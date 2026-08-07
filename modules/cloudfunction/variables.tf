variable "client" {
  description = "The client name"
  type        = string
}

variable "project" {
  description = "The project name"
  type        = string
}

variable "environment" {
  description = "The environment (e.g. dev, prod)"
  type        = string
}

variable "region" {
  description = "The GCP region to deploy resources to"
  type        = string
  default     = "us-central1"
}

variable "domain" {
  description = "The domain of the function, e.g., rrhh"
  type        = string
}

variable "product" {
  description = "The product related to the function, e.g., nomina"
  type        = string
}

variable "topic" {
  description = "The frequency or topic of the function execution, e.g., daily"
  type        = string
}

variable "layer" {
  description = "The medallion layer of the function, e.g., bronze"
  type        = string
}

variable "name" {
  description = "The base name of the function, e.g., function"
  type        = string
}

variable "runtime" {
  description = "The runtime in which to run the function"
  type        = string
  default     = "python311"
}

variable "entry_point" {
  description = "The name of the function (as defined in source code) that will be executed"
  type        = string
  default     = "main"
}

variable "source_local_path" {
  description = "The local filesystem path to the function directory containing main.py, requirements.txt, and other dependencies"
  type        = string
}

variable "source_bucket_name" {
  description = "The name of the GCS bucket to store the function source archive"
  type        = string
}

variable "output_path" {
  description = "The path where the zip archive of the function source code will be stored locally before uploading"
  type        = string
}

variable "service_account_email" {
  description = "The email of the service account to run the function as (created by the IAM module)"
  type        = string
  default     = null
}

variable "available_memory" {
  description = "The amount of memory available to the function (e.g. 256M, 512M, 1G)"
  type        = string
  default     = "512M"
}

variable "timeout_seconds" {
  description = "The timeout in seconds for the function"
  type        = number
  default     = 60
}

variable "max_instance_count" {
  description = "The maximum number of instances for the function"
  type        = number
  default     = 1
}

variable "environment_variables" {
  type        = map(string)
  default     = {}
  description = "Environment variables for the function"
}