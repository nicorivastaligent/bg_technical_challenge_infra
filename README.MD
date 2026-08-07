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

---

## 🗺️ Refactoring Roadmap (Future Enhancements)

To align further with a zero-trust microservices architecture and infrastructure best practices, the following refactoring tasks are planned:

1. **Granular Service Accounts (IAM Separation)**:
   - Create dedicated Service Accounts for **Cloud Scheduler** (`sa_scheduler`), **Workflows** (`sa_workflow`), **Silver Layer** (`sa_silver`), and **Gold Layer** (`sa_gold`) instead of reusing `sa_transform`.

2. **Remote Backend for Terraform State**:
   - Migrate local state management to a central **Google Cloud Storage (GCS) Remote Backend** with state locking via Google Cloud KMS/native locking to enable safe team collaboration and CI/CD execution.

3. **Shared Environment Module (`modules/environment`)**:
   - Refactor repetitive `environments/dev/main.tf` logic into a reusable `environment` module to reduce file duplication across `dev`, `test`, and `prod`.

4. **BigQuery Fine-Grained Permissions & Service Account Scoping**:
   - Restrict dataset/table level IAM access so `sa_gold` only has `BigQuery Data Editor` on the Gold dataset, preventing cross-dataset modifications.

5. **Dedicated Project Setup Module (`modules/project_setup`)**:
   - Extract API activation (`google_project_service`) into a dedicated module to manage project-level prerequisites, API enablement, and org policies independently from application resources.

6. **Secret Manager Integration**:
   - Replace plain environment variables in Cloud Functions with **GCP Secret Manager** references for API keys or connection strings.

7. **Phase 2: Data Governance with Dataplex (`modules/dataplex`)**:
   - Introduce a dedicated Dataplex module to manage Dataplex Lakes, Zones (raw/curated), and Assets for automated metadata discovery, data quality checks, and unified governance across GCS buckets and BigQuery datasets.



