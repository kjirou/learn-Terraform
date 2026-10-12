# 02-docker-nginx

Docker プロバイダで nginx コンテナを作る。公式チュートリアル [Get Started - Docker](https://developer.hashicorp.com/terraform/tutorials/docker-get-started) の内容に相当する。

## 前提

Docker Desktop を起動しておく。

```sh
open -a Docker
docker version
```

## 手順

```sh
cd exercises/02-docker-nginx
terraform init
terraform apply
open "$(terraform output -raw url)"
docker ps
terraform destroy
```

## 課題

1. **変更**: `terraform apply -var="external_port=8080"` を実行する。plan の `-/+`（作り直し）と `~`（その場で更新）の違いを確認する。
2. **ドリフト**: `docker rm -f learn-terraform-nginx` でコンテナを手で消してから `plan` する。
3. **依存関係**: `terraform graph` の出力を見て、image → container の依存を確認する。
4. **イメージを固定する**: `nginx:latest` をバージョン付きのタグ（例: `nginx:1.29`）に変えて `plan` する。
5. **output**: コンテナ名を返す output を追加する。
