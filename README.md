# AWS infrastructure module exercise (Terraform coursework)

This repository is a **learning scaffold**, not a validated deployable application. It sketches a VPC, public/private subnets, security groups, an ALB, EC2 Auto Scaling, and MySQL RDS as separate modules.

## Security note

The original coursework committed a sample database password directly in `modules/rds/main.tf`. The current source takes it from sensitive input instead and no longer outputs it. **If that password was ever used in a real environment, rotate it immediately**; removing it from the latest commit does not erase Git history. Terraform state can still contain secrets, so use a protected remote state backend and never commit state or `.tfvars` files.

## Inspect locally

From `terraform-main/`, supply a new secret through your shell or a secure secret manager, not a committed file:

```bash
export TF_VAR_database_password='a-new-secret-from-your-secret-manager'
terraform init
terraform fmt -check -recursive
terraform validate
```

Do **not** run `terraform apply` for this exercise as-is. The EC2 user data is only a placeholder and does not start an application; the target group's `/healthz` check will fail. The network and module wiring also need deployment validation. AWS resources can incur charges. No AWS account deployment or Terraform CLI validation was performed for this portfolio update.

For an interview, discuss the intended layers and what remains to make them production-ready: secret management, a secure state backend, route tables, multiple private subnet AZs for RDS, a real app bootstrap, health checks, TLS, cost controls, and teardown. Do not describe this repository as a live highly available system.
