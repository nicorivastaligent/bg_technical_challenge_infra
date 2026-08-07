# GCP Infrastructure - Iowa Census Medallion Pipeline

Infrastructure as Code (IaC) repository built with Terraform to deploy a serverless **Medallion Data Architecture** (Bronze, Silver, Gold) on Google Cloud Platform (GCP).

---

## 🚀 Architecture Overview

This project provisions and manages the GCP infrastructure required for the daily **Iowa Census** ETL data processing pipeline:

1. **Storage Layer (GCS)**:
   - **Bronze Bucket**: Stores raw ingested data files.
   - Additional buckets for Silver and Gold layers as defined in the pipeline modules.

2. **Compute Layer (Cloud Functions v2)**:
   - **Bronze Extract**: Ingests raw Iowa Census data into GCS (`iowa/census/daily/bronze/extract`).
   - **Silver Transform**: Cleans, standardizes, and enriches data (`iowa/census/daily/silver/transform`).
   - **Gold Create**: Aggregates and structures data ready for analytical queries (`iowa/census/daily/gold/create`).

3. **Orchestration Layer (GCP Workflows)**:
   - Orchestrates the execution sequence of the Cloud Functions (Bronze -> Silver -> Gold) securely via OIDC authentication.

4. **Scheduling Layer (Cloud Scheduler)**:
   - Triggers the GCP Workflow on a daily scheduled cron format (`30 12 * * *`).

5. **Security & IAM**:
   - Dedicated Service Accounts (`sa_bronze`, `sa_transform`).
   - Least privilege IAM roles (`roles/run.invoker`, `roles/workflows.invoker`) allowing Cloud Scheduler to invoke Workflows, and Workflows to invoke Cloud Functions.

---

## 📁 Repository Structure

```text
.
├── environments/
│   └── dev/                  # Development environment deployment
│       ├── src/functions/    # Python source code for Cloud Functions v2
│       │   └── iowa/census/daily/
│       │       ├── bronze/extract/
│       │       ├── silver/transform/
│       │       └── gold/create/
│       ├── main.tf           # Terraform root module calling reusable modules
│       ├── locals.tf         # Local naming variables and prefixes
│       ├── variables.tf      # Input variables definition
│       └── terraform.tfvars.example
├── modules/                  # Modular & reusable Terraform components
│   ├── cloudfunction/        # Cloud Functions v2 resource wrapper
│   ├── workflow/             # GCP Workflows definition module
│   ├── scheduler/            # Cloud Scheduler cron trigger module
│   ├── iam/                  # Service Accounts and IAM bindings module
│   ├── storage_bucket/       # Google Cloud Storage bucket module
│   └── bigquery/             # BigQuery dataset & table module
├── docs/                     # Documentation and architecture specs
├── .gitignore                # Ignored patterns (tfstate, .terraform, secrets)
└── README.MD                 # Project documentation
```

---

## 🛠️ Deployment Instructions

### Prerequisites
- [Terraform](https://www.terraform.io/downloads) >= 1.3.0
- Google Cloud SDK (`gcloud`) authenticated with adequate permissions on your target GCP project.

### Steps

1. **Navigate to the target environment directory**:
   ```bash
   cd environments/dev
   ```

2. **Configure input variables**:
   Create a `terraform.tfvars` file based on the provided example:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

3. **Initialize Terraform**:
   ```bash
   terraform init
   ```

4. **Plan and verify infrastructure changes**:
   ```bash
   terraform plan
   ```

5. **Apply configuration**:
   ```bash
   terraform apply
   ```

---

## 🔒 Security & Best Practices

- **State Management**: `terraform.tfstate` and `.terraform/` directories are explicitly ignored by `.gitignore` to prevent sensitive credentials or infrastructure state leakage.
- **Service Accounts**: Cloud Functions and Workflows execute under dedicated Service Accounts with minimal scope permissions instead of default Compute/Cloud Run service accounts.
