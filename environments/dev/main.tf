terraform {
  required_version = ">= 1.3.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 7.25.0"
    }
  }
}

provider "google" {
  project = var.project
  region  = var.region
}

# ── API Activation ───────────────────────────────────────────────────
resource "google_project_service" "apis" {
  for_each = toset([
    "cloudfunctions.googleapis.com",
    "workflows.googleapis.com",
    "cloudscheduler.googleapis.com"
  ])

  project            = var.project
  service            = each.key
  disable_on_destroy = false 
}

# ── Storage Infrastructure ───────────────────────────────────────────────────

module "storage_bucket" {
  source   = "../../modules/storage_bucket"
  for_each = toset(["bronze"])

  region      = var.region
  bucket_name = "${local.prefix}-gcs-${each.key}"
  labels = {
    "client"      = var.client
    "environment" = var.environment
    "layer"       = each.key
  }
  lifecycle_rules = [
    {
      action = {
        type = "Delete"
      }
      condition = {
        age = 365
      }
    },
    {
      action = {
        type = "AbortIncompleteMultipartUpload"
      }
      condition = {
        age = 1
      }
    }
  ]
}

resource "google_storage_bucket" "functions_src" {
  name                        = local.functions_src_bucket_name
  location                    = var.region
  uniform_bucket_level_access = true
  force_destroy               = var.force_destroy_functions_bucket

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 90
    }
  }
}

# ── Service Account ──────────────────────────────────────────────────────────

module "iam" {
  source = "../../modules/iam"

  client = var.client
  project = var.project
  gcp_project_id = var.project
  environment = var.environment
  bronze_bucket_name = module.storage_bucket["bronze"].bucket_name

}

# ── Cloud Functions ──────────────────────────────────────────────────────────

module "cloud_functions" {
  source   = "../../modules/cloudfunction"
  for_each = local.parsed_functions

  client      = var.client
  project     = var.project
  environment = var.environment
  region      = var.region

  domain  = each.value.domain
  product = each.value.product
  topic   = each.value.topic
  layer   = each.value.layer
  name    = each.value.name

  service_account_email = each.value.layer == "bronze" ? module.iam.sa_bronze_email : module.iam.sa_transform_email

  source_local_path  = "${path.module}/src/functions/${dirname(each.key)}"
  source_bucket_name = google_storage_bucket.functions_src.name
  output_path        = "${path.module}/tmp/${dirname(each.key)}.zip"

  environment_variables = merge(
    {
      GCP_PROJECT_ID = var.project
    },
    each.value.layer == "bronze" ? {
      GCS_BUCKET_NAME = module.storage_bucket["bronze"].bucket_name
    } : {}
  ) 
}

# ── BigQuery Infrastructure ──────────────────────────────────────────────────

resource "google_bigquery_dataset" "silver" {
  for_each   = local.parsed_domains
  dataset_id = replace("${local.prefix}_${each.key}_silver", "-", "_")
  location = "US"
}

resource "google_bigquery_dataset" "gold" {
  for_each   = local.parsed_domains
  dataset_id = replace("${local.prefix}_${each.key}_gold", "-", "_")
  location = "US"
}

# ── Workflow creation ──────────────────────────────────────────────────

module "workflow" {
  source = "../../modules/workflow"
  depends_on = [google_project_service.apis]

  project_id = var.project
  region = var.region
  workflow_name = "${local.prefix}-iowa-pipeline"
  description = "Pipeline for secuentialy process bronze, silver and gold."
  service_account_email = module.iam.sa_transform_email

  steps = [
    for step in sort([
      for path, value in local.parsed_functions : format(
        "%s|%s|%s",
        value.layer == "bronze" ? "1" : (value.layer == "silver" ? "2" : "3"),
        path,
        value.name
      )
    ]) : {
      name = "run_${local.parsed_functions[split("|", step)[1]].layer}_${split("|", step)[2]}"
      url = module.cloud_functions[split("|",step)[1]].function_uri
    }
  ]
}

# ── Trigger workflow ──────────────────────────────────────────────────

module "scheduler" {
  source = "../../modules/scheduler"
  depends_on = [google_project_service.apis]

  project_id = var.project
  region = var.region 
  job_name = "${local.prefix}-iowa-daily-trigger"
  description = "Daily trigger for iowa pipeline workflow"
  schedule = "30 12 * * *"
  time_zone = "America/Argentina/Buenos_Aires"
  service_account_email = module.iam.sa_transform_email

  target_uri = module.workflow.execution_uri
}