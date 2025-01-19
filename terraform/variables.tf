# Set in deploy time according to the previously created aws resources

variable "http_api_id" {
  type = string
  description = "API Gateway Http-API"
}

variable "cognito_user_pool_client_id" {
  type = string
}

variable "cognito_user_pool_client_secret" {
  type = string
}

# export TF_VAR_load_balancer_pagamento_arn="....."
# variable "load_balancer_pagamento_arn" {
#   type = string
#   description = "ARN of the load balancer listener (8090) created for the EKS cluster - Serviço de Pagamentos"
# }
#
# variable "load_balancer_pedidos_arn" {
#   type = string
#   description = "ARN of the load balancer listener (8091) created for the EKS cluster - Serviço de Pedidos"
# }
#
# variable "load_balancer_catalogo_arn" {
#   type = string
#   description = "ARN of the load balancer listener (8092) created for the EKS cluster - Serviço de Catalogo"
# }
