terraform {
  required_version = ">= 0.13"
}

resource "aws_api_gateway_resource" "resource" {
  parent_id = var.parent_id
  rest_api_id = var.rest_api_id
  path_part = var.path_part
}

/* Unauthorized methods and integration */
resource "aws_api_gateway_method" "unauthorized_methods" {
  depends_on = [
    aws_api_gateway_resource.resource
  ]
  for_each = {
    for index, handler in var.handlers:
    index => handler
  }
  rest_api_id = var.rest_api_id
  resource_id = aws_api_gateway_resource.resource.id
  api_key_required = each.value.api_key_required
  authorization = "NONE"
  http_method = each.value.method
}

resource "aws_api_gateway_integration" "unauthorized_methods_integration" {
  depends_on = [
    aws_api_gateway_method.unauthorized_methods
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
/* Unauthorized methods and integration */

/* Authorized methods and integration */
resource "aws_api_gateway_method" "authorized_methods" {
  depends_on = [
    aws_api_gateway_resource.resource
  ]
  for_each = {
    for index, handler in var.auth_handlers:
    index => handler
  }
  rest_api_id = var.rest_api_id
  resource_id = aws_api_gateway_resource.resource.id
  api_key_required = each.value.api_key_required
  authorization = each.value.authorization
  authorizer_id = each.value.authorizer_id
  http_method = each.value.method
}

resource "aws_api_gateway_integration" "authorized_methods_integration" {
  depends_on = [
    aws_api_gateway_method.authorized_methods
  ]
  for_each = {
    for index, handler in var.auth_handlers:
    index => handler
  }
  rest_api_id = var.rest_api_id
  resource_id = aws_api_gateway_resource.resource.id
  http_method = each.value.method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = each.value.lambda_invoke_arn
}
/* Unauthorized methods and integration */