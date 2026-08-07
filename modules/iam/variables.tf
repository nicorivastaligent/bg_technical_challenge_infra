variable "project" {
  description = "Project short name used for resource naming."
  type        = string
}

variable "client" {
  description = "Client that the bucket is going to be created in."
  type        = string
}

variable "gcp_project_id" {
  description = "GCP Project ID where the Service Accounts and IAM bindings will be created."
  type        = string
}

variable "environment" {
  description = "Environment name used to construct the Service Account IDs (e.g., dev, prod)."
  type        = string
}

variable "bronze_bucket_name" {
  description = "The name of the GCS Bronze bucket where permissions will be granted."
  type        = string
}