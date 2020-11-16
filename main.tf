provider "aws" {
  region = "eu-west-2"
}

resource "aws_vpc" "myNetwork" {
  cidr_block = "192.168.0.0/24"
}

data "aws_ami" "ubuntu" {
    most_recent = true
 
  filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]
}

resource "aws_instance" "test" {
  ami = data.aws_ami.ubuntu.id
  instance_type = local.web_instance_type_map[terraform.workspace]
  count = local.web_instance_count_map[terraform.workspace]
  availability_zone = "eu-west-2a"
  monitoring = true

  tags = {
    Name = "newProject"
  }
}
locals {
	web_instance_type_map = {
	stage = "t3.micro"
	prod = "t3.large"
	}
	web_instance_count_map = {
	stage = 1
	prod = 2
	}
}

locals {
  instances = {
    "t3.micro" = data.aws_ami.ubuntu.id
    "t3.large" = data.aws_ami.ubuntu.id
    "t3.large" = data.aws_ami.ubuntu.id
  }
}

resource "aws_instance" "test2" {
  for_each = local.instances

  ami = each.value
  instance_type = each.key
  tags = {
  Name = "foreach"
  }
}

terraform {
  backend "s3" {
    bucket = "mytest83252"
    key    = "path/mykey"
	encrypt = true
    region = "eu-west-2"
  }
}
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}