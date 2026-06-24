resource "aws_sns_topic" "alerts" {
  name              = "${var.cluster_name}-alerts"
  kms_master_key_id = var.kms_key_arn

  tags = var.common_tags
}

resource "aws_sns_topic_subscription" "email" {
  for_each = toset(var.sns_email_endpoints)

  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = each.value
}

resource "aws_cloudwatch_log_group" "application" {
  name              = "/aws/eks/${var.cluster_name}/application"
  retention_in_days = 30
  kms_key_id        = var.kms_key_arn

  tags = var.common_tags
}

resource "aws_cloudwatch_dashboard" "platform" {
  dashboard_name = "${var.cluster_name}-platform"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          region = var.aws_region
          title  = "EKS Cluster Health"
          metrics = [
            ["ContainerInsights", "cluster_failed_node_count", "ClusterName", var.cluster_name],
            [".", "cluster_node_count", ".", "."]
          ]
        }
      },
      {
        type   = "log"
        x      = 0
        y      = 6
        width  = 24
        height = 6
        properties = {
          region = var.aws_region
          title  = "Application errors"
          query  = "SOURCE '${aws_cloudwatch_log_group.application.name}' | fields @timestamp, @message | filter @message like /ERROR|Error|error/ | sort @timestamp desc | limit 50"
        }
      }
    ]
  })
}

resource "aws_cloudwatch_metric_alarm" "eks_failed_requests" {
  alarm_name          = "${var.cluster_name}-eks-failed-nodes"
  alarm_description   = "EKS node failures detected."
  namespace           = "ContainerInsights"
  metric_name         = "cluster_failed_node_count"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    ClusterName = var.cluster_name
  }

  tags = var.common_tags
}
