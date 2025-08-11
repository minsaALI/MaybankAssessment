# Security Group for NLB -> Application servers (allow traffic from NLB)
resource "aws_security_group" "app" {
  name   = "${var.name_prefix}-sg-app"
  vpc_id = aws_vpc.main.id
  description = "Allow traffic from NLB and allow egress"
  ingress {
    description = "Allow from NLB"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.nlb.id]
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.name_prefix}-sg-app" }
}

# Security group for NLB (target group uses instance protocol TCP 80)
resource "aws_security_group" "nlb" {
  name   = "${var.name_prefix}-sg-nlb"
  vpc_id = aws_vpc.main.id
  description = "Used by NLB for health checks and forwarding"
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.name_prefix}-sg-nlb" }
}

# Security group for SSM-host to allow SSH optionally and SSM traffic
resource "aws_security_group" "ssm_host" {
  name   = "${var.name_prefix}-sg-ssm"
  vpc_id = aws_vpc.main.id
  description = "SSM host security group"
  ingress {
    description = "Optional SSH for admin (replace with your IP)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Replace with admin CIDR
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.name_prefix}-sg-ssm" }
}

# Security group for RDS
resource "aws_security_group" "rds" {
  name   = "${var.name_prefix}-sg-rds"
  vpc_id = aws_vpc.main.id
  description = "RDS security group - allow only app and ssm host to access DB"
  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"
    security_groups = [aws_security_group.app.id, aws_security_group.ssm_host.id]
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.name_prefix}-sg-rds" }
}
