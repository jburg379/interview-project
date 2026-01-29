

####################

#VPC Configuration

####################

#This module is to configure the VPC and subnets
module "vpc" {
  source                    = "git::https://github.com/Coalfire-CF/terraform-aws-vpc-nfw.git?ref=v3.1.0" #pulling the VPC module from Coalfire's github repo
  vpc_name                  = "project-vpc"
  flow_log_destination_type = "cloud-watch-logs"
  cidr                      = "10.1.0.0/16"
  azs                       = ["us-east-1a", "us-east-1b"] #sets the available availability zones in which to provision the subnets
  subnets = [
    {
      custom_name       = "management",
      cidr              = "10.1.1.0/24",
      type              = "public",
      availability_zone = "us-east-1a"
    },
    {
      custom_name       = "application",
      cidr              = "10.1.2.0/24",
      type              = "private",
      availability_zone = "us-east-1a"
    },
    {
      custom_name       = "backend",
      cidr              = "10.1.3.0/24",
      type              = "private",
      availability_zone = "us-east-1b"
    },
    {
      custom_name       = "extra",
      cidr              = "10.1.4.0/24",
      type              = "public",
      availability_zone = "us-east-1b"
    }
  ]

  enable_nat_gateway = false #the NAT gateway is set to false to disable instances on a private subnet from connecting to the internet
}

####################

#Security Groups

####################

#Application Load Balancer (ALB) security group
module "alb_sg" {
  source  = "terraform-aws-modules/security-group/aws" #pulling the security group module from terraform
  version = "5.3.1"

  name   = "alb-sg"
  vpc_id = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp"]
  egress_rules        = ["all-all"]
}

#ASG security group
module "application_sg" {
  source  = "terraform-aws-modules/security-group/aws" #pulling the security group module from terraform
  version = "5.3.1"

  name   = "application-sg"
  vpc_id = module.vpc.vpc_id

  #Allows traffic from the ALB and Management EC2 security groups
  ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp",
      source_security_group_id = module.alb_sg.security_group_id
    },
    {
      rule                     = "ssh-tcp",
      source_security_group_id = module.management_sg.security_group_id
    }
  ]

  egress_rules = ["all-all"]
}

#Management subnet EC2 security group
module "management_sg" {
  source  = "terraform-aws-modules/security-group/aws" #pulling the security group module from terrafor
  version = "5.3.1"

  name   = "management-ec2-sg"
  vpc_id = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      rule        = "ssh-tcp",
      cidr_blocks = var.custom_ip
    }
  ]

  egress_rules = ["all-all"]
}

####################

#SSH Key generation

####################
#Generate an RSA SSH key pair locally
resource "tls_private_key" "project" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

#Upload the public key to AWS
resource "aws_key_pair" "project" {
  public_key = tls_private_key.project.public_key_openssh
  key_name   = var.key_name
}

#Write the private key to the disk securely
resource "local_file" "project_key" {
  content         = tls_private_key.project.private_key_pem
  filename        = "${path.module}/project.pem"
  file_permission = "0600"
}

####################

# EC2 Configuration

####################
#Configure management subnet EC2
module "management_ec2" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  version                = "5.8.0"
  name                   = "management-instance"
  subnet_id              = module.vpc.public_subnets["management"]
  vpc_security_group_ids = [module.management_sg.security_group_id]

  ami           = var.ami_id
  instance_type = var.instance_type #This cariable has been set to t2.micro as the default to meet requirements
  key_name      = aws_key_pair.project.key_name

  associate_public_ip_address = true #Auto assigns a public IP to the EC2

}

####################

#Application Load Balancer (ALB) configuration

####################

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "9.13.0"

  name               = "project-alb"
  load_balancer_type = "application"
  vpc_id             = module.vpc.vpc_id
  subnets            = [module.vpc.public_subnets["management"], module.vpc.public_subnets["extra"]]
  security_groups    = [module.alb_sg.security_group_id]

  enable_deletion_protection = false

  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"
      forward = {
        target_group_key = "application"
      }
    }
  }

  target_groups = {
    application = {
      port        = 80
      protocol    = "HTTP"
      target_type = "instance"
      create_attachment = false #Prevents creating empty attachment
      health_check = {
        path                = "/"
        matcher             = "200"
        interval            = 30
        timeout             = 5
        unhealthy_threshold = 2
        helthy_threshold    = 5
      }
    }
  }
}

####################

#Auto Scaling Group (ASG)

####################

module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "8.3.1"

  name                = "application-asg"
  min_size            = 2
  max_size            = 6
  desired_capacity    = 2
  vpc_zone_identifier = [module.vpc.private_subnets["application"]]

  image_id        = var.ami_id
  instance_type   = var.instance_type #This cariable has been set to t2.micro as the default to meet requirements
  security_groups = [module.application_sg.security_group_id]

  user_data = base64encode(file("${path.module}/scripts/install_apache.sh"))

  key_name      = aws_key_pair.project.key_name

  traffic_source_attachments = {
    alb = {
      traffic_source_identifier = module.alb.target_groups["application"].arn
      traffic_source_type       = "elbv2"
    }
  }

  create_iam_instance_profile = true
  iam_role_name               = "project-asg"
  iam_role_path               = "/ec2/"
  iam_role_description        = "IAM role for the ASG"
  iam_role_tags = {
    CustomIamRole = "Yes"
  }
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
}