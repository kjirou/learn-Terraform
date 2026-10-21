output "web_urls" {
  description = "count で作ったコンテナの URL（リスト）"
  value       = [for c in docker_container.web : "http://localhost:${c.ports[0].external}"]
}

output "site_urls" {
  description = "for_each で作ったコンテナの URL（キーごとの map）"
  value       = { for key, c in docker_container.site : key => "http://localhost:${c.ports[0].external}" }
}
