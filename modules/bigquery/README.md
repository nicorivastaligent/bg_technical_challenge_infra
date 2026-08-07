# Module: BigQuery

Crea un dataset por dominio y tablas externas en BigQuery apuntando a los archivos Parquet de la capa gold en GCS, exponiéndolos para su consumo por herramientas de visualización como Qlik.

## Requisitos

- **Terraform:** >= 1.0
- **Google Provider:** >= 7.0.0, < 8.0.0
  - Versión restringida para evitar breaking changes. Usa `google_bigquery_table` con `external_data_configuration` que es estable en v7.x

## Arquitectura

```
GCS (bucket gold)
  finanzas/ventas/customers.parquet ──► BigQuery dataset: dev_taligent_coe_data_finanzas_gold
  finanzas/ventas/sales.parquet     ──►   tabla: dev_taligent_coe_data_finanzas_ventas_customers
                                          tabla: dev_taligent_coe_data_finanzas_ventas_sales
                                                        │
                                                       Qlik
```

La detección de archivos es automática: Terraform escanea el bucket gold, parsea los paths `{domain}/{product}/{tabla}.parquet` y crea un dataset por dominio con una tabla externa por archivo.

## Estructura esperada del bucket gold

```
{bucket-gold}/
  {domain}/{product}/{tabla}.parquet
```

Ejemplo:
```
dev-taligent-coe-data-gold/
  finanzas/ventas/customers.parquet
  finanzas/ventas/sales.parquet
  rrhh/nomina/empleados.parquet
```

## Uso

```hcl
module "bigquery_gold" {
  source = "../../modules/bigquery"

  client      = "taligent"
  project     = "coe-data"
  environment = "dev"
  region      = "us-central1"

  domain  = "finanzas"
  product = "ventas"
  name    = "customers"

  dataset_id       = "dev_taligent_data_platform_gold"
  gold_bucket_name = "dev-taligent-data-platform-gcs-gold"
  gold_path_prefix = "rrhh/nomina/daily/gold/empleados"
  gcp_project_id   = "dev-taligent-data-platform-gcp"
}
```

## Recursos creados

| Recurso | Descripción |
|---|---|
| `google_bigquery_dataset.gold` | Un dataset por dominio detectado en el bucket gold |
| `google_bigquery_table.gold_external` | Una tabla externa por archivo Parquet encontrado |

## Variables

| Nombre | Descripción | Tipo | Requerido |
|---|---|---|---|
| `client` | Nombre del cliente | `string` | Sí |
| `project` | Nombre del proyecto | `string` | Sí |
| `environment` | Ambiente (dev, test, prod) | `string` | Sí |
| `region` | Región GCP | `string` | Sí |
| `domain` | Dominio del dato (ej. finanzas) | `string` | Sí |
| `product` | Producto (ej. ventas) | `string` | Sí |
| `name` | Nombre de la tabla, coincide con el archivo sin `.parquet` | `string` | Sí |
| `dataset_id` | ID del dataset de BigQuery donde se crea la tabla | `string` | Sí |
| `gold_bucket_name` | Nombre del bucket GCS con los Parquet gold | `string` | Sí |
| `gold_path_prefix` | Ruta dentro del bucket hacia los Parquet (patrón: `{domain}/{product}/{topic}/{layer}/{name}`, sin `/` final) | `string` | Sí |
| `gcp_project_id` | ID del proyecto GCP donde se crearán los recursos | `string` | Sí |

## Outputs

| Nombre | Descripción |
|---|---|
| `gold_table_id` | ID de la tabla externa gold creada |

## Convención de nombres

Los datasets y tablas se nombran automáticamente combinando las variables de contexto:

```
dataset: {environment}_{client}_{project}_{domain}_gold
tabla:   {environment}_{client}_{project}_{domain}_{product}_{name}
```

Ejemplo:
```
dataset: dev_taligent_coe_data_finanzas_gold
tabla:   dev_taligent_coe_data_finanzas_ventas_customers
```
