terraform {
  backend "s3" {
    bucket         = "tf-aws-fullstack-tfstate-prod"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tf-aws-fullstack-locks"
    encrypt        = true
  }
}
