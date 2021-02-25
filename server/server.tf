

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

  connection {
    user        = "ubuntu"
    private_key = var.private_key
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "../assets"
    destination = "/tmp/"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo sh /tmp/assets/setup-web.sh",
    ]
  }

}

/*
resource "null_resource" "web_cluster" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    web_cluster_instance_ids = "${join(",",
    { for p in sort(keys(var.servers)) : p => aws_instance.caddi_web[p].id })}"
  }

  # Bootstrap script can run on any instance of the cluster
  # So we just choose the first in this case
  connection {
    host = element(aws_instance.caddi_web.*.public_ip, 0)
  }

  provisioner "local-exec" {
    # Bootstrap script called with private_ip of each node in the clutser
    command = "echo Nodes of the Cluster: ${join(", ", aws_instance.caddi_web.*.private_ip)}"
  }
} */

output "caddi_public_dns" {
  description = "Public DNS names of the Servers"
  value       = { for p in sort(keys(var.servers)) : p => aws_instance.caddi_web[p].public_dns }
}

output "caddi_public_ip" {
  description = "Public IP of the Servers"
  value       = { for p in sort(keys(var.servers)) : p => aws_instance.caddi_web[p].public_ip }
}
