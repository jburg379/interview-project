## Intro

This repository is for a 3-tier VPC architecture with multiple avilability zones built using terraform. It was designed to meet Coalfire's minimum requirements.
Modules from terraform and Coalfire's repo were used in this project.

## Analysis

# Security

Depending on how the infrastructure will be used and the data that it stores. There are different levels of security requirements and AWS has a number of services we can use to keep our data secure.
The infrastructure uses security groups and private subnets to add some security. Security groups work at the instance level. However, this is minimal security. Below are some ways we could increase security.

* It does not have NACL (Network Access Control List) which would add extra security at the subnet level.
* A WAF (Web Aplpication Firewall) could be applied to the ALB (Application Load Balancer) to help filter traffic [What is AWS WAF](https://aws.amazon.com/waf/)
* AWS Shield could also be used to help protect the ALB from DDoS (Distributed Denial of Service)
* IAM roles be created and assigned with following the principle of least privelage
* Create an IAM User who will have access and enforce MFA (Multi Factor Athentication)
* Use Amazon GuardDuty for threat detection [What is Amazon GuardDuty](https://docs.aws.amazon.com/guardduty/latest/ug/what-is-guardduty.html) 


## Prerequisites

Below are some of the things you will need to provision the infrastructure. The links will provide extra help and information

* Terraform - this is an open source infrastructure as code software tool used to provision and manade cloud and on prem resources. [What is Terraform](https://developer.hashicorp.com/terraform/intro)
* [How to install Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
* AWS Account and credentials to create resources in the us-east-1 region. (Create a AWS account) [https://aws.amazon.com/console/]
* AWS CLI - use the AWS CLI to configure your AWS credentials. You will need you AWS access key ID and Secret Access key
* [How to install AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
* [Help to connect terraform with AWS](https://dev.to/aws-builders/connecting-aws-with-terraform-a-short-guide-4bda)

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.85 |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 2.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.100.0 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.6.1 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.1.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_alb"></a> [alb](#module\_alb) | terraform-aws-modules/alb/aws | 9.13.0 |
| <a name="module_alb_sg"></a> [alb\_sg](#module\_alb\_sg) | terraform-aws-modules/security-group/aws | 5.3.1 |
| <a name="module_application_sg"></a> [application\_sg](#module\_application\_sg) | terraform-aws-modules/security-group/aws | 5.3.1 |
| <a name="module_asg"></a> [asg](#module\_asg) | terraform-aws-modules/autoscaling/aws | 8.3.1 |
| <a name="module_management_ec2"></a> [management\_ec2](#module\_management\_ec2) | terraform-aws-modules/ec2-instance/aws | 5.8.0 |
| <a name="module_management_sg"></a> [management\_sg](#module\_management\_sg) | terraform-aws-modules/security-group/aws | 5.3.1 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | git::https://github.com/Coalfire-CF/terraform-aws-vpc-nfw.git | v3.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_internet_gateway.igw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_key_pair.project](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_route.management_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.management_rt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.application](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.backend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.management](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [local_file.project_key](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [tls_private_key.project](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | aws linux ami for the EC2 instances | `string` | `"ami-0532be01f26a3de55"` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region to deploy resources | `string` | `"us-east-1"` | no |
| <a name="input_custom_ip"></a> [custom\_ip](#input\_custom\_ip) | IP address to ssh to the management EC2 | `string` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | instance type for the EC2 instances | `string` | `"t2.micro"` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | key name for the aws key pair | `string` | `"project"` | no |

## Outputs

No outputs.
