module "keypair" {
  source  = "mitchellh/dynamic-keys/aws"
  version = "2.0.0"
  path    = "${path.root}/keys"
  name    = "${var.identity}-key-foreach-git"
}

module "server" {
  source       = "./server"
  identity     = var.identity
  access_key   = var.access_key
  secret_key   = var.secret_key
  region = var.region
  student_name = var.student_name
  student_id   = var.student_id
  key_name     = module.keypair.key_name
  private_key  = module.keypair.private_key_pem
}
