output "sonarqube_internal_url" {
  description = "Internal cluster URL when opt-in self-hosted SonarQube is enabled."
  value       = var.sonarqube_enabled ? "http://sonarqube-sonarqube.sonarqube.svc.cluster.local:9000" : ""
}

output "sonarqube_public_url" {
  description = "Public URL when opt-in self-hosted SonarQube is enabled and sonarqube_host_name is configured."
  value       = var.sonarqube_enabled && var.sonarqube_host_name != "" ? "https://${var.sonarqube_host_name}" : ""
}
