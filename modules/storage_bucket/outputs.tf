output "bucket_name" {
  description = "The name of the created GCS bucket."
  value       = google_storage_bucket.bucket.name
}

output "bucket_url" {
  description = "The URI of the created GCS bucket."
  value       = google_storage_bucket.bucket.url
}
