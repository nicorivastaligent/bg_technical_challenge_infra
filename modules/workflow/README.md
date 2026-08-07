# GCP Workflow Module

This module provisions a **Google Cloud Workflow** resource. It dynamically generates a sequential YAML pipeline based on a list of steps, calling each endpoint via HTTP GET with OIDC authentication.

## Usage

```hcl
module "workflow" {
  source                = "../../modules/workflow"
  project_id            = "my-gcp-project"
  region                = "us-central1"
  workflow_name         = "dev-taligent-iowa-pipeline"
  description           = "Sequential pipeline for processing Bronze, Silver, and Gold layers."
  service_account_email = "my-sa@my-gcp-project.iam.gserviceaccount.com"

  steps = [
    {
      name = "run_bronze_extract"
      url  = "https://my-bronze-function-url.a.run.app"
    },
    {
      name = "run_silver_transform"
      url  = "https://my-silver-function-url.a.run.app"
    }
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `project_id` | GCP Project ID where the workflow will be created | `string` | — | yes |
| `region` | GCP Region for workflow deployment | `string` | — | yes |
| `workflow_name` | Name assigned to the Workflow resource | `string` | — | yes |
| `description` | Description for the Workflow resource | `string` | `"Generic workflow pipeline."` | no |
| `service_account_email` | Service Account email executing the workflow | `string` | — | yes |
| `steps` | List of step objects (`name`, `url`) executed sequentially | `list(object)` | — | yes |

## Outputs

| Name | Description |
|------|-------------|
| `workflow_id` | Fully qualified resource ID of the Workflow |
| `workflow_name` | Name of the Workflow resource |
| `execution_uri` | Execution URI used by Cloud Scheduler or triggers |
