variable "web_names" {
  description = "count で作るコンテナの名前の一覧。順番に意味がある"
  type        = list(string)
  default     = ["a", "b", "c"]
}

variable "web_base_port" {
  description = "count で作るコンテナのポートの開始番号。web_names の順に 1 ずつ増える"
  type        = number
  default     = 8100
}

variable "sites" {
  description = "for_each で作るコンテナ。キーが名前、値がホスト側のポート"
  type        = map(number)
  default = {
    blue  = 8201
    green = 8202
  }
}
