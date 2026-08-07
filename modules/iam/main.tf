# ── Service Accounts ─────────────────────────────────────────────────────────

resource "google_service_account" "sa_bronze" {
  account_id   = "${var.environment}-${var.client}-btc-sa-bronze"
  display_name = "SA Bronze - ${local.prefix}"
  project      = var.gcp_project_id
}

resource "google_service_account" "sa_transform" {
  account_id   = "${var.environment}-${var.client}-btc-sa-transform"
  display_name = "SA Silver - ${local.prefix}"
  project      = var.gcp_project_id
}

# ── Permisos para sa_bronze: Leer, escribir y modificar objetos en el bucket bronze ──────────────────────────────────────────────

resource "google_storage_bucket_iam_member" "bronze_sa_bronze_write" {
  bucket = var.bronze_bucket_name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.sa_bronze.email}"
}

# ── Permisos para sa_transform: Lee bronze, escribe en bigquery ─────────────────────────────────────

#Lee en bucket bronze 
resource "google_storage_bucket_iam_member" "transform_sa_bronze_read" {
  bucket = var.bronze_bucket_name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.sa_transform.email}"
}

#Escribe en bigquery
resource "google_project_iam_member" "transform_sa_bq_editor" {
  project = var.gcp_project_id
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${google_service_account.sa_transform.email}"
}

#Ejecutar los trabajos (jobs) de carga y consultas en BigQuery
resource "google_project_iam_member" "transform_sa_bq_job_user" {
  project = var.gcp_project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.sa_transform.email}"
}

# Obtener los datos del proyecto actual para sacar el project_number
data "google_project" "project" {
  project_id = var.project
}

# Permiso para invocar Cloud Functions desde Workflows
resource "google_project_iam_member" "workflow_invoker" {
  project = var.gcp_project_id
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.sa_transform.email}"
}

# Permiso para invocar Workflows desde Scheduler
resource "google_project_iam_member" "scheduler_workflow_invoker" {
  project = var.gcp_project_id
  role    = "roles/workflows.invoker"
  member  = "serviceAccount:${google_service_account.sa_transform.email}"
}

# ── Permisos para la Service Account por defecto de Compute Engine (Usada en el Build de GCF v2) ──

# Permiso para escribir logs en Cloud Logging
resource "google_project_iam_member" "compute_logs_writer" {
  project = var.project
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
}

# Permiso para leer objetos de Cloud Storage (ZIPs del código fuente)
resource "google_project_iam_member" "compute_storage_viewer" {
  project = var.project
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
}

# Permiso para guardar las imágenes del contenedor en Artifact Registry
resource "google_project_iam_member" "compute_artifact_writer" {
  project = var.project
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
}

# ── SA to use CI/CD with GitHub Actions ──

# 1. Service Account for GitHub Actions
resource "google_service_account" "github_actions"{
  account_id = "github-actions-deployer"
  display_name = "Github Actions Deployer SA"
  project = var.project
}

# 2. Cloud Functions Deploy and modify permissions
resource "google_project_iam_member" "github_actions_cf_developer" {
  project = var.project 
  role = "roles/cloudfunctions.developer"
  member = "serviceAccount:${google_service_account.github_actions.email}"
}

resource "google_project_iam_member" "github_actions_sa_user"{
  project = var.project
  role = "roles/iam.serviceAccountUser"
  member = "serviceAccount:${google_service_account.github_actions.email}"
}

# ── Workload Identity Federation for GitHub Actions ──

# 1. Create Identity pool
resource "google_iam_workload_identity_pool" "github_pool" {
  project                   = var.project
  workload_identity_pool_id = "github-actions-pool"
  display_name              = "GitHub Actions Pool"
  description               = "Identity pool for GitHub Actions"
}

# 2. Create provider
resource "google_iam_workload_identity_pool_provider" "github_provider" {
  project                            = var.project
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-actions-provider"
  display_name                       = "GitHub Actions Provider"
  
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
  }

  attribute_condition = "assertion.repository == 'nicorivastaligent/bg_technical_challenge'"
  
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

# 3. SA use for github
resource "google_service_account_iam_member" "workload_identity_user" {
  service_account_id = google_service_account.github_actions.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/nicorivastaligent/bg_technical_challenge"
}

# 4. Output para que nos devuelva el string exacto que necesitamos para GitHub Actions
output "github_workload_identity_provider" {
  value = google_iam_workload_identity_pool_provider.github_provider.name
}