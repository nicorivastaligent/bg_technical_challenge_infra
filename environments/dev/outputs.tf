output "bronze_bucket_name" {
  description = "The name of the bronze GCS bucket"
  value       = module.storage_bucket["bronze"].bucket_name
}

output "silver_datasets" {
  description = "BigQuery datasets created for the Silver layer"
  value       = { for k, v in google_bigquery_dataset.silver : k => v.dataset_id }
}

output "gold_datasets" {
  description = "BigQuery datasets created for the Gold layer"
  value       = { for k, v in google_bigquery_dataset.gold : k => v.dataset_id }
}