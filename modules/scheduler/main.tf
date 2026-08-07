resource "google_cloud_scheduler_job" "scheduled_trigger" {
    name = var.job_name
    project = var.project_id
    region = var.region
    description = var.description
    schedule = var.schedule 
    time_zone = var.time_zone

    http_target {
        http_method = "POST"
        uri = var.target_uri

        oauth_token {
            service_account_email = var.service_account_email
        }
    }
}