output "job_id" {
  value       = google_cloud_scheduler_job.scheduled_trigger.id
  description = "The identifier for the created Cloud Scheduler job."
}

output "job_name" {
  value       = google_cloud_scheduler_job.scheduled_trigger.name
  description = "The name of the created Cloud Scheduler job."
}