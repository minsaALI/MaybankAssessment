output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnets" {
  value = [for s in aws_subnet.public : s.id]
}

output "private_subnets" {
  value = [for s in aws_subnet.private : s.id]
}

output "ssm_host_public_ip" {
  value = aws_instance.ssm_host.public_ip
}

output "rds_master_endpoint" {
  value = aws_db_instance.master.address
}

output "cloudfront_domain" {
  value = aws_cloudfront_distribution.cdn.domain_name
}
