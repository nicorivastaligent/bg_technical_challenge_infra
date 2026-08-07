# ── Outputs de Service Accounts ──────────────────────────────────────────────

output "sa_bronze_email" {
  description = "El correo electrónico del Service Account para la capa Bronze (Extracción)."
  value       = google_service_account.sa_bronze.email
}

output "sa_transform_email" {
  description = "El correo electrónico del Service Account para las capas Silver y Gold (Transformación)."
  value       = google_service_account.sa_transform.email
}

output "sa_bronze_name" {
  description = "El nombre completo del recurso (ID) del Service Account Bronze."
  value       = google_service_account.sa_bronze.name
}

output "sa_transform_name" {
  description = "El nombre completo del recurso (ID) del Service Account Transform."
  value       = google_service_account.sa_transform.name
}