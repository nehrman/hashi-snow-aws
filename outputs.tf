output "VM_ips" {
  value = "${aws_instance.vault_vm.*.public_ip}"
}

output "dns_server" {
  value = "${aws_route53_zone.ec2_route53_zone.*.name_servers}"
}
