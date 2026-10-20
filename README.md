# learn-Terraform

Terraform をローカル環境だけで学ぶための個人学習リポジトリ。
クラウドのアカウントを使わず、ローカルで完結するプロバイダから順に「本物のインフラ」へ近づけていく。

## 前提

| ツール          | 用途             | 確認コマンド         |
| --------------- | ---------------- | -------------------- |
| Terraform 1.16+ | 本体             | `terraform -version` |
| Docker Desktop  | `02-` 以降の演習 | `docker version`     |

Terraform は Homebrew 本体ではなく HashiCorp の tap から入れる（本体の formula は BSL 化前の 1.5.x で止まっているため）。

```sh
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

## ディレクトリ構成

```
.
├── exercises/              # 演習。1 ディレクトリ = 1 つの独立した Terraform ルートモジュール
│   ├── 01-local-basics/    # local / random プロバイダで基本操作と state を学ぶ（Docker 不要）
│   └── 02-docker-nginx/    # Docker プロバイダで nginx コンテナを立てる（公式 Get Started 相当）
└── notes/                  # 学習メモ
```

各演習ディレクトリは独立しているので、ディレクトリに `cd` してから `terraform` コマンドを実行する。
演習ごとの手順と課題は、各ディレクトリの `README.md` に書いてある。

## 基本の流れ

```sh
cd exercises/01-local-basics
terraform init      # プロバイダをダウンロードする（初回とプロバイダ変更時）
terraform fmt       # コードを整形する
terraform validate  # 構文をチェックする
terraform plan      # 何が変わるかを確認する
terraform apply     # 反映する
terraform destroy   # 片付ける
```

## 演習ロードマップ

- [x] `01-local-basics`: init / plan / apply / destroy、variable / output / locals、依存関係、state
- [x] `02-docker-nginx`: Docker コンテナの作成・変更、ドリフト検知
- [ ] `03-`: `count` / `for_each`、`lifecycle`
- [ ] `04-`: モジュール化
- [ ] `05-`: `terraform import` と state 操作（`state list` / `state mv` / `state rm`）
- [ ] `06-`: LocalStack で AWS を疑似体験（S3 / DynamoDB、リモート state backend）

新しい演習を足すときは `exercises/NN-<topic>/` を作り、`main.tf` と `README.md` を置く。

## 参考リンク（公式）

- [Install Terraform](https://developer.hashicorp.com/terraform/install)
- [Get Started - Docker](https://developer.hashicorp.com/terraform/tutorials/docker-get-started)
- [Tutorials 一覧](https://developer.hashicorp.com/terraform/tutorials)
- [Terraform ドキュメント](https://developer.hashicorp.com/terraform/docs)
- [Terraform Registry](https://registry.terraform.io/)
