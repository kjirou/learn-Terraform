# 01-local-basics

`local` / `random` プロバイダだけを使い、Terraform の基本操作と state の役割を学ぶ。Docker もクラウドも不要。

## 作るもの

- `random_pet.name`: ランダムな名前（例: `happy-otter`）
- `local_file.hello`: その名前を使った `output/hello.txt`

## 手順

```sh
cd exercises/01-local-basics
terraform init
terraform plan
terraform apply
cat output/hello.txt
terraform output
terraform destroy
```

## 課題

手を動かしながら、各ステップで `plan` の結果と `terraform.tfstate` の中身を観察する。

1. **冪等性**: `apply` を 2 回続けて実行する。2 回目に何も変わらないのはなぜか？
2. **state を覗く**: `terraform state list` と `terraform state show random_pet.name` を実行する。`terraform.tfstate` も開いて見てみる。
3. **変数を変える**: `terraform apply -var="pet_length=3"` を実行する。`random_pet` だけでなく `local_file` も作り直されるのはなぜか？
4. **ドリフト**: `output/hello.txt` を手で編集するか削除してから `plan` する。Terraform はどう反応するか？
5. **state を失う**: `terraform.tfstate` を別名に退避してから `plan` する。実ファイルは残っているのに Terraform はどう判断するか？（確認後は元に戻す）
6. **バリデーション**: `-var="pet_length=10"` を渡すと何が起きるか？
7. **output を足す**: `local.greeting` を返す output を `outputs.tf` に追加する。
8. **tfvars**: `terraform.tfvars` に `pet_length = 4` と書いて `plan` する。（`.gitignore` 対象なので commit はされない）
