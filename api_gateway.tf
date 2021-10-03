# resource "aws_api_gateway_rest_api" "demo-gateway" {
#   name = "demo-gateway"
# }

# resource "aws_api_gateway_resource" "root_resource" {
#     path_part = "public"
#     parent_id = aws_api_gateway_rest_api.demo-gateway.root_resource_id
#     rest_api_id = aws_api_gateway_rest_api.demo-gateway.id
# }

# resource "aws_api_gateway_resource" "public_dynamic" {
#     parent_id = aws_api_gateway_resource.root_resource.id
#     rest_api_id = aws_api_gateway_rest_api.demo-gateway.id
#     path_part = "{path+}"
# }

# resource "aws_api_gateway_method" "root_resource_method" {
#   authorization = "NONE"
#   http_method = "ANY"
#   resource_id = aws_api_gateway_resource.root_resource.id
#   rest_api_id = aws_api_gateway_rest_api.demo-gateway.id
# }

# resource "aws_api_gateway_integration" "root_resource_any_method" {
#   rest_api_id = aws_api_gateway_rest_api.demo-gateway.id
#   resource_id = aws_api_gateway_resource.root_resource.id
#   http_method = aws_api_gateway_method.root_resource_method.http_method
#   integration_http_method = "POST"
#   type = "AWS_PROXY"
#   uri = aws_lambda_function.lamda_function.invoke_arn
# }

# resource "aws_api_gateway_deployment" "demo_gateway_deployment" {
#   rest_api_id = aws_api_gateway_rest_api.demo-gateway.id
#   lifecycle {
#     create_before_destroy = true
#   }
#   triggers = {
#     # NOTE: The configuration below will satisfy ordering considerations,
#     #       but not pick up all future REST API changes. More advanced patterns
#     #       are possible, such as using the filesha1() function against the
#     #       Terraform configuration file(s) or removing the .id references to
#     #       calculate a hash against whole resources. Be aware that using whole
#     #       resources will show a difference after the initial implementation.
#     #       It will stabilize to only change when resources change afterwards.
    
    
#     redeployment = sha1(jsonencode([
#       aws_api_gateway_resource.root_resource.id,
#       aws_api_gateway_method.root_resource_method.id,
#       aws_api_gateway_integration.root_resource_any_method.id,
#     ]))
#   }
# }

# resource "aws_api_gateway_stage" "demo_gateway_stage" {
#   stage_name = var.stage_name
#   deployment_id = aws_api_gateway_deployment.demo_gateway_deployment.id
#   rest_api_id = aws_api_gateway_rest_api.demo-gateway.id
# }

module "api_gateway" {
  source          = "./modules/gateway"
  api_gateway_name = "Terraform Manged API Gateway"
  resource_path = "public"
  lamda_invoke_arn = aws_lambda_function.lamda_function.invoke_arn
  stage_name = "Prod"
}

# module "api_gateway_new" {
#   source          = "./modules/gateway"
#   api_gateway_name = "New Terraform Manged API Gateway"
#   resource_path = "public_new"
#   lamda_invoke_arn = aws_lambda_function.lamda_function.invoke_arn
#   stage_name = "Prod"
# }

