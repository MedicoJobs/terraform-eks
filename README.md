# MedicoJobs Production EKS Deployment

This folder provisions and deploys MedicoJobs on Amazon EKS using Terraform, Helm, Kubernetes manifests, and ArgoCD GitOps.

## Architecture

Traffic flow:

```text
User
  -> Route53
  -> AWS Application Load Balancer
  -> Kubernetes Gateway API / ALB Ingress
  -> ClusterIP Service
  -> Application Pods
  -> Backend Services
  -> Database / Cache / External Services
```

## Terraform Structure

```text
terraform-eks/
  main.tf
  provider.tf
  variables.tf
  output.tf
  acm.tf
  addons.tf
  argocd_application.tf
  moved.tf
  modules/
    vpc/
    subnets/
    internet-gateway/
    nat-gateway/
    route-tables/
    eks/
    ecr/
  charts/
    argocd-app/
  k8s/
    base/
    overlays/prod/
    argocd/
  scripts/
    push-all-images.ps1
```

## What Terraform Creates

- VPC, public subnets, private subnets
- Internet Gateway, NAT Gateway, route tables
- Amazon EKS cluster
- Managed node group with 2 worker nodes
- ECR repositories
- Optional ACM certificate and DNS validation
- IAM OIDC provider for IRSA
- IRSA roles for:
  - AWS Load Balancer Controller
  - ExternalDNS
  - CloudWatch agent
- Helm add-ons:
  - AWS Load Balancer Controller
  - metrics-server
  - kube-prometheus-stack
  - Grafana
  - ArgoCD
  - ExternalDNS
  - CloudWatch Observability / Container Insights

## Kubernetes Manifests

The app manifests are in:

```text
k8s/base
k8s/overlays/prod
```

They include:

- Namespace
- ConfigMap
- Secret example
- Deployments
- ClusterIP Services
- Horizontal Pod Autoscalers
- Pod Disruption Budgets
- ALB Ingress
- GatewayClass
- Gateway
- HTTPRoute
- ArgoCD Application

## Important Before Apply

If Terraform shows destroy/create after module refactoring, do not approve it blindly. This repo includes `moved.tf` to map old resource addresses into the new module structure. Run:

```powershell
terraform plan
```

Check that existing resources are shown as moved or updated, not destroyed and recreated.

## Configure Variables

```powershell
cd terraform-eks
Copy-Item terraform.tfvars.example terraform.tfvars
```

Edit:

```hcl
domain_name         = "medicojobs.example.com"
hosted_zone_id      = "YOUR_ROUTE53_ZONE_ID"
acm_certificate_arn = "YOUR_ACM_CERTIFICATE_ARN"

argocd_git_repo_url = "https://github.com/your-org/medicojobs.git"
argocd_git_revision = "main"
argocd_app_path     = "terraform-eks/k8s/overlays/prod"
```

If you want Terraform to create the ACM certificate:

```hcl
create_acm_certificate = true
domain_name            = "medicojobs.example.com"
hosted_zone_id         = "YOUR_ROUTE53_ZONE_ID"
acm_certificate_arn    = ""
```

## Provision Infrastructure

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

## Push Images to ECR

Docker must be installed and running.

```powershell
cd terraform-eks
.\scripts\push-all-images.ps1 -Region ap-south-1 -Tag latest -FrontendApiUrl "https://medicojobs.example.com"
```

## Configure Application Images

Edit `k8s/overlays/prod/kustomization.yaml` and replace:

```text
123456789012.dkr.ecr.ap-south-1.amazonaws.com
```

with your real AWS account ECR registry.

Update:

```yaml
newTag: latest
```

to a versioned tag such as:

```yaml
newTag: v1.0.0
```

## Configure Secrets

Create the real secret from the example:

```powershell
Copy-Item k8s/base/secret.example.yaml k8s/overlays/prod/secret.yaml
```

Replace all `replace-me` values. For production, prefer AWS Secrets Manager plus External Secrets Operator instead of committing raw secrets.

If you add `secret.yaml`, include it in `k8s/overlays/prod/kustomization.yaml`.

## Deploy with ArgoCD

Terraform installs ArgoCD and creates the ArgoCD Application automatically from `argocd_application.tf`.

Check sync:

```powershell
kubectl get pods -n argocd
kubectl get applications -n argocd
kubectl describe application medicojobs -n argocd
```

Get initial ArgoCD admin password:

```powershell
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | %{ [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($_)) }
```

Port-forward ArgoCD UI:

```powershell
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

## Verify Application

```powershell
kubectl get all -n medicojobs
kubectl get ingress -n medicojobs
kubectl get gateway,httproute -n medicojobs
kubectl get hpa -n medicojobs
kubectl get pdb -n medicojobs
```

Check ALB:

```powershell
kubectl describe ingress medicojobs-alb -n medicojobs
```

Check ExternalDNS:

```powershell
kubectl logs -n external-dns deploy/external-dns
```

Check AWS Load Balancer Controller:

```powershell
kubectl logs -n kube-system deploy/aws-load-balancer-controller
```

## Observability

Prometheus and Grafana:

```powershell
kubectl get pods -n monitoring
kubectl port-forward svc/kube-prometheus-stack-grafana -n monitoring 3000:80
```

CloudWatch Container Insights:

```powershell
kubectl get pods -n amazon-cloudwatch
```

Then open CloudWatch Logs and Container Insights in AWS Console.

## Rollback

Rollback a Kubernetes deployment:

```powershell
kubectl rollout history deployment/api-gateway -n medicojobs
kubectl rollout undo deployment/api-gateway -n medicojobs
```

Rollback with GitOps:

```powershell
git revert <bad-commit>
git push
```

ArgoCD will sync the previous known-good manifests.

Rollback image tag:

```powershell
kubectl set image deployment/api-gateway api-gateway=<ecr-url>/medicojob-api-gateway:v1.0.0 -n medicojobs
```

For GitOps production, commit the tag rollback in `k8s/overlays/prod/kustomization.yaml`.

## Troubleshooting

Terraform wants to destroy/recreate resources:

```powershell
terraform state list
terraform plan
```

Make sure `moved.tf` is present. Do not approve destructive plans unless intended.

Pods not starting:

```powershell
kubectl describe pod <pod-name> -n medicojobs
kubectl logs <pod-name> -n medicojobs
```

Image pull errors:

```powershell
kubectl describe pod <pod-name> -n medicojobs
aws ecr describe-repositories --region ap-south-1
```

ALB not created:

```powershell
kubectl describe ingress medicojobs-alb -n medicojobs
kubectl logs -n kube-system deploy/aws-load-balancer-controller
```

DNS not created:

```powershell
kubectl logs -n external-dns deploy/external-dns
aws route53 list-resource-record-sets --hosted-zone-id YOUR_ZONE_ID
```

HPA not working:

```powershell
kubectl top pods -n medicojobs
kubectl get apiservice v1beta1.metrics.k8s.io
```

ArgoCD not syncing:

```powershell
kubectl describe application medicojobs -n argocd
kubectl logs -n argocd deploy/argocd-application-controller
```

## Production Notes

- Use versioned image tags, not `latest`, after initial testing.
- Store secrets in AWS Secrets Manager or External Secrets Operator.
- Keep worker nodes in private subnets.
- Keep app Services as ClusterIP.
- Terminate TLS at ALB using ACM.
- Use HTTPS redirect at ALB/Gateway.
- Use ArgoCD as the source of truth after bootstrap.
- Review IAM policies before production compliance review.
