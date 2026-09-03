output "shared_services_vpc_id" {
  value = module.shared_services_vpc.vpc_id
}

output "shared_services_private_subnet_ids" {
  value = module.shared_services_vpc.private_subnet_ids
}