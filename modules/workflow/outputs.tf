output "workflow_id" {
  value = google_workflows_workflow.workflow.id
}

output "workflow_name" {
  value = google_workflows_workflow.workflow.name
}

# Nueva salida para exponer la URL completa de ejecución
output "execution_uri" {
  description = "The full HTTP target URI to trigger executions of this workflow."
  value       = "https://workflowexecutions.googleapis.com/v1/${google_workflows_workflow.workflow.id}/executions"
}