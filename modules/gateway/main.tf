terraform {
  required_version = ">= 0.13"
}

resource "aws_api_gateway_rest_api" "gateway" {
  name = var.api_gateway_name
  description = "Deployed at ${timestamp()}"
}

resource "aws_api_gateway_resource" "resource" {
  parent_id = aws_api_gateway_rest_api.gateway.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.gateway.id
  path_part = var.resource_path
}

resource "aws_api_gateway_method" "method" {
  for_each = toset([ "GET", "PUT", "POST", "DELETE" ])
  rest_api_id = aws_api_gateway_rest_api.gateway.id
  resource_id = aws_api_gateway_resource.resource.id
  authorization = "NONE"
  http_method = each.key
}

resource "aws_api_gateway_integration" "integration" {
  depends_on = [
    aws_api_gateway_method.method
  ]
  for_each = toset([ "GET", "PUT", "POST", "DELETE" ])
  rest_api_id = aws_api_gateway_rest_api.gateway.id
  resource_id = aws_api_gateway_resource.resource.id
  http_method = each.key
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = var.lamda_invoke_arn
}

# resource "aws_api_gateway_deployment" "deployment" {
#   rest_api_id = aws_api_gateway_rest_api.gateway.id
#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_api_gateway_stage" "demo_gateway_stage" {
#   stage_name = var.stage_name
#   deployment_id = aws_api_gateway_deployment.deployment.id
#   rest_api_id = aws_api_gateway_rest_api.gateway.id
# }