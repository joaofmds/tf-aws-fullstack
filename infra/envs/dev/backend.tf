terraform {
  backend "s3" {
    bucket         = "exampleorg-tf-aws-fullstack-731616607264-us-east-1-tfstate"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "exampleorg-tf-aws-fullstack-731616607264-us-east-1-tfstate-locks"
    encrypt        = true
    kms_key_id     = "arn:aws:kms:us-east-1:731616607264:key/836ed3ca-7b71-48ee-8348-0fbceef16cbe"
  }
}
