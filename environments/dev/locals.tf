locals {
  # Resource naming prefix (env-client-project)
  prefix = "${var.environment}-${var.client}-${var.project}"

  # Target GCP Project ID
  gcp_project_id = "${var.environment}-${var.client}-${var.project}-gcp"

  # GCS bucket for Cloud Functions source code
  functions_src_bucket_name = "${var.environment}-${var.client}-bg-technical-challenge-functions-src"

  # Fails execution if no valid Cloud Functions are found in src/functions/
  _validate_functions = length(fileset("${path.module}/src/functions", "**/main.py")) == 0 ? (
    file("ERROR: No Cloud Functions found in src/functions/. Verify directory structure: domain/product/topic/layer/name/main.py")
  ) : null
  
  # Maps local file paths to function metadata (domain, product, topic, layer, name)
  parsed_functions = {
    for path in fileset("${path.module}/src/functions", "**/main.py") :
    path => regex("^(?P<domain>[^/]+)/(?P<product>[^/]+)/(?P<topic>[^/]+)/(?P<layer>bronze|silver|gold)/(?P<name>[^/]+)/main\\.py$", path)
    if can(regex("^[^/]+/[^/]+/[^/]+/(bronze|silver|gold)/[^/]+/main\\.py$", path))
  }

  # Unique domains extracted from local paths to provision BigQuery datasets
  parsed_domains = toset(distinct([
    for path, meta in local.parsed_functions : meta.domain
  ]))
}