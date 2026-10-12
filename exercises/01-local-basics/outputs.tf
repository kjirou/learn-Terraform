output "pet_name" {
  description = "生成された名前"
  value       = random_pet.name.id
}

output "file_path" {
  description = "作成したファイルのパス"
  value       = local_file.hello.filename
}
