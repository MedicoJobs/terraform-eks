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

module "vpc_endpoints" {
  source = "./modules/vpc-endpoints"

  cluster_name = var.cluster_name
  aws_region   = var.aws_region
  vpc_id       = module.vpc.vpc_id
  route_table_ids = [
    module.route_tables.private_route_table_id
  ]
  common_tags = local.common_tags
}

module "eks" {
  source = "./modules/eks"

  cluster_name                 = var.cluster_name
  kubernetes_version           = var.kubernetes_version
  public_subnet_ids            = module.subnets.public_subnet_ids
  private_subnet_ids           = module.subnets.private_subnet_ids
  node_instance_types          = var.node_instance_types
  node_desired_size            = var.node_desired_size
  node_min_size                = var.node_min_size
  node_max_size                = var.node_max_size
  console_admin_principal_arns = var.eks_console_admin_principal_arns
  common_tags                  = local.common_tags

  depends_on = [module.route_tables]
}


data "aws_caller_identity" "current" {}

module "github_actions_iam" {
  source = "./modules/github-actions-iam"

  cluster_name        = var.cluster_name
  github_org          = var.github_org
  repository_names    = var.github_actions_repository_names
  allowed_branches    = var.github_actions_allowed_branches
  ecr_repository_arns = [for repo in var.ecr_repository_names : "arn:aws:ecr:${var.aws_region}:${data.aws_caller_identity.current.account_id}:repository/${repo}"]
  common_tags         = local.common_tags
}

module "security_kms" {
  source = "./modules/security-kms"

  cluster_name = var.cluster_name
  common_tags  = local.common_tags
}

  module "app_data" {
  source = "./modules/app-data"

  cluster_name         = var.cluster_name
  service_names        = var.microservice_names
  dynamodb_table_names = var.dynamodb_table_names
  s3_bucket_name       = var.uploads_bucket_name
  kms_key_arn          = module.security_kms.key_arn
  common_tags          = local.common_tags
}

module "route53" {
  source = "./modules/route53"

  cluster_name        = var.cluster_name
  domain_name         = var.domain_name
  hosted_zone_id      = var.hosted_zone_id
  create_route53_zone = var.create_route53_zone
  route53_zone_name   = var.route53_zone_name
  common_tags         = local.common_tags
}

module "acm" {
  source = "./modules/acm"

  cluster_name           = var.cluster_name
  domain_name            = var.domain_name
  hosted_zone_id         = module.route53.hosted_zone_id
  create_acm_certificate = var.create_acm_certificate
  acm_certificate_arn    = var.acm_certificate_arn
  common_tags            = local.common_tags
}

module "edge" {
  source = "./modules/edge"

  providers = {
    aws = aws.us_east_1
  }

  cloudfront_enabled = var.cloudfront_enabled
  domain_name        = var.domain_name
  hosted_zone_id     = module.route53.hosted_zone_id
  alb_dns_name       = var.external_alb_dns_name
  common_tags        = local.common_tags
}

module "observability" {
  source = "./modules/observability"

  cluster_name        = var.cluster_name
  aws_region          = var.aws_region
  sns_email_endpoints = var.alert_email_endpoints
  kms_key_arn         = module.security_kms.key_arn
  common_tags         = local.common_tags
}

module "addons" {
  source = "./modules/addons"

  cluster_name                          = module.eks.cluster_name
  aws_region                            = var.aws_region
  vpc_id                                = module.vpc.vpc_id
  oidc_issuer_url                       = module.eks.oidc_issuer_url
  hosted_zone_id                        = module.route53.hosted_zone_id
  domain_name                           = var.domain_name
  acm_certificate_arn                   = module.acm.certificate_arn
  argocd_git_repo_url                   = var.argocd_git_repo_url
  argocd_git_revision                   = var.argocd_git_revision
  argocd_app_path                       = var.argocd_app_path
  argocd_app_chart_path                 = "${path.module}/charts/argocd-app"
  sonarqube_enabled                     = var.sonarqube_enabled
  sonarqube_host_name                   = var.sonarqube_host_name
  sonarqube_chart_version               = var.sonarqube_chart_version
  sonarqube_monitoring_passcode         = var.sonarqube_monitoring_passcode
  sonarqube_persistence_size            = var.sonarqube_persistence_size
  sonarqube_storage_class               = var.sonarqube_storage_class
  sonarqube_postgresql_persistence_size = var.sonarqube_postgresql_persistence_size
  workload_namespace                    = "medicojobs-prod"
  workload_service_account_names        = var.microservice_names
  workload_data_access_policy_arn       = module.app_data.workload_data_access_policy_arn
  common_tags                           = local.common_tags

  depends_on = [module.eks, module.app_data]
}
