variable "project_id" {
  type        = string
  description = "The Google Cloud project ID where the workflow will be created."
}

variable "region" {
  type        = string
  description = "The Google Cloud region where the workflow will be deployed."
}

variable "workflow_name" {
  type        = string
  description = "The name assigned to the Google Cloud Workflows resource."
}

variable "description" {
  type        = string
  description = "The description for the Google Cloud Workflows resource."
  default     = "Generic workflow pipeline."
}

variable "service_account_email" {
  type        = string
  description = "The email of the Service Account used to execute the workflow."
}

variable "steps" {
  type = list(object({
    name = string
    url  = string
  }))
  description = "List of steps to execute sequentially in the workflow."
}