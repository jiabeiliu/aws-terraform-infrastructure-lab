resource "aws_db_instance" "main" {
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  db_name           = "appdb"
  username          = "adminuser"
  password          = var.password
  port              = 3306

  vpc_security_group_ids = [var.db_sg_id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  skip_final_snapshot = true
}

resource "aws_db_subnet_group" "main" {
  name       = "main-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "db-subnet-group"
  }
}

output "db_endpoint" {
  value = aws_db_instance.main.address
}

output "db_port" {
  value = aws_db_instance.main.port
}

output "username" {
  value = aws_db_instance.main.username
}

output "db_name" {
  value = aws_db_instance.main.db_name
}

variable "password" {
  type      = string
  sensitive = true
}
