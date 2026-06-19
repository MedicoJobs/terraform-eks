locals {
  common_tags = {
    Project     = "medicojobs"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

module "vpc" {
  source = "./modules/vpc"

  cluster_name = var.cluster_name
  vpc_cidr     = var.vpc_cidr
  common_tags  = local.common_tags
}

module "subnets" {
  source = "./modules/subnets"

  cluster_name         = var.cluster_name
  vpc_id               = module.vpc.vpc_id
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  common_tags          = local.common_tags
}

module "internet_gateway" {
  source = "./modules/internet-gateway"

  cluster_name = var.cluster_name
  vpc_id       = module.vpc.vpc_id
  common_tags  = local.common_tags
}

module "nat_gateway" {
  source = "./modules/nat-gateway"

  cluster_name        = var.cluster_name
  public_subnet_id    = module.subnets.public_subnet_ids[0]
  internet_gateway_id = module.internet_gateway.igw_id
  common_tags         = local.common_tags
}

module "route_tables" {
  source = "./modules/route-tables"

  cluster_name        = var.cluster_name
  vpc_id              = module.vpc.vpc_id
  internet_gateway_id = module.internet_gateway.igw_id
  nat_gateway_id      = module.nat_gateway.nat_gateway_id
  public_subnet_ids   = module.subnets.public_subnet_ids
  private_subnet_ids  = module.subnets.private_subnet_ids
  common_tags         = local.common_tags
}

module "eks" {
  source = "./modules/eks"

  cluster_name        = var.cluster_name
  kubernetes_version  = var.kubernetes_version
  public_subnet_ids   = module.subnets.public_subnet_ids
  private_subnet_ids  = module.subnets.private_subnet_ids
  node_instance_types = var.node_instance_types
  node_desired_size   = var.node_desired_size
  node_min_size       = var.node_min_size
  node_max_size       = var.node_max_size
  common_tags         = local.common_tags

  depends_on = [module.route_tables]
}

module "ecr" {
  source = "./modules/ecr"

  repository_names = var.ecr_repository_names
  scan_on_push     = var.ecr_scan_on_push
  common_tags      = local.common_tags
}
