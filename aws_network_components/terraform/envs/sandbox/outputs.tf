output "shared_services_vpc_id" {
  value = module.shared_services_vpc.vpc_id
}

output "shared_services_private_subnet_ids" {
  value = module.shared_services_vpc.private_subnet_ids
}
# EC2 test harness. one() returns null instead of erroring when disabled.
output "ec2_test_shared_services_ids" {
  value = one(module.ec2_test_shared_services[*].instance_ids)
}

output "ec2_test_shared_services_ips" {
  value = one(module.ec2_test_shared_services[*].private_ips)
}
