provider "aws" {
  region = "us-east-1"
}

variable "database_password" {
  type      = string
  sensitive = true
}

# Core Networking Module: VPC, Subnets, Internet Gateway, Routing
module "network_stack" {
  source = "./modules/network"
}

# Security Groups Module: ALB, EC2, and RDS rules
module "firewall_rules" {
  source = "./modules/security_groups"
  vpc_id = module.network_stack.vpc_id
}

# Database Setup Module: MySQL RDS hosted in private subnets
module "mysql_database" {
  source             = "./modules/rds"
  vpc_id             = module.network_stack.vpc_id
  private_subnet_ids = module.network_stack.private_subnet_ids
  db_sg_id           = module.firewall_rules.rds_sg_id
  app_sg_id          = module.firewall_rules.ec2_sg_id
  password           = var.database_password
}

# Application Layer Module: EC2 deployment in public subnets
module "application_layer" {
  source          = "./modules/ec2"
  subnet_ids      = module.network_stack.public_subnet_ids
  ec2_sg_id       = module.firewall_rules.ec2_sg_id
  database_host   = module.mysql_database.db_endpoint
  database_port   = module.mysql_database.db_port
  database_user   = module.mysql_database.username
  database_name   = module.mysql_database.db_name
}

# Load Balancer Module: Internet-facing ALB with listener and target group
module "http_alb" {
  source            = "./modules/alb"
  vpc_id            = module.network_stack.vpc_id
  public_subnet_ids = module.network_stack.public_subnet_ids
  alb_sg_id         = module.firewall_rules.alb_sg_id
}

# Auto Scaling Module: EC2 ASG config tied to the ALB target group
module "scaling_engine" {
  source              = "./modules/autoscaling"
  subnet_ids          = module.network_stack.public_subnet_ids
  target_group_arn    = module.http_alb.target_group_arn
  launch_template_id  = module.application_layer.launch_template_id
}
