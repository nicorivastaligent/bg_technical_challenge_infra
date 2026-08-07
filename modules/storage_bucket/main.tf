resource "google_storage_bucket" "bucket" {
  name          = var.bucket_name
  location      = var.region
  force_destroy = false
  labels        = var.labels

  uniform_bucket_level_access = true

  versioning {
    enabled = var.versioning_enabled
  }

  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_rules
    content {
      action {
        type = lifecycle_rule.value.action.type
        # Solo ponemos STANDARD si la acción es cambiar de clase. 
        # Si es Delete o Abort, enviamos null.
        storage_class = lifecycle_rule.value.action.type == "SetStorageClass" ? try(lifecycle_rule.value.action.storage_class, "STANDARD") : null
      }
      condition {
        age                   = try(lifecycle_rule.value.condition.age, null)
        created_before        = try(lifecycle_rule.value.condition.created_before, null)
        with_state            = try(lifecycle_rule.value.condition.with_state, null)
        matches_storage_class = try(lifecycle_rule.value.condition.matches_storage_class, null)
        matches_prefix        = try(lifecycle_rule.value.condition.matches_prefix, null)
        matches_suffix        = try(lifecycle_rule.value.condition.matches_suffix, null)
        num_newer_versions    = try(lifecycle_rule.value.condition.num_newer_versions, null)
      }
    }
  }
}
