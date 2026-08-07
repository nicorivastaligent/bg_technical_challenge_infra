# storage_bucket

Terraform module for creating a Google Cloud Storage bucket with optional lifecycle rules, labels, and versioning.

## Requirements

- **Terraform:** >= 1.3.0
- **Google Provider:** >= 7.0.0, < 8.0.0
  - Versión restringida para evitar breaking changes. Usa `google_storage_bucket` que es estable en v7.x

## Usage

```hcl
module "storage_bucket" {
  source   = "../../modules/storage_bucket"
  for_each = toset(["bronze", "silver", "gold"])

  bucket_name = "${local.prefix}-gcs-${each.key}"
  region      = var.region

  labels = {
    client      = var.client
    environment = var.environment
    layer       = each.key
  }

  lifecycle_rules = [
    {
      action    = { type = "Delete" }
      condition = { age = 365 }
    },
    {
      action    = { type = "AbortIncompleteMultipartUpload" }
      condition = { age = 1 }
    }
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `bucket_name` | The name of the GCS bucket | `string` | — | yes |
| `region` | GCP region where the bucket will be created | `string` | — | yes |
| `labels` | Key/value label pairs to assign to the bucket | `map(string)` | `{}` | no |
| `lifecycle_rules` | Lifecycle rules to apply to the bucket | `list(object)` | `[]` | no |
| `versioning_enabled` | Enables object versioning on the bucket. Recommended for data lakes. | `bool` | `false` | no |

## lifecycle_rules structure

Each rule has two fields:

**`action`**
| Field | Type | Values | Required |
|---|---|---|---|
| `type` | `string` | `Delete`, `SetStorageClass`, `AbortIncompleteMultipartUpload` | yes |
| `storage_class` | `string` | `STANDARD`, `NEARLINE`, `COLDLINE`, `ARCHIVE`, `MULTI_REGIONAL`, `REGIONAL` | only if type = `SetStorageClass` |

**`condition`** (all fields optional)
| Field | Type | Description |
|---|---|---|
| `age` | `number` (integer) | Days since object creation |
| `created_before` | `string` | Date in `YYYY-MM-DD` format |
| `with_state` | `string` | `LIVE`, `ARCHIVED` or `ANY` |
| `matches_storage_class` | `list(string)` | Matches objects in these storage classes |
| `matches_prefix` | `list(string)` | Matches objects whose name starts with any of these prefixes |
| `matches_suffix` | `list(string)` | Matches objects whose name ends with any of these suffixes |
| `num_newer_versions` | `number` (integer) | Matches objects with at least this many newer versions |

## Outputs

| Name | Description |
|------|-------------|
| `bucket_name` | The name of the created bucket |
| `bucket_url` | The URI of the created bucket (`gs://...`) |

## Naming convention

```
{environment}-{client}-{project}-gcs-{layer}
```

Example: `dev-taligent-data-platform-gcs-gold`
