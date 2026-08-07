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
  description = "The GCP region to deploy resources"
  type        = string
}

variable "domain" {
  description = "The domain of the data, e.g., rrhh"
  type        = string
}

variable "product" {
  description = "The product related to the data, e.g., nomina"
  type        = string
}

variable "name" {
  description = "The name of the table, e.g., empleados"
  type        = string
}

variable "dataset_id" {
  description = "The BigQuery dataset ID where tables will be created"
  type        = string
}

variable "gold_bucket_name" {
  description = "The GCS bucket name containing gold layer Parquet files"
  type        = string
}

variable "gold_path_prefix" {
  description = "The GCS path prefix within the bucket for this table's gold data"
  type        = string
}

variable "gcp_project_id" {
  description = "The GCP project ID"
  type        = string
}
