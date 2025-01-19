

## Authorization
resource "aws_apigatewayv2_authorizer" "cognito-authorizer" {
  api_id                            = data.aws_apigatewayv2_api.http-api.id
  authorizer_type                   = "REQUEST"
  authorizer_uri                    = aws_lambda_function.authorizer-function.invoke_arn
  identity_sources = []
  name                              = "cognito-authorizer"
  enable_simple_responses           = true
  authorizer_payload_format_version = "2.0"
}

resource "aws_lambda_permission" "exec-authorizer-lambda-permission" {
  statement_id  = "AuthorizationFunctionAllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.authorizer-function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:us-east-1:${data.aws_caller_identity.current.account_id}:${data.aws_apigatewayv2_api.http-api.id}/authorizers/${aws_apigatewayv2_authorizer.cognito-authorizer.id}"
}


