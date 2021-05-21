resource "aws_api_gateway_rest_api" "api" { # <1>
  name = "Hello World API"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "proxy" { # <2>
  parent_id = aws_api_gateway_rest_api.api.root_resource_id
  path_part = "{proxy+}"
  rest_api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_method" "proxy" { # <3>
  authorization = "NONE"
  http_method = "ANY"
  resource_id = aws_api_gateway_resource.proxy.id
  rest_api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_integration" "proxy" { # <4>
  resource_id = aws_api_gateway_resource.proxy.id
  rest_api_id = aws_api_gateway_rest_api.api.id

  type = "AWS_PROXY"
  integration_http_method = "POST"
  uri = aws_lambda_function.function.invoke_arn
  http_method = "ANY"
}

resource "aws_api_gateway_deployment" "deployment" { # <5>
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name = "test"

  depends_on = [
    aws_api_gateway_integration.proxy
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lambda_permission" "apigw" { # <6>
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function.function_name
  principal     = "apigateway.amazonaws.com"

  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

output "invoke_url" { # <7>
  value = aws_api_gateway_deployment.deployment.invoke_url
}