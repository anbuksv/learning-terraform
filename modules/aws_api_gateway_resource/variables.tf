variable "parent_id" {
  type = string
  description = "Parent ID of the resource"
}

variable "rest_api_id" {
  type = string
  description = "Rest API ID"
}

variable "path_part" {
  type = string
  description = "Handler Path"
}

variable "handlers" {
  default = []
  type = list(object({
    method = string
    lambda_invoke_arn = string
    api_key_required = bool
  }))
  description = "List of method need to add to given resource"
}

variable "auth_handlers" {
  default = []
  type = list(object({
    method = string
    lambda_invoke_arn = string
    api_key_required = bool
    authorization = string
    authorizer_id = string
  }))
  description = "List of method need to add to given resource with authorization support"
}