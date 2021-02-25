

variable "servers" {
  description = "Map of server types to configuration"
  type        = map(any)
  default = {
    server-iis = {
      ami                    = "ami-07f5c641c23596eb9"
      instance_type          = "t2.micro",
      environment            = "dev"
      subnet_id              = "subnet-031bf0c9a309fcd8d"
      vpc_security_group_ids = ["sg-01380b40dc19ad166"]
    },
    server-apache = {
      ami                    = "ami-07f5c641c23596eb9"
      instance_type          = "t2.nano",
      environment            = "test"
      subnet_id              = "subnet-031bf0c9a309fcd8d"
      vpc_security_group_ids = ["sg-01380b40dc19ad166"]
    }
  }
}

resource "aws_instance" "caddi_web" {

  for_each      = var.servers
  ami           = each.value.ami
  instance_type = each.value.instance_type

  subnet_id              = each.value.subnet_id
  vpc_security_group_ids = each.value.vpc_security_group_ids

  key_name = var.key_name

  tags = {
    "Identity"    = var.student_id
    "Name"        = "${var.student_name}-${each.key}"
    "Environment" = each.value.environment
  }
}

output "caddi_public_dns" {
  description = "Public DNS names of the Servers"
  value       = { for p in sort(keys(var.servers)) : p => aws_instance.caddi_web[p].public_dns }
}

output "caddi_public_ip" {
  description = "Public IP of the Servers"
  value       = { for p in sort(keys(var.servers)) : p => aws_instance.caddi_web[p].public_ip }
}
