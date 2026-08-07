# Cloud Function Module

This module creates a Google Cloud Function (Gen 2) and automatically packages the source code as a .zip, uploading it to a provided GCS bucket.

The service account must be created beforehand by the IAM module and passed in via `service_account_email`.

## Requirements

- **Terraform:** >= 1.0
- **Google Provider:** >= 7.0.0, < 8.0.0
  - Versión restringida para evitar breaking changes. Usa `google_cloudfunctions2_function` y `google_storage_bucket_object` que son estables en v7.x
  - **Nota técnica:** `google_storage_bucket_object` está deprecado pero funciona en v7.x. Se recomienda migrar a `google_storage_bucket_object_content` cuando se actualice a v8.x
- **Archive Provider:** >= 2.0
  - Para empaquetar código fuente de funciones

## Prerequisites: Project Setup Module Required

This module requires that the **project setup module** has enabled the necessary APIs:
- `cloudfunctions` — Cloud Functions API
- `run` — Cloud Run API
- `cloudbuild` — Cloud Build API
- `artifactregistry` — Artifact Registry API

Without these APIs enabled, `terraform apply` will fail. 

### Integration Pattern

The project setup module uses `depends_on` to ensure APIs are enabled before this module executes. This provides:
- Single `terraform apply` command
- Guaranteed execution order
- No data coupling (this module doesn't consume project_setup outputs)

See the project_setup module README for integration details.

## Important: IAM Binding Responsibility

This module creates the Cloud Function resource only. **The function will not be invocable until an IAM binding is created.**

**The IAM module is responsible for managing the `roles/run.invoker` binding.** This binding grants invoke permissions to service accounts that need to call this Cloud Function (e.g., Workflows, Cloud Scheduler, Cloud Run).

The IAM module should:
1. Create or reference the service account that will invoke this function
2. Add a `google_cloud_run_v2_service_iam_member` binding with role `roles/run.invoker` on the Cloud Function resource
3. Reference the function's resource name (output `function_uri` from this module)

This separation ensures:
- **Centralized IAM management** — All permissions are handled by the IAM module
- **Clean module boundaries** — Each module has a single responsibility
- **Microservices pattern** — Decoupling between function creator and function consumers

## Convention Example
Given:
- `client` = "taligent"
- `environment` = "dev"
- `domain` = "rrhh"
- `product` = "nomina"
- `topic` = "daily"
- `layer` = "bronze"
- `name` = "function"

It generates the function name `dev-tdp-rrhh-nomina-daily-bronze-function`.

## Usage
```hcl
module "my_cloud_function" {
  source             = "../modules/cloudfunction"
  client             = "taligent"
  project            = "data-platform"
  environment        = "dev"
  region             = "us-central1"
  domain             = "rrhh"
  product            = "nomina"
  topic              = "daily"
  layer              = "bronze"
  name               = "function"
  service_account_email = module.iam.bronze.email  # SA por layer, del módulo IAM
  source_local_path     = "${path.module}/src/functions/rrhh/nomina/daily/bronze/function"
  source_bucket_name = "dev-taligent-services-functions-src"
  output_path        = "${path.module}/tmp/rrhh/nomina/daily/bronze/function.zip"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `client` | The client name | `string` | — | yes |
| `project` | The project name | `string` | — | yes |
| `environment` | The environment (e.g. dev, test, prod) | `string` | — | yes |
| `region` | The GCP region to deploy resources to | `string` | `"us-central1"` | no |
| `domain` | The domain of the function, e.g., rrhh | `string` | — | yes |
| `product` | The product related to the function, e.g., nomina | `string` | — | yes |
| `topic` | The frequency or topic of the function execution, e.g., daily | `string` | — | yes |
| `layer` | The medallion layer of the function, e.g., bronze | `string` | — | yes |
| `name` | The base name of the function, e.g., function | `string` | — | yes |
| `service_account_email` | The email of the service account (from IAM module: `module.iam.{bronze\|silver\|gold}.email`) | `string` | `null` | no |
| `runtime` | The runtime in which to run the function | `string` | `"python311"` | no |
| `entry_point` | The name of the function that will be executed | `string` | `"main"` | no |
| `source_local_path` | Local path to the function directory containing main.py, requirements.txt, and other dependencies | `string` | — | yes |
| `source_bucket_name` | The GCS bucket name to store the function source archive | `string` | — | yes |
| `output_path` | Local path where the zip will be stored before uploading | `string` | — | yes |
| `available_memory` | The amount of memory available to the function (e.g. 256M, 512M, 1G) | `string` | `"256M"` | no |
| `timeout_seconds` | The timeout in seconds for the function | `number` | `60` | no |
| `max_instance_count` | The maximum number of instances for the function | `number` | `1` | no |

## Outputs

| Name | Description |
|------|-------------|
| `function_name` | The name of the created Cloud Function |
| `function_uri` | The URI of the Cloud Function |
| `function_resource_name` | The full resource name of the Cloud Function (for IAM bindings) |

**Note:** The `function_resource_name` output should be consumed by the IAM module to create `google_cloud_run_v2_service_iam_member` bindings for service accounts that need to invoke this function.
