# Cloud Scheduler Module

This module provisions a **Google Cloud Scheduler** job configured to make authenticated HTTP POST requests (e.g., triggering a Cloud Workflow execution) on a cron-based schedule.

## Usage

```hcl
module "scheduler" {
  source                = "../../modules/scheduler"
  project_id            = "my-gcp-project"
  region                = "us-central1"
  job_name              = "dev-taligent-iowa-daily-trigger"
  description           = "Daily trigger for Iowa pipeline workflow"
  schedule              = "30 12 * * *"
  time_zone             = "America/Argentina/Buenos_Aires"
  service_account_email = "my-sa@my-gcp-project.iam.gserviceaccount.com"
  target_uri            = module.workflow.execution_uri
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `project_id` | GCP Project ID where the scheduler job will be created | `string` | — | yes |
| `region` | GCP Region for scheduler deployment | `string` | — | yes |
| `job_name` | Name assigned to the Cloud Scheduler job | `string` | — | yes |
| `description` | Description of the Scheduler job | `string` | `"Trigger for scheduled HTTP job execution."` | no |
| `schedule` | Cron schedule expression (e.g. `30 12 * * *`) | `string` | — | yes |
| `time_zone` | Timezone for the cron schedule | `string` | `"America/Argentina/Buenos_Aires"` | no |
| `target_uri` | HTTP target URI to invoke | `string` | — | yes |
| `service_account_email` | Service Account email for OAuth authentication | `string` | — | yes |

## Outputs

| Name | Description |
|------|-------------|
| `job_id` | Fully qualified ID of the Cloud Scheduler job |
| `job_name` | Name of the Cloud Scheduler job |
