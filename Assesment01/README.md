Assessment Terraform - AWS Architecture

Overview
--------
This project contains Terraform configuration to create an AWS VPC-based architecture for an assessment. It includes:
- VPC with public and private subnets across two availability zones
- Internet Gateway and NAT Gateways (highly available pattern)
- Public Network Load Balancer (NLB)
- EC2 instance to act as an SSM jump host (SSM enabled)
- Auto Scaling Group for application servers (private subnets)
- RDS MariaDB primary and a read-replica with asynchronous replication (placeholders included)
- S3 bucket + CloudFront + Origin Access Control (OAC) for static content
- VPC Endpoint for SSM
- Security groups following least privilege patterns
- Outputs to make it easy to retrieve key endpoints

Notes & Next steps
------------------
- Replace placeholder values (db password, key pair name, certificate ARNs, region, etc.) in terraform.tfvars or environment variables before running.
- Run `terraform init` then `terraform plan` and `terraform apply`.
- Review IAM permissions and limit as needed.
- Ensure your account has limits for RDS instances and NAT gateways.

Files
-----
- providers.tf
- variables.tf
- terraform.tfvars.example
- network.tf
- compute.tf
- rds.tf
- s3_cloudfront.tf
- security.tf
- outputs.tf
