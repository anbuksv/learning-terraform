variable "api_gateway_name" {
  type = string
  description = "Name of the API gateway"
}

variable "resource_path" {
  type = string
  description = "Name of the root resource path"
}

variable "lamda_invoke_arn" {
  type = string
  description = "ARN of lamda function"
}

variable "stage_name" {
  type = string
  description = "Deployment stage name"
}