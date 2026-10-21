terraform {
  required_version = ">= 1.6"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 4.6"
    }
  }
}

provider "docker" {}

# 02 と同じ nginx:latest を使う。keep_locally = true にして、destroy してもイメージは消さない
# （他の演習のコンテナが同じイメージを使っていると、削除に失敗するため）
resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = true
}

# count: 同じ設定のリソースを「個数」で複製する。各リソースは 0 始まりの番号（count.index）で区別される
resource "docker_container" "web" {
  count = length(var.web_names)

  image = docker_image.nginx.image_id
  name  = "learn-tf03-web-${var.web_names[count.index]}"

  ports {
    internal = 80
    external = var.web_base_port + count.index
  }
}

# for_each: map や set の要素ごとにリソースを作る。各リソースはキー（each.key）で区別される
resource "docker_container" "site" {
  for_each = var.sites

  image = docker_image.nginx.image_id
  name  = "learn-tf03-site-${each.key}"

  ports {
    internal = 80
    external = each.value
  }
}
