variable "project" {
  description = "Project short name used for resource naming."
  type        = string
}

variable "region" {
  description = "Region of the servers that the buckets will be created in."
  type        = string
}

variable "client" {
  description = "Client that the bucket is going to be created in."
  type        = string
}

variable "environment" {
  description = "Environment that the bucket is going to be created in."
  type        = string
}

variable "discover_objects" {
  description = "Whether to discover and create BigQuery tables from gold bucket objects. Set to true after adding data to the bucket."
  type        = bool
  default     = false
}

variable "force_destroy_functions_bucket" {
  description = "Whether to force destroy the functions source bucket (set true only in dev/test)"
  type        = bool
  default     = false
}
