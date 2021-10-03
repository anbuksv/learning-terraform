
resource "aws_cognito_user_pool" "private_pool" {
  name = "Private_Pool"
}

data "aws_cognito_user_pools" "private_pool" {
  depends_on = [
    aws_cognito_user_pool.private_pool
  ]
  name = "Private_Pool"
}

resource "aws_api_gateway_rest_api" "rest_api" {
  name = "Terraform Managed REST API"
}

resource "aws_api_gateway_authorizer" "private_resource" {
  name          = "CognitoPrivateUserPoolAuthorizer"
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id

  type          = "COGNITO_USER_POOLS"
  provider_arns = data.aws_cognito_user_pools.private_pool.arns
}

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

# module "api_gateway" {
#   source          = "./modules/gateway"
#   api_gateway_name = "Terraform Manged API Gateway"
#   resource_path = "public"
#   lamda_invoke_arn = aws_lambda_function.lamda_function.invoke_arn
#   stage_name = "Prod"
# }

# module "api_gateway_new" {
#   source          = "./modules/gateway"
#   api_gateway_name = "New Terraform Manged API Gateway"
#   resource_path = "public_new"
#   lamda_invoke_arn = aws_lambda_function.lamda_function.invoke_arn
#   stage_name = "Prod"
# }


locals {
  public_resources_handler = aws_lambda_function.lamda_function.invoke_arn
}
module "public_resources" {
  source = "./modules/aws_api_gateway_resource"
  parent_id = aws_api_gateway_rest_api.rest_api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  path_part = "public"
  handlers = [
    {
      lambda_invoke_arn = local.public_resources_handler
      method = "GET"
      api_key_required = false
    },
    {
      lambda_invoke_arn = local.public_resources_handler
      method = "PUT"
      api_key_required = true
    },
    {
      lambda_invoke_arn = local.public_resources_handler
      method = "POST"
      api_key_required = true
    },
    {
      lambda_invoke_arn = local.public_resources_handler
      method = "DELETE"
      api_key_required = true
    }
  ]
}

module "private_resource" {
  source = "./modules/aws_api_gateway_resource"
  parent_id = aws_api_gateway_rest_api.rest_api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  path_part = "private"
}

module "private_dynamic_resource" {
  source = "./modules/aws_api_gateway_resource"
  parent_id = module.private_resource.value.id
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  path_part = "{path+}"
  auth_handlers = [
    {
      lambda_invoke_arn = local.public_resources_handler
      method = "GET"
      api_key_required = true
      authorization = "COGNITO_USER_POOLS"
      authorizer_id = aws_api_gateway_authorizer.private_resource.id
    },
    {
      lambda_invoke_arn = local.public_resources_handler
      method = "POST"
      api_key_required = true
      authorization = "COGNITO_USER_POOLS"
      authorizer_id = aws_api_gateway_authorizer.private_resource.id
    }
  ]
}