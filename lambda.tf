data "archive_file" "lambda-zip" {
  type        = "zip"
  source_dir = var.lambda_src_dir
  output_path = var.lambda_function_package_file
}

resource "aws_lambda_function" "lamda_function" {
    runtime = "python3.6"
    role = aws_iam_role.lambda_role.arn
    filename = var.lambda_function_package_file
    source_code_hash = data.archive_file.lambda-zip.output_base64sha256
    function_name = "apigwt_prod_testing_function"
    handler = "router.event_handler"
}

# IAM
resource "aws_iam_role" "lambda_role" {
  name = "apigw_testing_role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

# Lambda
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lamda_function.function_name
  principal     = "apigateway.amazonaws.com"

  # The /*/*/* part allows invocation from any stage, method and resource path
  # within API Gateway REST API.
  # source_arn = "${module.api_gateway.rest_api.execution_arn}/*/*/*"
  source_arn = "${aws_api_gateway_rest_api.rest_api.execution_arn}/*/*/*"
}