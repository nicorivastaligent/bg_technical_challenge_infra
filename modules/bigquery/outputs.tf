output "gold_table_id" {
  description = "The ID of the gold external table"
  value       = google_bigquery_table.gold_external.table_id
}
