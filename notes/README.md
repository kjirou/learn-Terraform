# notes

- 学習メモを置く場所。最終的にはトピックごとに 1 ファイル（例: `state.md`、`modules.md`）で書いていく。
- 最初は未整理状態で良いので、ここに雑なメモの形で記述する

## terraform コマンドを実行するカレントディレクトリ

- カレントディレクトリ = 1つの独立した Terraform プロジェクト、正式には、このディレクトリをルートモジュールと呼ぶ
- カレントディレクトリで決まるもの
  - 読み込む .tf ファイル
    - カレントディレクトリ直下の *.tf すべて（サブディレクトリは読まない）
    - サブディレクトリのコードを使いたいときは、module ブロックで明示的に呼び出す
  - state ファイルは、 ./terraform.tfstate へ読み書きする
  - プロバイダ置き場は、 ./.terraform/ 、 init で作られる
  - ロックファイルは、 ./.terraform.lock.hcl
  -  自動で読み込む変数ファイルは、 ./terraform.tfvars、./*.auto.tfvars
  - 相対パスの基準
    - `-var-file=dev.tfvars` などは、カレントディレクトリから探す
-  cd せずに実行する: -chdir
  - 指定したディレクトリに cd したのと同じ扱いになる
  - 例: `terraform -chdir=exercises/01-local-basics plan`

## .tf やコードに読み込み順序はない

- 要点: 順序が意味を持たない2つのレベル
  - ファイル間の順序に意味はない
    - ディレクトリ内の *.tf は、すべて合体して1つの設定として扱われる
  - ファイル内のブロックの順序にも意味はない
    - 後ろに書いたものや、別のファイルに書いたものも、そのまま参照できる
- 思想
  - Terraform は宣言型の言語。 「上から順に実行する手順書」ではなく、「最終的にあるべき姿」の記述で決まる。
  - 実行順は、コード中の参照関係（と depends_on）から作られる依存グラフで決まる
- 補足
  - 同じアドレスを2回定義するとエラーになる
  - 例外として override.tf と *_override.tf がある
    - これらは通常のファイルの後に適用されて、定義を上書きする。順序に意味がある、数少ない特殊なファイル。

## HCL と .tf の役割の違い

- 役割の違い
  - HCL = 構文とパーサー、ブロックの順序の解釈と保持はこれが行う。
  - Terraform = 「全 .tf を合体」「トップレベルの順序を無視」「依存グラフで実行順を決める」などの決め
    - 例外として、provisioner やリスト型のネストブロックは書いた順序に意味があ
- HCL を使った他ツールも存在する
  - Packer や Nomad など

## 用語

- configuration file
  - = .tf
  - Ref) https://developer.hashicorp.com/terraform/language/files#file-extension
    - > Files containing Terraform code are often called configuration files.
- HashiCorp Configuration Language
  - = HCL
- module（モジュール）
  - 1つのディレクトリにある .tf ファイルのまとまり
- root module（ルートモジュール）
  - terraform コマンドを実行するディレクトリのモジュール
- Terraform language
  - .tf を書く言語、HCL の構文をベースにしている

## Terraform が状態を把握する仕組み: コード・state・実物

###  Terraform は、 3 つのものを照らし合わせて状態を把握する

- 3つの登場人物
  - コード（.tf）
    - あるべき姿、「こうあってほしい」という宣言
    - 例: random_pet を length = 2 で
  - state（terraform.tfstate）
    - 「自分はこれを作って管理している」という Terraform の記憶
    - 例: random_pet.name = accepted-narwhal、local_file.hello = ID 2286ae...
  - 実物
    - 実際に存在しているもの
    - ディスク上の hello.txt
- state の役割
  - 最も重要な役割は、コード上のアドレス（local_file.hello）と実物（ID 2286ae... のファイル）を結び付けること
  - Terraform は、この対応表を通してしか実物を認識できない
    - state にない実物を管理下に入れるには、terraform import を使う

### plan の 2 段階の振る舞い

- A) refresh
  - state と実物の比較を行う。state に記録されたリソースを、プロバイダが1つずつ確認しに行く。
    - 出力の "Refreshing state..." の行
    - state に載っているものだけが対象、state にない実物は、確認すらされない
  - 実物が変わっていたら、Terraform の state の認識をメモリ内で更新する
    - この作用だけを記録したいなら `terraform apply -refresh-only`
- B) diff
  - コードと refresh で更新後の state の比較を行う
  - 差分を、作成 / 更新 / 作り直し / 削除 のアクションにする

### Core とプロバイダの役割

- Core（terraform コマンド本体） <-> プロバイダ <-> 実物、の間で接触する
- Core の仕事: state の管理、依存グラフの作成、差分計算、実行順の制御
- プロバイダ の仕事: 実物との通信。ファイルを読む、Docker API を呼ぶ、AWS API を呼ぶ、など
  - リソースごとに Create / Read / Update / Delete を実装している
  - 実物がない場合は state の値のみを参照して結果を返す

### よくあるパターンの例

- コード = state = 実物
  - No changes. が表示される
- コード ≠ state
  - \-/\+ で作り直し
  - 変数を更新した状況など
- state ≠ 実物
  - \+ create
  - refresh で検知 → 「存在しない」とみなされた
- state が空
  - 全部 \+ create、refresh なし
  - state が空なの → 実物があっても見えない

## path.module, path.root, path.cwd

- .tf の中で `"${path.module}/output/hello.txt"` のように使うパスの変数
- path.module
  - この .tf ファイルがあるディレクトリ
- path.root
- path.cmd
