# IAM Module

This module creates the service accounts and IAM bindings for the medallion data lake architecture (Bronze → Silver → Gold).

Each layer has a dedicated service account with permissions that follow the data flow:

| Service Account | Read | Write |
|----------------|------|-------|
| SA Bronze | — | Bronze |
| SA Silver | Bronze | Silver |
| SA Gold | Silver | Gold |

Optionally, a Google Group for data engineers can be granted read access to all layers.

## Usage

```hcl
module "iam" {
  source = "../../modules/iam"

  client         = "taligent"
  project        = "data-platform"
  environment    = "dev"
  gcp_project_id = "dev-taligent-data-platform-gcp"

  bronze_bucket_name   = "dev-taligent-data-platform-gcs-bronze"
  silver_bucket_name   = "dev-taligent-data-platform-gcs-silver"
  gold_bucket_name     = "dev-taligent-data-platform-gcs-gold"
  engineer_group_email = "data-engineers@taligent.com.ar"
}

# Pasar el SA al módulo de cloud function
module "cloud_functions" {
  source = "../../modules/cloudfunction"
  # ...
  service_account_email = module.iam.service_account_emails["bronze"]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `client` | The client name | `string` | — | yes |
| `project` | The project name | `string` | — | yes |
| `environment` | The environment (e.g. dev, test, prod) | `string` | — | yes |
| `gcp_project_id` | GCP Project ID where the service accounts will be created | `string` | — | yes |
| `bronze_bucket_name` | GCS bucket name for the bronze layer | `string` | — | yes |
| `silver_bucket_name` | GCS bucket name for the silver layer | `string` | — | yes |
| `gold_bucket_name` | GCS bucket name for the gold layer | `string` | — | yes |
| `engineer_group_email` | Google Group email for data engineers | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| `service_account_emails` | Map of layer to service account email (`bronze`, `silver`, `gold`) |
