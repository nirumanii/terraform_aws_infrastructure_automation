# 🚀 Terraform AWS Infrastructure Automation – Nginx Web Server Deployment

## 📖 Overview

This project demonstrates Infrastructure as Code (IaC) by provisioning a complete AWS environment using Terraform. It automates the deployment of a secure Virtual Private Cloud (VPC), networking components, security configurations, and an Amazon EC2 instance running an Nginx web server.

The infrastructure is fully automated, from creating the networking resources to generating an SSH key pair, launching the EC2 instance, installing Nginx, and providing outputs such as the web server URL and SSH connection command. This project highlights the benefits of Infrastructure as Code, including repeatable deployments, consistency, automation, and simplified infrastructure management.

## 🎯 Business Problem

Provisioning cloud infrastructure manually is time-consuming, error-prone, and difficult to maintain consistently across environments. Organizations require an automated and repeatable approach to deploy secure infrastructure while reducing manual configuration and operational overhead.

This project addresses these challenges by using Terraform to automate the provisioning of AWS infrastructure, including networking, security groups, EC2 instances, and web server installation. The solution ensures consistent deployments, improves operational efficiency, and demonstrates Infrastructure as Code (IaC) best practices.

## 🏗 Architecture
<p align="left">
  <img src="images/terraform-aws-architecture.png" width="50%">
</p>

## ☁️ AWS Services Used
🔹 Amazon VPC
🔹 Public Subnet
🔹 Internet Gateway
🔹 Route Table
🔹 Security Groups
🔹 Amazon EC2
🔹 AWS Key Pair
🔹 IAM (Access Permissions)

## 🛠️ Technologies
- Terraform
- AWS
- Amazon Linux 2023
- Nginx
- SSH
- TLS Provider
- Local Provider

## ✨ Features
- Automated AWS infrastructure provisioning using Terraform
- Creates a custom Amazon VPC with DNS support
- Configures a public subnet and Internet Gateway
- Creates and associates Route Tables
- Automatically generates SSH key pairs
- Securely stores the private key locally
- Deploys an Amazon Linux 2023 EC2 instance
- Configures Security Groups for SSH and HTTP access
- Automatically installs and starts the Nginx web server
- Provides Terraform outputs for EC2 public IP, Nginx URL, and SSH connection
