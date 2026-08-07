locals {
  gold_table_name = replace("${var.environment}_${var.client}_${var.project}_${var.domain}_${var.product}_${var.name}", "-", "_")
}
