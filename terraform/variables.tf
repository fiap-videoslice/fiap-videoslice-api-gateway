# Set in deploy time according to the previously created aws resources

variable "cognito_user_pool_client_id" {
  type = string
}

variable "cognito_user_pool_client_secret" {
  type = string
}

# export TF_VAR_load_balancer_pagamento_arn="....."
variable "load_balancer_web_api_arn" {
  type = string
  description = "ARN of the load balancer listener (8090) created for the EKS cluster - WebAPI service"
}

variable "load_balancer_engine_arn" {
  type = string
  description = "ARN of the load balancer listener (8091) created for the EKS cluster - Engine Service"
}
