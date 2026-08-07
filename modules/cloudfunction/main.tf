data "archive_file" "function_zip" {
  type        = "zip"
  source_dir  = var.source_local_path
  output_path = var.output_path
}

resource "google_storage_bucket_object" "function_zip" {
  name   = "source-${data.archive_file.function_zip.output_md5}.zip"
  bucket = var.source_bucket_name
  source = data.archive_file.function_zip.output_path
}

resource "google_cloudfunctions2_function" "default" {
  name        = local.function_name
  location    = var.region
  project     = var.project
  description = "Cloud function for ${local.function_name}"

  lifecycle {
    precondition {
      condition     = length(local.function_name) <= 63
      error_message = "El nombre de la función '${local.function_name}' tiene ${length(local.function_name)} caracteres; el límite de Cloud Functions Gen2 es 63."
    }
  }

  build_config {
    runtime     = var.runtime
    entry_point = var.entry_point
    source {
      storage_source {
        bucket = var.source_bucket_name
        object = google_storage_bucket_object.function_zip.name
      }
    }
  }

  service_config {
    max_instance_count    = var.max_instance_count
    available_memory      = var.available_memory
    timeout_seconds       = var.timeout_seconds
    service_account_email = var.service_account_email
    environment_variables = var.environment_variables
  }
}

# NOTE: IAM Binding (roles/run.invoker) must be managed by the IAM module.
# The IAM module is responsible for granting invoke permissions to service accounts
# that need to call this Cloud Function (e.g., Workflows, Cloud Run, etc.).
# This ensures centralized permission management and proper separation of concerns.
