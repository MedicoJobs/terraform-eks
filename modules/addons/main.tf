data "tls_certificate" "eks_oidc" {
  url = var.oidc_issuer_url
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint]
  url             = var.oidc_issuer_url

  tags = merge(var.common_tags, {
    Name = "${var.cluster_name}-oidc"
  })
}

locals {
  oidc_provider_host = replace(var.oidc_issuer_url, "https://", "")
}

data "aws_iam_policy_document" "irsa_assume_role" {
  for_each = {
    aws_load_balancer_controller = "kube-system:aws-load-balancer-controller"
    external_dns                 = "external-dns:external-dns"
    cloudwatch_agent             = "amazon-cloudwatch:cloudwatch-agent"
    external_secrets             = "external-secrets:external-secrets"
  }

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider_host}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider_host}:sub"
      values   = ["system:serviceaccount:${each.value}"]
    }
  }
}

resource "aws_iam_role" "aws_load_balancer_controller" {
  name               = "${var.cluster_name}-alb-controller-irsa"
  assume_role_policy = data.aws_iam_policy_document.irsa_assume_role["aws_load_balancer_controller"].json
  tags               = var.common_tags
}

resource "aws_iam_policy" "aws_load_balancer_controller" {
  #tfsec:ignore:aws-iam-no-policy-wildcards
  name        = "${var.cluster_name}-alb-controller-policy"
  description = "Permissions for AWS Load Balancer Controller."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iam:CreateServiceLinkedRole",
          "ec2:DescribeAccountAttributes",
          "ec2:DescribeAddresses",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeCoipPools",
          "ec2:DescribeInstances",
          "ec2:DescribeInternetGateways",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeTags",
          "ec2:DescribeVpcs",
          "ec2:DescribeVpcPeeringConnections",
          "ec2:GetCoipPoolUsage",
          "ec2:GetSecurityGroupsForVpc",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeLoadBalancerAttributes",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:DescribeListenerAttributes",
          "elasticloadbalancing:DescribeListenerCertificates",
          "elasticloadbalancing:DescribeSSLPolicies",
          "elasticloadbalancing:DescribeRules",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeTargetGroupAttributes",
          "elasticloadbalancing:DescribeTargetHealth",
          "elasticloadbalancing:DescribeTags",
          "cognito-idp:DescribeUserPoolClient",
          "acm:ListCertificates",
          "acm:DescribeCertificate",
          "iam:ListServerCertificates",
          "iam:GetServerCertificate",
          "waf-regional:GetWebACL",
          "waf-regional:GetWebACLForResource",
          "waf-regional:AssociateWebACL",
          "waf-regional:DisassociateWebACL",
          "wafv2:GetWebACL",
          "wafv2:GetWebACLForResource",
          "wafv2:AssociateWebACL",
          "wafv2:DisassociateWebACL",
          "shield:GetSubscriptionState",
          "shield:DescribeProtection",
          "shield:CreateProtection",
          "shield:DeleteProtection"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:CreateSecurityGroup",
          "ec2:CreateTags",
          "ec2:DeleteTags",
          "ec2:DeleteSecurityGroup",
          "elasticloadbalancing:CreateLoadBalancer",
          "elasticloadbalancing:CreateTargetGroup",
          "elasticloadbalancing:CreateListener",
          "elasticloadbalancing:DeleteListener",
          "elasticloadbalancing:CreateRule",
          "elasticloadbalancing:DeleteRule",
          "elasticloadbalancing:AddTags",
          "elasticloadbalancing:RemoveTags",
          "elasticloadbalancing:ModifyLoadBalancerAttributes",
          "elasticloadbalancing:SetIpAddressType",
          "elasticloadbalancing:SetSecurityGroups",
          "elasticloadbalancing:SetSubnets",
          "elasticloadbalancing:DeleteLoadBalancer",
          "elasticloadbalancing:ModifyTargetGroup",
          "elasticloadbalancing:ModifyTargetGroupAttributes",
          "elasticloadbalancing:DeleteTargetGroup",
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:DeregisterTargets",
          "elasticloadbalancing:SetWebAcl",
          "elasticloadbalancing:ModifyListener",
          "elasticloadbalancing:AddListenerCertificates",
          "elasticloadbalancing:RemoveListenerCertificates",
          "elasticloadbalancing:ModifyRule"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller" {
  role       = aws_iam_role.aws_load_balancer_controller.name
  policy_arn = aws_iam_policy.aws_load_balancer_controller.arn
}

resource "aws_iam_role" "external_dns" {
  name               = "${var.cluster_name}-external-dns-irsa"
  assume_role_policy = data.aws_iam_policy_document.irsa_assume_role["external_dns"].json
  tags               = var.common_tags
}

resource "aws_iam_policy" "external_dns" {
  name        = "${var.cluster_name}-external-dns-policy"
  description = "Permissions for ExternalDNS to manage Route53 records."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "route53:ChangeResourceRecordSets"
        ]
        Resource = var.hosted_zone_id != "" ? "arn:aws:route53:::hostedzone/${var.hosted_zone_id}" : "*"
      },
      {
        Effect = "Allow"
        Action = [
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets",
          "route53:ListTagsForResource"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "external_dns" {
  role       = aws_iam_role.external_dns.name
  policy_arn = aws_iam_policy.external_dns.arn
}

resource "aws_iam_role" "cloudwatch_agent" {
  name               = "${var.cluster_name}-cloudwatch-agent-irsa"
  assume_role_policy = data.aws_iam_policy_document.irsa_assume_role["cloudwatch_agent"].json
  tags               = var.common_tags
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = aws_iam_role.cloudwatch_agent.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.11.0"

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "region"
    value = var.aws_region
  }

  set {
    name  = "vpcId"
    value = var.vpc_id
  }

  set {
    name  = "enableGatewayAPI"
    value = "true"
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.aws_load_balancer_controller.arn
  }

  depends_on = [

    aws_iam_role_policy_attachment.aws_load_balancer_controller
  ]
}

resource "helm_release" "external_dns" {
  name             = "external-dns"
  namespace        = "external-dns"
  create_namespace = true
  repository       = "https://kubernetes-sigs.github.io/external-dns/"
  chart            = "external-dns"
  version          = "1.15.0"

  set {
    name  = "provider.name"
    value = "aws"
  }

  set {
    name  = "policy"
    value = "sync"
  }

  set {
    name  = "registry"
    value = "txt"
  }

  set {
    name  = "txtOwnerId"
    value = var.cluster_name
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.external_dns.arn
  }

  dynamic "set" {
    for_each = var.domain_name != "" ? [var.domain_name] : []
    content {
      name  = "domainFilters[0]"
      value = replace(set.value, "/^[^.]+\\./", "")
    }
  }

  depends_on = [
    helm_release.aws_load_balancer_controller,
    aws_iam_role_policy_attachment.external_dns
  ]
}

resource "helm_release" "metrics_server" {
  name             = "metrics-server"
  namespace        = "kube-system"
  repository       = "https://kubernetes-sigs.github.io/metrics-server/"
  chart            = "metrics-server"
  version          = "3.12.2"
  create_namespace = false

  depends_on = []
}

resource "helm_release" "kube_prometheus_stack" {
  name             = "kube-prometheus-stack"
  namespace        = "monitoring"
  create_namespace = true
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  version          = "66.3.1"
  values = [
    yamlencode({
      grafana = {
        adminPassword = "PaviSam@2003"
        service = {
          type = "ClusterIP"
        }
        ingress = {
          enabled          = true
          ingressClassName = "alb"
          annotations = {
            "alb.ingress.kubernetes.io/group.name"      = "medicojobs"
            "alb.ingress.kubernetes.io/scheme"          = "internet-facing"
            "alb.ingress.kubernetes.io/target-type"     = "ip"
            "external-dns.alpha.kubernetes.io/hostname" = "grafana.medicojobs.online"
          }
          hosts    = ["grafana.medicojobs.online"]
          paths    = ["/"]
          pathType = "Prefix"
        }
      }
      prometheus = {
        prometheusSpec = {
          retention = "15d"
          resources = {
            requests = {
              cpu    = "200m"
              memory = "512Mi"
            }
            limits = {
              cpu    = "1000m"
              memory = "2Gi"
            }
          }
        }
      }
    })
  ]

  depends_on = []
}

resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = "argocd"
  create_namespace = true
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "7.7.16"
  values = [
    yamlencode({
      server = {
        service = {
          type = "ClusterIP"
        }
      }
      configs = {
        params = {
          "server.insecure" = true
        }
      }
    })
  ]

  depends_on = []
}

resource "helm_release" "medicojobs_argocd_app" {
  name      = "medicojobs-argocd-app"
  namespace = "argocd"
  chart     = "${path.root}/charts/argocd-app"

  set {
    name  = "repoURL"
    value = var.argocd_git_repo_url
  }

  set {
    name  = "targetRevision"
    value = var.argocd_git_revision
  }

  set {
    name  = "path"
    value = var.argocd_app_path
  }

  set {
    name  = "destinationNamespace"
    value = "medicojobs"
  }

  depends_on = [helm_release.argocd]
}

resource "helm_release" "cloudwatch_observability" {
  name             = "amazon-cloudwatch-observability"
  namespace        = "amazon-cloudwatch"
  create_namespace = true
  repository       = "https://aws-observability.github.io/helm-charts"
  chart            = "amazon-cloudwatch-observability"
  version          = "3.3.0"

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "region"
    value = var.aws_region
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.cloudwatch_agent.arn
  }

  depends_on = [
    aws_iam_role_policy_attachment.cloudwatch_agent,
    helm_release.aws_load_balancer_controller
  ]
}

locals {
  workload_irsa_enabled = length(var.workload_service_account_names) > 0
}

data "aws_iam_policy_document" "workload_assume_role" {
  count = local.workload_irsa_enabled ? 1 : 0

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider_host}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider_host}:sub"
      values = [
        for service_account_name in var.workload_service_account_names :
        "system:serviceaccount:${var.workload_namespace}:${service_account_name}"
      ]
    }
  }
}

resource "aws_iam_role" "workload" {
  count = local.workload_irsa_enabled ? 1 : 0

  name               = "${var.cluster_name}-workload-irsa"
  assume_role_policy = data.aws_iam_policy_document.workload_assume_role[0].json
  tags               = var.common_tags
}

resource "aws_iam_role_policy_attachment" "workload_data_access" {
  count = local.workload_irsa_enabled ? 1 : 0

  role       = aws_iam_role.workload[0].name
  policy_arn = var.workload_data_access_policy_arn
}

resource "null_resource" "cleanup_ingress" {
  triggers = {
    cluster_name = var.cluster_name
  }

  provisioner "local-exec" {
    when    = destroy
    command = "aws eks update-kubeconfig --name ${self.triggers.cluster_name} --region ap-south-1 && kubectl delete ingress --all --all-namespaces --ignore-not-found=true || true"
  }

  depends_on = [
    helm_release.aws_load_balancer_controller
  ]
}