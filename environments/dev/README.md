# Development Environment

## Resource Naming Convention

Cloud Functions follow this pattern:
```
{environment}-tdp-{domain}-{product}-{topic}-{layer}-function
```

Example: `dev-tdp-rrhh-nomina-daily-bronze-function`

- **environment**: dev, test, prod
- **tdp**: Taligent Data Platform (fixed identifier)
- **domain**: Data domain (e.g., rrhh, finance)
- **product**: Product name (e.g., nomina, payroll)
- **topic**: Execution frequency (e.g., daily, weekly)
- **layer**: Medallion architecture layer (e.g., bronze, silver, gold)

This naming keeps function names concise while maintaining GCP's 63-character limit.

## Deployment Workflow

This environment uses a **two-phase deployment strategy** for discovering and creating BigQuery tables from gold bucket objects.

### Phase 1: Create Infrastructure
Deploy with `discover_gold_objects = false` (default):
```hcl
discover_gold_objects = false
```

This creates:
- Storage buckets (bronze, silver, gold)
- Cloud Functions
- BigQuery dataset

### Phase 2: Discover and Create Tables
After uploading Parquet files to the gold bucket, deploy with `discover_gold_objects = true`:
```hcl
discover_gold_objects = true
```

This discovers objects in the gold bucket and creates corresponding BigQuery external tables.

## Why Two Phases?

The `data.google_storage_bucket_objects` data source depends on the `module.storage_bucket["gold"]` resource. This dependency means:
- During `plan`, Terraform cannot determine which objects exist in the bucket
- The data source is only evaluated during `apply`, after the bucket is created
- `for_each` loops that depend on this data source cannot be evaluated in `plan`

Therefore, attempting to enable `discover_gold_objects = true` before the bucket exists and is populated will fail.

## Usage Example

```bash
# Phase 1: Create buckets and functions (discover_gold_objects = false in tfvars)
terraform apply

# Upload Parquet files to the gold bucket:
# gs://dev-taligent-data-platform-gcs-gold/...

# Phase 2: Create BigQuery tables (discover_gold_objects = true in tfvars)
terraform apply
```

## Technical Debt: File Duplication

**Status:** Accepted deliberately (see CLAUDE.md section 4)

The files `main.tf` and `locals.tf` are **identical across dev/test/prod**. This requires replicating changes in 3 places.

**Why accepted now:**
- Small scope: only 3 environments
- Minimal duplication: ~10 identical lines
- Clear audit trail: changes visible in 3 files
- Easy to navigate: explicit folder per environment

**Future improvement:** Create a `modules/environment` to eliminate duplication (see ClickUp task 86bap7wzc)
