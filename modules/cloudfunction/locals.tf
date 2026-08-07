locals {
  prefix         = "${var.environment}-${var.client}-${var.project}"
  gcp_project_id = "${var.environment}-${var.client}-${var.project}-gcp"
  function_name  = "${var.environment}-btc-${var.domain}-${var.product}-${var.topic}-${var.layer}-${var.name}"
}
