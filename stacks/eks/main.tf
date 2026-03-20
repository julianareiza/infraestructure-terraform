locals {
  configs = jsondecode(file("${path.module}/vars/${terraform.workspace}.json"))
}

module "eks" {
  source = "../../modules/eks"

  cluster_name         = local.configs.eks.cluster_name
  cluster_version      = try(local.configs.eks.cluster_version, "1.31")
  vpc_name             = local.configs.eks.vpc_name
  private_subnet_names = local.configs.eks.private_subnet_names
  public_subnet_names  = local.configs.eks.public_subnet_names
  node_instance_types  = try(local.configs.eks.node_instance_types, ["t3.medium"])
  node_desired_size    = try(local.configs.eks.node_desired_size, 2)
  node_min_size        = try(local.configs.eks.node_min_size, 1)
  node_max_size        = try(local.configs.eks.node_max_size, 3)
  node_disk_size       = try(local.configs.eks.node_disk_size, 20)
  node_capacity_type   = try(local.configs.eks.node_capacity_type, "ON_DEMAND")
  tags                 = try(local.configs.eks.tags, {})
}

module "ecr" {
  source   = "../../modules/ecr"
  for_each = try(local.configs.ecr_repositories, {})

  repository_name      = each.value.repository_name
  scan_on_push         = try(each.value.scan_on_push, true)
  max_image_count      = try(each.value.max_image_count, 10)
  image_tag_mutability = try(each.value.image_tag_mutability, "MUTABLE")
  tags                 = try(each.value.tags, {})
}
