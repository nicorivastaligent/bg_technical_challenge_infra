output "function_name" {
  description = "The name of the created function"
  value       = google_cloudfunctions2_function.default.name
}

output "function_uri" {
  description = "The URI of the function"
  value       = google_cloudfunctions2_function.default.service_config[0].uri
}

output "function_resource_name" {
  description = "The full resource name of the Cloud Function for IAM bindings"
  value       = google_cloudfunctions2_function.default.id
}
