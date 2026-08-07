variable "bucket_name" {
  description = "The name of the Google Cloud Storage bucket."
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9_-]{1,61}[a-z0-9]$", var.bucket_name))
    error_message = "Bucket name must be lowercase, between 3 and 63 characters, and only contain letters, numbers, hyphens, or underscores."
  }
}

variable "lifecycle_rules" {
  description = "Lifecycle rules to apply to the bucket."
  type = list(object({
    action = object({
      type          = string
      storage_class = optional(string)
    })
    condition = object({
      age                   = optional(number)
      created_before        = optional(string)
      with_state            = optional(string)
      matches_storage_class = optional(list(string))
      matches_prefix        = optional(list(string))
      matches_suffix        = optional(list(string))
      num_newer_versions    = optional(number)
    })
  }))
  default = []
  validation {
    condition = alltrue([
      for rule in var.lifecycle_rules :
      try(rule.condition.age == floor(rule.condition.age), true)
    ])
    error_message = "El campo 'age' debe ser un número entero de días."
  }
  validation {
    condition = alltrue([
      for rule in var.lifecycle_rules :
      try(rule.condition.num_newer_versions == floor(rule.condition.num_newer_versions), true)
    ])
    error_message = "El campo 'num_newer_versions' debe ser un número entero."
  }
  validation {
    condition = alltrue([
      for rule in var.lifecycle_rules :
      rule.condition.created_before == null || can(regex("^\\d{4}-\\d{2}-\\d{2}$", rule.condition.created_before))
    ])
    error_message = "El campo 'created_before' debe tener formato YYYY-MM-DD."
  }
  validation {
    condition = alltrue([
      for rule in var.lifecycle_rules :
      rule.action.type == null || contains(["Delete", "SetStorageClass", "AbortIncompleteMultipartUpload"], rule.action.type)
    ])
    error_message = "El campo 'action.type' debe ser 'Delete', 'SetStorageClass' o 'AbortIncompleteMultipartUpload'."
  }
  validation {
    condition = alltrue([
      for rule in var.lifecycle_rules :
      try(rule.action.storage_class != null, false) ? contains(["STANDARD", "NEARLINE", "COLDLINE", "ARCHIVE", "MULTI_REGIONAL", "REGIONAL"], rule.action.storage_class) : true
    ])
    error_message = "El campo 'action.storage_class' debe ser uno de: STANDARD, NEARLINE, COLDLINE, ARCHIVE, MULTI_REGIONAL, REGIONAL."
  }
  validation {
    condition = alltrue([
      for rule in var.lifecycle_rules :
      try(rule.condition.with_state != null, false) ? contains(["LIVE", "ARCHIVED", "ANY"], rule.condition.with_state) : true
    ])
    error_message = "El campo 'with_state' debe ser 'LIVE', 'ARCHIVED' o 'ANY'."
  }
  validation {
    condition = alltrue([
      for rule in var.lifecycle_rules :
      try(rule.condition.matches_storage_class != null, false) ? alltrue([
        for sc in rule.condition.matches_storage_class :
        contains(["STANDARD", "NEARLINE", "COLDLINE", "ARCHIVE", "MULTI_REGIONAL", "REGIONAL", "DURABLE_REDUCED_AVAILABILITY"], sc)
      ]) : true
    ])
    error_message = "El campo 'matches_storage_class' solo admite: STANDARD, NEARLINE, COLDLINE, ARCHIVE, MULTI_REGIONAL, REGIONAL, DURABLE_REDUCED_AVAILABILITY."
  }
  validation {
    condition = alltrue([
      for rule in var.lifecycle_rules :
      try(rule.condition.matches_prefix != null, false) ? alltrue([
        for p in rule.condition.matches_prefix : length(p) > 0
      ]) : true
    ])
    error_message = "El campo 'matches_prefix' no puede contener strings vacíos."
  }
  validation {
    condition = alltrue([
      for rule in var.lifecycle_rules :
      try(rule.condition.matches_suffix != null, false) ? alltrue([
        for s in rule.condition.matches_suffix : length(s) > 0
      ]) : true
    ])
    error_message = "El campo 'matches_suffix' no puede contener strings vacíos."
  }
}

variable "versioning_enabled" {
  description = "Habilita el versionado de objetos en el bucket. Recomendado para data lakes."
  type        = bool
  default     = false
}

variable "labels" {
  description = "A set of key/value label pairs to assign to the bucket."
  type        = map(string)
  default     = {}
}

variable "region" {
  description = "GCP region donde se creará el bucket (ej. US, us-central1, europe-west1). Ver regiones disponibles: https://cloud.google.com/storage/docs/locations"
  type        = string
  validation {
    # Agregamos ^(US|EU|ASIA| ... )$ para permitir multiregiones, o el formato clásico
    condition     = can(regex("^(US|EU|ASIA|[a-z]+-[a-z]+[0-9]+(-[a-z]+)?)$", var.region))
    error_message = "El valor no tiene formato de región GCP válida. Ejemplos: US, EU, us-central1, europe-west1."
  }
}
