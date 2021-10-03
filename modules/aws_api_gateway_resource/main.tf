terraform {
  required_version = ">= 0.13"
}

resource "aws_api_gateway_resource" "resource" {
  parent_id = var.parent_id
  rest_api_id = var.rest_api_id
  path_part = var.path_part
}

resource "aws_api_gateway_method" "methods" {
  depends_on = [
    aws_api_gateway_resource.resource
  ]
  for_each = {
    for index, handler in var.handlers:
    index => handler
  }
  rest_api_id = var.rest_api_id
  resource_id = aws_api_gateway_resource.resource.id
  authorization = "NONE"
  http_method = each.value.method
}

resource "aws_api_gateway_integration" "integration" {
  depends_on = [
    aws_api_gateway_method.methods
  ]
  for_each = {
    for index, handler in var.handlers:
    index => handler
  }
  rest_api_id = var.rest_api_id
  resource_id = aws_api_gateway_resource.resource.id
  http_method = each.value.method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = each.value.lambda_invoke_arn
}