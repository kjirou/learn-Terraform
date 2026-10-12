output "container_id" {
  description = "nginx コンテナの ID"
  value       = docker_container.nginx.id
}

output "url" {
  description = "ブラウザで開く URL"
  value       = "http://localhost:${var.external_port}"
}
