output "notebook_url" {
  value= var.deploy_notebook == "yes" ? "https://${var.name}.${var.ingress_domain}" : null
  #value="https://${var.name}.${var.ingress_domain}/lab?token=${random_string.token.result}"
}

output "token" {
  value="${local.token}"
}