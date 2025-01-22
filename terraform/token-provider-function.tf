
#################################################
## Token provider lambda

data "archive_file" "token-function-code" {
  type        = "zip"
  source_file = "../authenticator/src/token-function.js"
  output_path = "token-function_payload.zip"
}

resource "aws_lambda_function" "token-function" {
  function_name = "token-function"
  filename      = "token-function_payload.zip"
  role          = data.aws_iam_role.awsacademy-role.arn
  handler       = "token-function.handler"

  source_code_hash = data.archive_file.token-function-code.output_base64sha256

  runtime = "nodejs20.x"
}

resource "aws_lambda_permission" "exec-token-lambda-permission" {
  statement_id  = "TokenFunctionAllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.token-function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:us-east-1:${data.aws_caller_identity.current.account_id}:${data.aws_apigatewayv2_api.http-api.id}/*/*/token"
}


# Route

resource "aws_apigatewayv2_integration" "http-token-integration" {
  api_id           = data.aws_apigatewayv2_api.http-api.id
  integration_type = "AWS_PROXY"

  connection_type           = "INTERNET"
  description               = "Return IdToken for user"
  integration_method        = "POST"
  integration_uri           = aws_lambda_function.token-function.invoke_arn
  passthrough_behavior      = "WHEN_NO_MATCH"
}

resource "aws_apigatewayv2_route" "http-token-api-route" {
  api_id    = data.aws_apigatewayv2_api.http-api.id
  route_key = "ANY /token"

  authorization_type = "CUSTOM"
  authorizer_id = aws_apigatewayv2_authorizer.cognito-authorizer.id

  target = "integrations/${aws_apigatewayv2_integration.http-token-integration.id}"
}
