# Remote backend will be enabled after the S3 bucket and DynamoDB table are created.
# The backend resources are defined in modules/s3-backend.
#
# terraform {
#   backend "s3" {
#     bucket         = "terraform-state-lesson-7-mykhailov-viacheslav-20260628"
#     key            = "lesson-7/terraform.tfstate"
#     region         = "us-west-2"
#     dynamodb_table = "terraform-locks-lesson-7"
#     encrypt        = true
#   }
# }