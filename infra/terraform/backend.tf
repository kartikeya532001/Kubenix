terraform {
  backend "s3" {
    bucket         = "llmstatefiles"
    key            = "terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-lock"   # optional but recommended for state locking
    encrypt        = true
  }
}
