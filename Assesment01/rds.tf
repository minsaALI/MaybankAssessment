# Subnet group for RDS using private subnets
resource "aws_db_subnet_group" "rds" {
  name       = "${var.name_prefix}-db-subnet-group"
  subnet_ids = [for s in aws_subnet.private : s.id]
  tags = { Name = "${var.name_prefix}-db-subnet-group" }
}

resource "aws_db_instance" "master" {
  identifier = "${var.name_prefix}-db-master"
  engine     = "mariadb"
  instance_class = var.db_instance_class
  allocated_storage = 20
  name = "assessmentdb"
  username = var.db_username
  password = var.db_password
  skip_final_snapshot = true
  db_subnet_group_name = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible = false
  multi_az = false
  tags = { Name = "${var.name_prefix}-db-master" }
}

# Read replica (asynchronous)
resource "aws_db_instance" "replica" {
  identifier = "${var.name_prefix}-db-replica"
  instance_class = var.db_instance_class
  replicate_source_db = aws_db_instance.master.id
  db_subnet_group_name = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible = false
  skip_final_snapshot = true
  tags = { Name = "${var.name_prefix}-db-replica" }
}
