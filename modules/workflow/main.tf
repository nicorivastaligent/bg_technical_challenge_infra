resource "google_workflows_workflow" "workflow" {
    name = var.workflow_name
    project = var.project_id
    region = var.region
    description = var.description
    service_account = var.service_account_email

    source_contents = yamlencode({
        main = {
            steps = [
                for step in var.steps : {
                    "${step.name}" = {
                        call = "http.get"
                        args = {
                            url = step.url
                            auth = {
                                type = "OIDC"
                            }
                        }
                        result = "${step.name}_result"
                    }
                }
            ]
        }
    })
}