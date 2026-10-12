terraform {
  required_version = ">= 1.6"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

# ランダムな名前を生成する。一度作られると state に保存され、apply し直しても変わらない
resource "random_pet" "name" {
  length = var.pet_length
}

locals {
  greeting = "Hello, ${random_pet.name.id}!"
}

# random_pet.name を参照しているので、Terraform は random_pet → local_file の順に作る（暗黙の依存関係）
resource "local_file" "hello" {
  filename        = "${path.module}/output/hello.txt"
  content         = "${local.greeting}\n"
  file_permission = "0644"
}
