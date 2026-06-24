resource "aws_secretsmanager_secret" "shared" {
  name                    = "${var.cluster_name}/shared-secrets"
  description             = "Shared runtime secrets for all microservices."
  kms_key_id              = var.kms_key_arn
  recovery_window_in_days = 7

  tags = merge(var.common_tags, {
    Name = "${var.cluster_name}-shared-secrets"
  })
}