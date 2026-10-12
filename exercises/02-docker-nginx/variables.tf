variable "container_name" {
  description = "nginx コンテナの名前"
  type        = string
  default     = "learn-terraform-nginx"
}

variable "external_port" {
  description = "ホスト側に公開するポート"
  type        = number
  default     = 8000
}
