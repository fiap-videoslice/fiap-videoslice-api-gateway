
###
resource "aws_security_group" "allow_app_port" {
  name        = "allow_app_port"
  description = "Allow Traffic to and from port 8090"
  vpc_id      = data.aws_vpc.app-vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_app_port_ingress" {
  security_group_id = aws_security_group.allow_app_port.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 8090
  to_port           = 8092
}

resource "aws_vpc_security_group_egress_rule" "allow_app_port_egress" {
  security_group_id = aws_security_group.allow_app_port.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 8090
  to_port           = 8092
}


resource "aws_apigatewayv2_vpc_link" "app-vpc-link" {
  name = "app-vpc-link"
  security_group_ids = [aws_security_group.allow_app_port.id]
  subnet_ids = [data.aws_subnet.app-subnet-1.id, data.aws_subnet.app-subnet-2.id, data.aws_subnet.app-subnet-3.id]
}


resource "aws_apigatewayv2_integration" "app-gateway-integration-web_api" {
  api_id           = aws_apigatewayv2_api.http-api.id
  credentials_arn     = data.aws_iam_role.awsacademy-role.arn
  description         = "App Proxy Integration - WEB API Service"

  integration_type    = "HTTP_PROXY"

  integration_uri = var.load_balancer_web_api_arn
  integration_method = "ANY"

  connection_type = "VPC_LINK"
  connection_id = aws_apigatewayv2_vpc_link.app-vpc-link.id

  request_parameters = {
    "overwrite:path" = "$request.path"
  }
}


resource "aws_apigatewayv2_route" "http-route-web_api" {
  api_id    = aws_apigatewayv2_api.http-api.id
  route_key = "ANY /jobs"

  target = "integrations/${aws_apigatewayv2_integration.app-gateway-integration-web_api.id}"
}
resource "aws_apigatewayv2_route" "http-route-web_api-subpath" {
  api_id    = aws_apigatewayv2_api.http-api.id
  route_key = "ANY /jobs/{subpath+}"

  target = "integrations/${aws_apigatewayv2_integration.app-gateway-integration-web_api.id}"
}

# resource "aws_apigatewayv2_route" "http-default-route-default" {
#   api_id    = aws_apigatewayv2_api.http-api.id
#   route_key = "$default"
#
#   authorization_type = "CUSTOM"
#   authorizer_id = aws_apigatewayv2_authorizer.cognito-authorizer.id
#
#   target = "integrations/${aws_apigatewayv2_integration.app-gateway-????.id}"
# }

