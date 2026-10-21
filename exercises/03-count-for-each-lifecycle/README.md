# 03-count-for-each-lifecycle

`count` と `for_each` で同じ種類のリソースを複数作り、両者の違いを学ぶ。後半では `lifecycle` でリソースの作り直しや削除の振る舞いを変える。

## 作るもの

| アドレス                         | コンテナ名              | ポート |
| -------------------------------- | ----------------------- | ------ |
| `docker_container.web[0]`        | `learn-tf03-web-a`      | 8100   |
| `docker_container.web[1]`        | `learn-tf03-web-b`      | 8101   |
| `docker_container.web[2]`        | `learn-tf03-web-c`      | 8102   |
| `docker_container.site["blue"]`  | `learn-tf03-site-blue`  | 8201   |
| `docker_container.site["green"]` | `learn-tf03-site-green` | 8202   |

- `web` は `count` で、`var.web_names`（リスト）の要素数だけ作る。番号（`count.index`）で区別される
- `site` は `for_each` で、`var.sites`（map）のキーごとに作る。キー（`each.key`）で区別される
- `docker_image.nginx` は 02 と同じ `nginx:latest` を使う。`keep_locally = true` なので、destroy してもイメージは残る

## 前提

Docker Desktop を起動しておく。02 のコンテナ（ポート 8000）と同時に動かしても、名前とポートはぶつからない。

## ベースライン（各課題の始点）

```sh
cd exercises/03-count-for-each-lifecycle
terraform init
terraform apply
terraform plan     # No changes. を確認する
```

**課題を 1 つ終えるたびに、ベースラインに戻す**（`terraform plan` で `No changes.` を確認する）。

`-var` でリストや map を渡すときは、シェルが `[` や `{` を解釈しないように、全体をシングルクォートで囲む。

## 課題

### 1. アドレスを見る

```sh
terraform state list
terraform output
```

- `count` のリソースは `web[0]` のように番号、`for_each` のリソースは `site["blue"]` のようにキーがアドレスに付く
- `web_urls` はリスト、`site_urls` は map で出力される

`terraform console` で、次の式も評価してみる。

```
docker_container.web[0].name
docker_container.web[*].name
docker_container.site["blue"].name
keys(docker_container.site)
```

戻し方: 不要（見るだけ）

### 2. count の弱点: 先頭の要素を消す

```sh
terraform plan -var='web_names=["b","c"]'
```

`a` だけを消したつもりでも、どうなるかを観察する。

- `web[0]` の名前が `a -> b`、`web[1]` の名前が `b -> c` に変わり、両方とも作り直しになる
- `web[2]` は `because index [2] is out of range for count` で削除される
- 結果は `2 to add, 0 to change, 3 to destroy`。実質的に消えるのは `a` だけなのに、全部が作り直しになる

`count` はリソースを**番号で**管理しているので、途中の要素を消すと、それより後ろの番号がすべてずれる。

戻し方: 不要（plan だけ。apply しない）

### 3. for_each なら: 要素を消す

```sh
terraform plan -var='sites={green=8202}'
```

- `site["blue"]` だけが `because key ["blue"] is not in for_each map` で削除される
- `site["green"]` には何も起きない（`0 to add, 0 to change, 1 to destroy`）

`for_each` はリソースを**キーで**管理しているので、他の要素に影響しない。

戻し方: 不要（plan だけ。apply しない）

### 4. 末尾に追加する

```sh
terraform plan -var='web_names=["a","b","c","d"]'
terraform plan -var='sites={blue=8201,green=8202,red=8203}'
```

- どちらも、追加した 1 つだけが作成される（`web[3]`、`site["red"]`）
- `count` でも、**末尾への追加**なら番号はずれない。課題 2 との違いを考える

戻し方: 不要（plan だけ。apply しない）

### 5. lifecycle: prevent_destroy

`main.tf` の `docker_container.site` に、次のブロックを追加する。

```hcl
resource "docker_container" "site" {
  for_each = var.sites

  lifecycle {
    prevent_destroy = true
  }
  # ...
```

```sh
terraform plan                               # No changes. のまま
terraform plan -var='sites={green=8202}'     # blue を消そうとすると？
```

- 削除を伴う plan は `Error: Instance cannot be destroyed` で止まる
- 消してはいけないもの（実務ではデータベースなど）を守るための設定

戻し方: 追加した `lifecycle` ブロックを消す

### 6. lifecycle: ignore_changes

まず、Terraform の外から設定を変える（02 の課題 2 で試したドリフト）。

```sh
docker update --restart=always learn-tf03-web-a
terraform plan     # web[0] の restart を "always" -> "no" に戻そうとする
```

次に、`main.tf` の `docker_container.web` に、次のブロックを追加する。

```hcl
resource "docker_container" "web" {
  count = length(var.web_names)

  lifecycle {
    ignore_changes = [restart]
  }
  # ...
```

```sh
terraform plan     # No changes. になる
```

- `ignore_changes` に書いた属性は、実物とずれていても無視される
- Terraform の外で変更されることが前提の属性（実務では、自動で増減するサーバーの台数など）に使う

戻し方: 追加した `lifecycle` ブロックを消す → `docker update --restart=no learn-tf03-web-a`

### 7. lifecycle: create_before_destroy

`main.tf` の `docker_container.web` に、次のブロックを追加する。

```hcl
resource "docker_container" "web" {
  count = length(var.web_names)

  lifecycle {
    create_before_destroy = true
  }
  # ...
```

```sh
terraform plan  -var=web_base_port=8110
terraform apply -var=web_base_port=8110
```

- plan の記号が `-/+` ではなく `+/-`（先に作ってから消す）になる
- apply は `Conflict. The container name "/learn-tf03-web-a" is already in use` で失敗する。なぜか？
  - 古いコンテナを消す前に、同じ名前で新しいコンテナを作ろうとするため
  - `create_before_destroy` を使うときは、新旧が同時に存在できる（名前などがぶつからない）ようにする必要がある
- 失敗しても、古いコンテナは消されずに残っている（`docker ps` で確認する）

戻し方: 追加した `lifecycle` ブロックを消す → `terraform apply`（失敗した apply で output の値だけが更新されているので、元に戻す） → `terraform plan` で `No changes.`

## 片付け

```sh
terraform destroy
```

nginx イメージは `keep_locally = true` なので残る。
