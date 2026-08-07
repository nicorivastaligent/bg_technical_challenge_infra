variable "project_id" {
  type        = string
  description = "The Google Cloud project ID where the Cloud Scheduler job will be created."
}

variable "region" {
  type        = string
  description = "The Google Cloud region where the scheduler job will be deployed (e.g., us-central1)."
}

variable "job_name" {
  type        = string
  description = "The name assigned to the Cloud Scheduler job resource."
}

variable "description" {
  type        = string
  description = "The description for the Cloud Scheduler job."
  default     = "Trigger for scheduled HTTP job execution."
}

variable "schedule" {
  type        = string
  description = "The cron expression defining the schedule execution time (e.g., '0 3 * * *')."
}

variable "time_zone" {
  type        = string
  description = "The timezone in which the schedule will be executed."
  default     = "America/Argentina/Buenos_Aires"
}

variable "target_uri" {
  type        = string
  description = "The full HTTP target URI that Cloud Scheduler will call (e.g., Workflow executions API or Cloud Run URL)."
}

variable "service_account_email" {
  type        = string
  description = "The email of the Service Account used by Cloud Scheduler to authenticate the HTTP request."
}