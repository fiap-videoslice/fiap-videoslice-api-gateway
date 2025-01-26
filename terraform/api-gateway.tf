
resource "aws_apigatewayv2_api" "http-api" {
  name          = "http-api"
  protocol_type = "HTTP"
}

output "http-api-url" {
  value = aws_apigatewayv2_api.http-api.api_endpoint
}


## API Deployment

resource "aws_cloudwatch_log_group" "api-gateway-log" {
  name              = "/aws/api-gw/http-api-default-stage"
  retention_in_days = 7
}

resource "aws_apigatewayv2_stage" "http-api-default-stage" {
  api_id      = aws_apigatewayv2_api.http-api.id
  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api-gateway-log.arn
    format = "$context.identity.sourceIp - - [$context.requestTime] \"$context.httpMethod $context.routeKey $context.protocol\" $context.status $context.responseLength $context.requestId AuthErr=[$context.authorizer.error] IntegrErr=[$context.integrationErrorMessage] GwErr=[$context.error.message] "
  }
}

output "service_url" {
  value = aws_apigatewayv2_stage.http-api-default-stage.invoke_url
}
