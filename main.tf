#####################
# AWS Configuration #
#####################

resource "aws_vpc" "ec2_vpc" {
  count = "${var.cloud_provider == "aws" ? 1 : 0}"

  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags {
    name        = "vpc-${var.global_environment}-${var.global_purpose}"
    environment = "${var.global_environment}"
    owner       = "${var.global_owner}"
    purpose     = "${var.global_purpose}"
    cloud       = "${var.cloud_provider}"
  }
}

resource "aws_subnet" "ec2_subnet" {
  count = "${var.cloud_provider == "aws" ? 1 : 0}"

  vpc_id                  = "${aws_vpc.ec2_vpc.id}"
  cidr_block              = "${cidrsubnet(var.global_address_space, 8, 1)}"
  map_public_ip_on_launch = true

  tags {
    name        = "subnet-${var.global_environment}-${var.global_purpose}"
    environment = "${var.global_environment}"
    owner       = "${var.global_owner}"
    purpose     = "${var.global_purpose}"
    cloud       = "${var.cloud_provider}"
  }
}

resource "aws_internet_gateway" "ec2_igw" {
  count = "${var.cloud_provider == "aws" ? 1 : 0}"

  vpc_id = "${aws_vpc.ec2_vpc.id}"

  tags {
    name        = "igw-${var.global_environment}-${var.global_purpose}"
    environment = "${var.global_environment}"
    owner       = "${var.global_owner}"
    purpose     = "${var.global_purpose}"
    cloud       = "${var.cloud_provider}"
  }
}

resource "aws_route_table" "ec2_rtb" {
  count = "${var.cloud_provider == "aws" ? 1 : 0}"

  vpc_id = "${aws_vpc.ec2_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.ec2_igw.id}"
  }

  tags {
    name        = "route_table-${var.global_environment}-${var.global_purpose}"
    environment = "${var.global_environment}"
    owner       = "${var.global_owner}"
    purpose     = "${var.global_purpose}"
    cloud       = "${var.cloud_provider}"
  }
}

resource "aws_route_table_association" "ec2_rtb_assoc" {
  count = "${var.cloud_provider == "aws" ? 1 : 0}"

  subnet_id      = "${aws_subnet.ec2_subnet.id}"
  route_table_id = "${aws_route_table.ec2_rtb.id}"
}

resource "aws_security_group" "ec2_sg" {
  count = "${var.cloud_provider == "aws" ? 1 : 0}"

  name        = "ec2_sg"
  description = "Security Group allowing access to Vault instance"
  vpc_id      = "${aws_vpc.ec2_vpc.id}"

  tags {
    name        = "sg-${var.global_environment}-${var.global_purpose}"
    environment = "${var.global_environment}"
    owner       = "${var.global_owner}"
    purpose     = "${var.global_purpose}"
    cloud       = "${var.cloud_provider}"
  }
}

resource "aws_security_group_rule" "ec2_custom_rules" {
  count             = "${length(var.ec2_custom_security_rules) * (var.cloud_provider == "aws" ? 1 : 0)}"
  type              = "${lookup(var.ec2_custom_security_rules[count.index], "type")}"
  from_port         = "${lookup(var.ec2_custom_security_rules[count.index], "from_port")}"
  to_port           = "${lookup(var.ec2_custom_security_rules[count.index], "to_port")}"
  protocol          = "${lookup(var.ec2_custom_security_rules[count.index], "protocol")}"
  cidr_blocks       = "${var.ec2_cidr_blocks}"
  description       = "${lookup(var.ec2_custom_security_rules[count.index], "description")}"
  security_group_id = "${aws_security_group.ec2_sg.id}"
}

resource "aws_route53_zone" "ec2_route53_zone" {
  count = "${var.cloud_provider == "aws" ? 1 : 0}"

  name = "demo${var.cloud_provider}.my-v-world.com"
}

resource "aws_key_pair" "ec2_key" {
  count = "${var.cloud_provider == "aws" ? 1 : 0}"

  key_name   = "${var.global_key_name}"
  public_key = "${var.ssh_public_key}"
}

resource "aws_instance" "vault_vm" {
  count = "${var.vault_vm_count * (var.cloud_provider == "aws" ? 1 : 0)}"

  ami                         = "${data.aws_ami.rhel.id}"
  instance_type               = "t2.medium"
  subnet_id                   = "${aws_subnet.ec2_subnet.id}"
  private_ip                  = "${cidrhost(aws_subnet.ec2_subnet.cidr_block, count.index + 100)}"
  associate_public_ip_address = "true"
  vpc_security_group_ids      = ["${aws_security_group.ec2_sg.id}"]
  key_name                    = "${var.global_key_name}"

  root_block_device {
    volume_size = "50"
  }

  ebs_block_device {
    device_name = "sdf"
    volume_size = "100"
  }

  tags {
    Name        = "${var.global_vm_apps}-${var.global_environment}-vault-${count.index}"
    environment = "${var.global_environment}"
    owner       = "${var.global_owner}"
    purpose     = "vault"
    cloud       = "${var.cloud_provider}"
  }
}

resource "aws_instance" "consul_vm" {
  count = "${var.consul_vm_count * (var.cloud_provider == "aws" ? 1 : 0)}"

  ami                         = "${data.aws_ami.rhel.id}"
  instance_type               = "t2.medium"
  subnet_id                   = "${aws_subnet.ec2_subnet.id}"
  private_ip                  = "${cidrhost(aws_subnet.ec2_subnet.cidr_block, count.index + 110)}"
  associate_public_ip_address = "true"
  vpc_security_group_ids      = ["${aws_security_group.ec2_sg.id}"]
  key_name                    = "${var.global_key_name}"

  root_block_device {
    volume_size = "50"
  }

  tags {
    Name        = "${var.global_vm_apps}-${var.global_environment}-consul-${count.index}"
    environment = "${var.global_environment}"
    owner       = "${var.global_owner}"
    purpose     = "consul"
    cloud       = "${var.cloud_provider}"
  }
}

resource "aws_route53_record" "vault_route53_records" {
  count = "${var.vault_vm_count * (var.cloud_provider == "aws" ? 1 : 0)}"

  zone_id = "${aws_route53_zone.ec2_route53_zone.zone_id}"
  name    = "${lookup(aws_instance.vault_vm.*.tags[count.index], "Name")}"
  type    = "A"
  ttl     = "300"
  records = ["${element(aws_instance.vault_vm.*.public_ip, count.index)}"]
}

resource "aws_route53_record" "consul_route53_records" {
  count = "${var.consul_vm_count * (var.cloud_provider == "aws" ? 1 : 0)}"

  zone_id = "${aws_route53_zone.ec2_route53_zone.zone_id}"
  name    = "${lookup(aws_instance.consul_vm.*.tags[count.index], "Name")}"
  type    = "A"
  ttl     = "300"
  records = ["${element(aws_instance.consul_vm.*.public_ip, count.index)}"]
}
