# Launch template for ASG
resource "aws_launch_template" "app" {
  name_prefix = "${var.name_prefix}-lt-"
  image_id    = data.aws_ami.ubuntu.id
  instance_type = var.asg_instance_type

  dynamic "key_name" {
    for_each = length(var.key_pair_name) > 0 ? [1] : []
    content {
      key_name = var.key_pair_name
    }
  }

  vpc_security_group_ids = [aws_security_group.app.id]

  user_data = base64encode("#!/bin/bash\nset -e\n#")
  tag_specifications {
    resource_type = "instance"
    tags = { Name = "${var.name_prefix}-asg-instance" }
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] 
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

resource "aws_autoscaling_group" "app" {
  name_prefix          = "${var.name_prefix}-asg-"
  desired_capacity     = var.desired_capacity
  min_size             = var.min_size
  max_size             = var.max_size
  health_check_type    = "EC2"
  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }
  vpc_zone_identifier = [for s in aws_subnet.private : s.id]
  tags = [
    {
      key                 = "Name"
      value               = "${var.name_prefix}-asg"
      propagate_at_launch = true
    }
  ]
}

# SSM jump host
resource "aws_instance" "ssm_host" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type_ssm
  subnet_id     = element(aws_subnet.public.*.id, 0)
  vpc_security_group_ids = [aws_security_group.ssm_host.id]
  tags = { Name = "${var.name_prefix}-ssm-host" }
  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name

  dynamic "key_name" {
    for_each = length(var.key_pair_name) > 0 ? [1] : []
    content {
      key_name = var.key_pair_name
    }
  }
}

# IAM role & profile for SSM
resource "aws_iam_role" "ssm_role" {
  name = "${var.name_prefix}-ssm-role"
  assume_role_policy = data.aws_iam_policy_document.ssm_assume.json
}

data "aws_iam_policy_document" "ssm_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "${var.name_prefix}-ssm-profile"
  role = aws_iam_role.ssm_role.name
}
