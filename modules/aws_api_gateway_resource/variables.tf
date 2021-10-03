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
    type = list(object({
        method = string
        lambda_invoke_arn = string
    }))
    description = "List of method need to add to given resource"
}