resource "google_bigquery_table" "gold_external" {
  dataset_id          = var.dataset_id
  table_id            = local.gold_table_name
  project             = var.gcp_project_id
  deletion_protection = false

  external_data_configuration {
    source_uris   = ["gs://${var.gold_bucket_name}/${var.gold_path_prefix}"]
    source_format = "PARQUET"
    autodetect    = true
  }
}
