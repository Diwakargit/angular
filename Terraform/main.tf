provider "aws" {
  region = "us-east-1"
}

######################################
# Data sources to get VPC and subnets
######################################
data "aws_vpc" "default" {
  default = false
  tags = {
        Name = "default"
}
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.default.id
}
 


#############
# RDS Aurora
#############

resource "aws_db_subnet_group" "default" {
  name        = "cse-cr"
  description = "Private subnets for RDS instance"
  subnet_ids  = data.aws_subnet_ids.all.ids
}

resource "aws_rds_cluster" "default" {
  cluster_identifier      = "sample"
  vpc_security_group_ids  = [aws_security_group.app_servers.id]
  db_subnet_group_name    = aws_db_subnet_group.default.name
  engine_mode             = "serverless"
  master_username         = "admin"
  master_password         = "passwrd"
  backup_retention_period = 7
  skip_final_snapshot     = false

  scaling_configuration {
    auto_pause               = true
    max_capacity             = 2
    min_capacity             = 2
    seconds_until_auto_pause = 300
  }
}



resource "aws_db_parameter_group" "aurora_db_57_parameter_group" {
  name        = "test-aurora56-parameter-group"
  family      = "aurora5.6"
  description = "test-aurora56-parameter-group"
}

resource "aws_rds_cluster_parameter_group" "aurora_57_cluster_parameter_group" {
  name        = "test-aurora56-cluster-parameter-group"
  family      = "aurora5.6"
  description = "test-aurora56-cluster-parameter-group"
}

resource "random_password" "master_password" {
length = 16
special = false
}

############################
# Example of security group
############################
resource "aws_security_group" "app_servers" {
  name        = "app-servers"
  description = "For application servers"
  vpc_id      = data.aws_vpc.default.id
}