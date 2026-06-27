aws_region         = "ap-south-1"
cluster_name       = "medicojobs-cluster"
environment        = "dev"
kubernetes_version = "1.30"

node_instance_types = ["c7i-flex.large"]
node_desired_size   = 2
node_min_size       = 1
node_max_size       = 3

eks_console_admin_principal_arns = [
  "arn:aws:iam::194418667391:user/admin"
]

ecr_repository_names = [
  "medicojob-api-gateway",
  "medicojob-user-service",
  "medicojob-job-service",
  "medicojob-matching-service",
  "medicojob-availability-service",
  "medicojob-location-service",
  "medicojob-reputation-service",
  "medicojob-course-service",
  "medicojob-resume-service",
  "medicojob-frontend"
]

domain_name            = "medicojobs.online"
create_route53_zone    = true
route53_zone_name      = "medicojobs.online"
hosted_zone_id         = ""
create_acm_certificate = false
acm_certificate_arn    = ""

argocd_git_repo_url = "https://github.com/MedicoJobs/Helm.git"
argocd_git_revision = "main"
argocd_app_path     = "app-of-apps"

sonarqube_enabled               = false
github_actions_allowed_branches = ["*"]

cloudfront_enabled    = true
external_alb_dns_name = "k8s-medicojobs-f8e7af1243-17509298.ap-south-1.elb.amazonaws.com"

alert_email_endpoints = ["pavithrasampath0609@gmail.com"]