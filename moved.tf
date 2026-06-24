moved {
  from = aws_route53_zone.app[0]
  to   = module.route53.aws_route53_zone.app[0]
}

moved {
  from = aws_acm_certificate.app[0]
  to   = module.acm.aws_acm_certificate.app[0]
}

moved {
  from = aws_route53_record.app_cert_validation
  to   = module.acm.aws_route53_record.app_cert_validation
}

moved {
  from = aws_acm_certificate_validation.app[0]
  to   = module.acm.aws_acm_certificate_validation.app[0]
}

moved {
  from = aws_iam_openid_connect_provider.eks
  to   = module.addons.aws_iam_openid_connect_provider.eks
}

moved {
  from = aws_iam_role.aws_load_balancer_controller
  to   = module.addons.aws_iam_role.aws_load_balancer_controller
}

moved {
  from = aws_iam_policy.aws_load_balancer_controller
  to   = module.addons.aws_iam_policy.aws_load_balancer_controller
}

moved {
  from = aws_iam_role_policy_attachment.aws_load_balancer_controller
  to   = module.addons.aws_iam_role_policy_attachment.aws_load_balancer_controller
}

moved {
  from = aws_iam_role.external_dns
  to   = module.addons.aws_iam_role.external_dns
}

moved {
  from = aws_iam_policy.external_dns
  to   = module.addons.aws_iam_policy.external_dns
}

moved {
  from = aws_iam_role_policy_attachment.external_dns
  to   = module.addons.aws_iam_role_policy_attachment.external_dns
}

moved {
  from = aws_iam_role.cloudwatch_agent
  to   = module.addons.aws_iam_role.cloudwatch_agent
}

moved {
  from = aws_iam_role_policy_attachment.cloudwatch_agent
  to   = module.addons.aws_iam_role_policy_attachment.cloudwatch_agent
}

moved {
  from = helm_release.aws_load_balancer_controller
  to   = module.addons.helm_release.aws_load_balancer_controller
}

moved {
  from = helm_release.external_dns
  to   = module.addons.helm_release.external_dns
}

moved {
  from = helm_release.metrics_server
  to   = module.addons.helm_release.metrics_server
}

moved {
  from = helm_release.kube_prometheus_stack
  to   = module.addons.helm_release.kube_prometheus_stack
}

moved {
  from = helm_release.argocd
  to   = module.addons.helm_release.argocd
}

moved {
  from = helm_release.medicojobs_argocd_app
  to   = module.addons.helm_release.medicojobs_argocd_app
}

moved {
  from = helm_release.cloudwatch_observability
  to   = module.addons.helm_release.cloudwatch_observability
}
