terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket"
    key            = "lesson-8-9/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
