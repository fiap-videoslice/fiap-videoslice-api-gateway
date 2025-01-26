
#######################################################
## "Echo API" - Simple Lambda for testing the infra

data "archive_file" "sample-echo-function-code" {
  type        = "zip"
  source_file = "../authenticator/src/echo-function.js"
  output_path = "sample-hello-function_payload.zip"
}

resource "aws_lambda_function" "sample-echo-function" {
  function_name = "echo-function"
  filename      = "sample-hello-function_payload.zip"
  role          = data.aws_iam_role.awsacademy-role.arn
  handler       = "echo-function.handler"

  source_code_hash = data.archive_file.sample-echo-function-code.output_base64sha256

  runtime = "nodejs20.x"

  environment {
    variables = {
      foo = "bar"
    }
  }
}

resource "aws_apigatewayv2_integration" "http-echo-api-integration" {
  api_id           = aws_apigatewayv2_api.http-api.id
  integration_type = "AWS_PROXY"

  connection_type           = "INTERNET"
  description               = "Test Function Lambda integration"
  integration_method        = "POST"
  integration_uri           = aws_lambda_function.sample-echo-function.invoke_arn
  passthrough_behavior      = "WHEN_NO_MATCH"

  request_parameters = {
    "overwrite:path" = "$request.path"
  }
}

resource "aws_apigatewayv2_route" "http-echo-api-route" {
  api_id    = aws_apigatewayv2_api.http-api.id
  route_key = "ANY /echo"

  target = "integrations/${aws_apigatewayv2_integration.http-echo-api-integration.id}"
}

resource "aws_apigatewayv2_route" "http-echo-auth-api-route" {
  api_id    = aws_apigatewayv2_api.http-api.id
  route_key = "ANY /echo-auth"

  authorization_type = "CUSTOM"
  authorizer_id = aws_apigatewayv2_authorizer.cognito-authorizer.id

  target = "integrations/${aws_apigatewayv2_integration.http-echo-api-integration.id}"
}

resource "aws_lambda_permission" "exec-echo-lambda-permission" {
  statement_id  = "EchoFunctionAllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sample-echo-function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:us-east-1:${data.aws_caller_identity.current.account_id}:${aws_apigatewayv2_api.http-api.id}/*/*/echo"
}

resource "aws_lambda_permission" "exec-echo-auth-lambda-permission" {
  statement_id  = "EchoAuthFunctionAllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sample-echo-function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:us-east-1:${data.aws_caller_identity.current.account_id}:${aws_apigatewayv2_api.http-api.id}/*/*/echo-auth"
}
