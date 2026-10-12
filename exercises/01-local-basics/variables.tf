variable "pet_length" {
  description = "random_pet の名前を構成する単語数"
  type        = number
  default     = 2

  validation {
    condition     = var.pet_length >= 1 && var.pet_length <= 5
    error_message = "pet_length は 1 から 5 の範囲で指定してください。"
  }
}
