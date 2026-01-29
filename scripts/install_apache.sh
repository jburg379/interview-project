#!/bin/bash

#This script is to install apache on Amazon Linux 2023

apt update -y
apt install -y httpd

systemctl enable httpd
systemctl start httpd

echo "Hello Coalfire" > /var/www/html/index.html