# MedicoJobs Production EKS Deployment

This folder provisions MedicoJobs on Amazon EKS using Terraform, Helm, and Argo CD GitOps.

See [ARCHITECTURE.md](ARCHITECTURE.md) for the Route 53 -> CloudFront -> WAF -> ALB -> EKS request flow.

## Structure

```text
terraform-eks/
  main.tf
  provider.tf
  variables.tf
  output.tf
  moved.tf
  modules/
    acm/
    addons/
    ecr/
    eks/
    route53/
    vpc/
    subnets/
    internet-gateway/
    nat-gateway/
    route-tables/
  charts/
    argocd-app/        # Terraform-installed bootstrap Argo CD Application
  helm/
    app-of-apps/       # Root Argo CD app-of-apps chart
    apps/
      platform/        # Namespace, ConfigMap, ALB Ingress, HPA, PDB
      api-gateway/
      frontend/
      user-service/
      job-service/
      matching-service/
      availability-service/
      location-service/
      reputation-service/
      course-service/
      resume-service/
  scripts/
    push-all-images.ps1
```

## What Terraform Creates

- VPC, public/private subnets, NAT, route tables
- EKS cluster and managed node group
- ECR repositories
- Optional Route53/ACM
- AWS Load Balancer Controller, ExternalDNS, metrics-server, monitoring, Argo CD, CloudWatch, EBS CSI
- Argo CD bootstrap Application pointing to `app-of-apps`

## GitOps Model

Terraform installs only the bootstrap Application from `charts/argocd-app`.
That Application syncs the Helm chart at:

```text
app-of-apps
```

The app-of-apps chart creates one child Argo CD Application for each folder under:

```text
apps/<service-name>
```

Each microservice owns its own Helm values file, for example:

```text
apps/frontend/values.yaml
apps/api-gateway/values.yaml
apps/resume-service/values.yaml
```

CI updates `.image.repository` and `.image.tag` inside the matching service `values.yaml` after Docker build, Trivy scan, and ECR push pass.

## Configure Variables

In `terraform.tfvars`:

```hcl
argocd_git_repo_url = "https://github.com/MedicoJobs/Helm.git"
argocd_git_revision = "main"
argocd_app_path     = "app-of-apps"

domain_name         = "medicojobs.online"
route53_zone_name   = "medicojobs.online"
```

SonarCloud is used from GitHub Actions, so Terraform does not install a SonarQube server by default:

```hcl
sonarqube_enabled = false
```

## Apply

```powershell
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

Configure kubectl:

```powershell
aws eks update-kubeconfig --region ap-south-1 --name medicojobs-cluster
kubectl get nodes
```

## Verify Argo CD

```powershell
kubectl get pods -n argocd
kubectl get applications -n argocd
kubectl describe application medicojobs -n argocd
```

The expected child Applications are:

```text
medicojobs-platform
medicojobs-api-gateway
medicojobs-frontend
medicojobs-user-service
medicojobs-job-service
medicojobs-matching-service
medicojobs-availability-service
medicojobs-location-service
medicojobs-reputation-service
medicojobs-course-service
medicojobs-resume-service
```

## Verify Application

```powershell
kubectl get all -n medicojobs-prod
kubectl get ingress -n medicojobs-prod
kubectl get hpa,pdb -n medicojobs-prod
kubectl describe ingress medicojobs-alb -n medicojobs-prod
```

## Image Updates

Update a service image manually by editing its Helm values file:

```yaml
image:
  repository: 168614391879.dkr.ecr.ap-south-1.amazonaws.com/medicojob-frontend
  tag: <commit-sha>
```

Then commit and push. Argo CD will sync the change.

## Secrets

The Helm charts expect an optional Kubernetes Secret named:

```text
medicojobs-secrets
```

Create it out-of-band or manage it with AWS Secrets Manager plus External Secrets Operator. Do not commit raw production secrets.

## Troubleshooting

Argo CD sync:

```powershell
kubectl describe application medicojobs -n argocd
kubectl logs -n argocd deploy/argocd-application-controller
```

Pods:

```powershell
kubectl describe pod <pod-name> -n medicojobs-prod
kubectl logs <pod-name> -n medicojobs-prod
```

Image pull errors:

```powershell
kubectl describe pod <pod-name> -n medicojobs-prod
aws ecr describe-images --repository-name medicojob-frontend --region ap-south-1
```

Terraform fails with `explicit deny in a service control policy`:

This is an AWS Organizations permission guardrail, not a Terraform syntax error. An explicit deny in an SCP overrides IAM user, role, and AdministratorAccess permissions. The Terraform principal must be allowed by the SCP attached to the AWS account or OU before `terraform plan` or `terraform apply` can refresh resources.

For this stack, the SCP must allow at least read/describe access for services Terraform manages, including:

```text
ecr:DescribeRepositories
iam:GetOpenIDConnectProvider
ec2:DescribeAddresses
ec2:DescribeVpcs
route53:GetHostedZone
kms:DescribeKey
```

To apply infrastructure changes, also allow the corresponding create/update/delete actions used by the modules in this folder. If the deny is intentional, run Terraform from an account, OU, or assumed role that is outside that deny policy.

ALB/DNS:

```powershell
kubectl describe ingress medicojobs-alb -n medicojobs-prod
kubectl logs -n kube-system deploy/aws-load-balancer-controller
kubectl logs -n external-dns deploy/external-dns
```


