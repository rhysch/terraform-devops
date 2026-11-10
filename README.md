# Terraform AWS EC2 Learning Project

This project practices provisioning AWS networking and EC2 instances with Terraform. It creates a VPC, public subnet, internet gateway and route, security group, EC2 key pair, and four EC2 instances.

## Terraform concepts used

- **Provider:** `provider.tf` selects the AWS provider and region. Credentials should come from an AWS CLI profile, IAM Identity Center, or an attached IAM role; do not put access keys in Terraform files.
- **Resources:** `my-ec2.tf` declares AWS objects. Terraform infers dependency order from references such as `aws_subnet.rhys_subnet.id`.
- **Variables:** `variable.tf` declares configurable inputs. `ami_id` is used by the EC2 resource. `ec2_instance_type` is currently declared but unused; instance sizes instead come from the `for_each` map in `my-ec2.tf`.
- **`for_each`:** the EC2 resource creates one instance per map entry, with stable addresses such as `aws_instance.mine_ec2["dev-instance"]`.
- **Outputs:** `output.tf` collects public IPs after apply. Outputs can be read later with `terraform output ec2_IP`.
- **State:** Terraform state maps configuration addresses to real AWS resource IDs. Treat state as sensitive, keep it private, and do not manually edit it. The current project uses local state, appropriate for a solo exercise but not ideal for collaboration.
- **Dependency lock file:** `.terraform.lock.hcl` records the selected provider version and checksums. Commit this file so installs are repeatable.

## Inputs worth making configurable

Use variables for settings that differ between users or environments, such as region, AMI, instance size, SSH source CIDR, and instance names. For example:

```hcl
variable "aws_region" {
  description = "AWS region for this deployment"
  type        = string
  default     = "ap-south-1"
}

variable "ssh_cidr" {
  description = "Your public IPv4 address in CIDR notation, for example 203.0.113.10/32"
  type        = string
}
```

Then use `var.aws_region` in the provider and `var.ssh_cidr` for the SSH ingress rule. Set personal values in an untracked `terraform.tfvars` file, or pass them with `-var`. Never commit personal values or secrets.

The current `ec2_instance_type` variable is not wired into the EC2 resource. Either remove it or use it in the `for_each` map, for example `"dev-instance" = var.ec2_instance_type`.

## Safety and practical improvements

- Restrict SSH ingress on port 22 to your own IP (`x.x.x.x/32`) instead of `0.0.0.0/0`. Keep HTTP/HTTPS public only if the web server is intended to be public.
- Check the AWS Free Tier or account plan before choosing instance types, storage sizes, or the number of instances. Four instances can incur charges.
- The public key path should expand the home directory: `file(pathexpand("~/.ssh/rhys-ec2-key.pub"))`. Only the `.pub` key belongs here; never put the private key in Git.
- Pin a compatible Terraform CLI version with `required_version` so contributors know which CLI versions the project supports.
- Add a README, as here, to document prerequisites, deployment steps, expected resources, and cleanup.
- For team use, configure remote state with encryption, access control, and state locking. Do not upload a local state file to a public repository.
- Modules are useful when a set of resources should be reused. For a small learning project, keeping the resources in the root module is fine; extract a VPC or EC2 module when you want to practice reuse.

## Typical workflow

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform output ec2_IP
```

Review the plan before applying. `terraform apply` creates billable AWS resources.

When finished, review and remove only this project's resources with:

```bash
terraform plan -destroy
terraform destroy
```

## Git hygiene

Commit `.tf` files, this README, and `.terraform.lock.hcl`. Do not commit `.terraform/`, `terraform.tfstate`, `terraform.tfstate.backup`, private SSH keys, or personal `terraform.tfvars` files. Add these local files to `.gitignore` before pushing to GitHub.
