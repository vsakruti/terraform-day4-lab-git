
output "venkat_public_ip" {
  value = module.server.caddi_public_ip
}

output "venkat_public_dns" {
  value = module.server.caddi_public_dns
}

output "venkat_private_key" {
  value = module.keypair.private_key_pem
}
