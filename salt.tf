data "archive_file" "salt" {
  type        = "zip"
  source_dir = "./salt"
  output_path = "${path.module}/.tmp/salt.zip"
}
