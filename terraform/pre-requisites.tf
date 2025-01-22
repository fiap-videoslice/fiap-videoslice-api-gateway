
data "aws_iam_role" "awsacademy-role" {
  name = "LabRole"
}

# data "aws_vpc" "app-vpc" {
#   cidr_block = "10.0.0.0/16"
# }
#
# data "aws_subnet" "app-subnet-1" {
#   cidr_block = "10.0.1.0/24"
# }
# data "aws_subnet" "app-subnet-2" {
#   cidr_block = "10.0.2.0/24"
# }
# data "aws_subnet" "app-subnet-3" {
#   cidr_block = "10.0.3.0/24"
# }
#
data "aws_apigatewayv2_api" "http-api" {
  api_id = var.http_api_id
}
