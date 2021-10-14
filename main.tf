resource "null_resource" "setup_env" { 
  provisioner "local-exec" { 
    command = <<-EOT
      mkdir ~/.kube || echo "~/.kube already exists"
      echo "${var.kubeconfig}" > ~/.kube/config
    EOT
  }
}

resource "null_resource" "configure_cert_manager" {
  depends_on = [null_resource.setup_env]
  provisioner "local-exec" {
    command = <<-EOT
      kubectl create namespace ${var.cert_manager_namespace} || echo "namespace already exists"
      helm repo add jetstack https://charts.jetstack.io
      helm repo update
      helm upgrade --install cert-manager jetstack/cert-manager \
        --namespace ${var.cert_manager_namespace} \
        --values https://raw.githubusercontent.com/teokyllc/terraform-kubernetes-cert-manager/main/values.yaml \
        --timeout 10m0s
      sleep 120
    EOT
  }
}

resource "null_resource" "add_cert_manager_vault_role_secret" {
  depends_on = [null_resource.configure_cert_manager]
  provisioner "local-exec" {
    command = <<-EOT
      cat <<EOF | kubectl apply -f -
      apiVersion: v1
      kind: Secret
      type: Opaque
      metadata:
        name: cert-manager-vault-approle
        namespace: ${var.cert_manager_namespace}
      stringData:
        secretId: "${var.cert_manager_secret_id}"
      EOF
    EOT
  }
}

resource "null_resource" "configure_vault_issuer" {
  depends_on = [null_resource.add_cert_manager_vault_role_secret]
  provisioner "local-exec" {
    command = <<-EOT
      cat <<EOF | kubectl apply -f -
      apiVersion: cert-manager.io/v1
      kind: ClusterIssuer
      metadata:
        name: vault-issuer
      spec:
        vault:
          path: pki_int/sign/teokyllc-internal
          server: https://vault.teokyllc.internal:8200
          caBundle: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUhRekNDQlN1Z0F3SUJBZ0lEWXJ0Uk1BMEdDU3FHU0liM0RRRUJEUVVBTUlHeE1SMHdHd1lEVlFRRERCUmoKWVM1MFpXOXJlV3hzWXk1cGJuUmxjbTVoYkRFTE1Ba0dBMVVFQmhNQ1ZWTXhFVEFQQmdOVkJBZ01DRXRsYm5SMQpZMnQ1TVJJd0VBWURWUVFIREFsQ1lYSmtjM1J2ZDI0eEt6QXBCZ05WQkFvTUlsUmhlV3h2Y2lCRmJuUmxjbkJ5CmFYTmxJRzltSUV0bGJuUjFZMnQ1TENCTVRFTXhFVEFQQmdOVkJBc01DSE5sWTNWeWFYUjVNUnd3R2dZSktvWkkKaHZjTkFRa0JGZzF1YjI1bFFHNXZibVV1WTI5dE1CNFhEVEl4TURZeU9ERXlNVGd3TkZvWERUSTJNRFl5TnpFeQpNVGd3TkZvd2diRXhIVEFiQmdOVkJBTU1GR05oTG5SbGIydDViR3hqTG1sdWRHVnlibUZzTVFzd0NRWURWUVFHCkV3SlZVekVSTUE4R0ExVUVDQXdJUzJWdWRIVmphM2t4RWpBUUJnTlZCQWNNQ1VKaGNtUnpkRzkzYmpFck1Da0cKQTFVRUNnd2lWR0Y1Ykc5eUlFVnVkR1Z5Y0hKcGMyVWdiMllnUzJWdWRIVmphM2tzSUV4TVF6RVJNQThHQTFVRQpDd3dJYzJWamRYSnBkSGt4SERBYUJna3Foa2lHOXcwQkNRRVdEVzV2Ym1WQWJtOXVaUzVqYjIwd2dnSWlNQTBHCkNTcUdTSWIzRFFFQkFRVUFBNElDRHdBd2dnSUtBb0lDQVFEQVQyYXExOVJOR0d6WE1xMmo3Z3d1VDJwKzcra3UKa0ZicHVnaFdZMUEwM1dIYUU3dXZFemtJR2xGYlptSDJ4aTFkRUF0L3ZSMitaZGczYU9PcnlmQ0UvUUxKZGFnLwpTM0QvRFkwMW12NEt2SjlpdkhZbE1jeU1vQjdhdXBjZms3UGFVbFVlQmlQS0t2L25KM0EvSDR4d1dLMXlLTUczClZBeUROd0RRYVhmQmZTVVFmajZmU0VsQUJJMXRiT1k5UXFFU2RUdU1ma1Q1cU5SZUg3OG5hZVZVQ3dBckhuczEKT0RZMzkwdG12cE5PcThCTnd0Tk5jellHV1pqcHQvYXJKTnVocG1QdmVCSGVkVFZMUTBGMXJoY1drei9JTkZyWAprN0tXUWpPQjVUb2Fsd1J1ZmI1czN5YS9BRE1rNmN4TTZrYUZzSEVkRXQvWlVtL29zMjhFcjczZkdPSW9lRGdvCkhxRGVXU1FZTCtFaGppZmJqdUw1aTJEY1d3aGpRMWlCNEFmNmhUTVBGalhyTVBLSURpbWZWODZxY2RFNnJsaHQKWmljRnAzTUJnbXRiaEtMamRIY2l0NCsybjdVcndpNmFza0xySWp4T3pOOSt1Ym1vK0FMNmRNbElKeXpyMVJHQgplZWdPR3FjL2FBM3E1L3I1eWpaczlxMjNEREEyQWk5WTRkUmJVaVVRcUd2YmZQMkZtMU52Y2tzbHVkbnZMR0d1Cko4cTVEa3BjeTB5aVVzRkkvdktwa3hVbE1TSldzMEdFTkY5V2FEbERod3FZN1dSeS95ZEdNTFdtK0xRYTZUSUQKckxiRUZScFl3Z2lvNXg1b05PNU1iZUJaaVdnNzMzL3FGSExtY3NkZ3FiK2N4ejk5WWxiMmpnSlZGMk1ydVJwMAo1ZVkrdDRIcFA5UGNHd0lEQVFBQm80SUJZRENDQVZ3d0h3WURWUjBSQkJnd0ZvSVVZMkV1ZEdWdmEzbHNiR011CmFXNTBaWEp1WVd3d0hRWURWUjBPQkJZRUZEQ1orcFZ0bVN1Y054UExmTEM4dGgwN0sxUFVNQThHQTFVZEV3RUIKL3dRRk1BTUJBZjh3Z2VNR0ExVWRJd0VCL3dTQjJEQ0IxWUFVTUpuNmxXMlpLNXczRTh0OHNMeTJIVHNyVTlTaApnYmVrZ2JRd2diRXhIVEFiQmdOVkJBTU1GR05oTG5SbGIydDViR3hqTG1sdWRHVnlibUZzTVFzd0NRWURWUVFHCkV3SlZVekVSTUE4R0ExVUVDQXdJUzJWdWRIVmphM2t4RWpBUUJnTlZCQWNNQ1VKaGNtUnpkRzkzYmpFck1Da0cKQTFVRUNnd2lWR0Y1Ykc5eUlFVnVkR1Z5Y0hKcGMyVWdiMllnUzJWdWRIVmphM2tzSUV4TVF6RVJNQThHQTFVRQpDd3dJYzJWamRYSnBkSGt4SERBYUJna3Foa2lHOXcwQkNRRVdEVzV2Ym1WQWJtOXVaUzVqYjIyQ0EySzdVVEFUCkJnTlZIU1VFRERBS0JnZ3JCZ0VGQlFjREFUQU9CZ05WSFE4QkFmOEVCQU1DQVFZd0RRWUpLb1pJaHZjTkFRRU4KQlFBRGdnSUJBR3lreWVWQ3hBcURGcXZ4bXpYcDhBYmtqbE43eWpKVmtqUjZDSlV2Y0NEd3BuMUxhakpGSlpBQwpEbWlCWUpmTExtQ0FWdnFnb01vYnd6a1JpQWk3cXAxV2hFamJOZlJlUVBpS2hZYjRzVXFPazFQbzRhR2UwandWCkVZR0xHeHZGK0Ntakd0RVMyVk1QM3RQOExFYXN6aGtlNjFncEFEdEdvMVBKZU5kcUhjVW1Pc29Qd2Znb0c4OTYKNVFPMmM3RkV5YUNlNzBvdHZ5VWhEcHVvR2dHamV4NElFTklTNFc0UzJjT0haTTFEUFpCelA0cUNWa2JjM245aQo1WHhGRU4ySWd2NzRzSmVzclV3UU14QU5zdzVUV05Mdjlja2p3anlWdU5qUDlZckROdXBraVR6R0pTTGF3RURxCjZhYlpSbkpOOStqaC9MWjNES2JFU2c4cGFUY09CVFBBamxySW1TbmkvSFRTZ0Jna2JBNmpXT3JYdTc0ZU5CUHgKYW1EMm14RGtRaFFNcEhHa3hNZGVxVzhLQnBqc29BWXpua1RReHFJV3FZUjkvU2JPNXJMN3VybURGdll4OTFudgpndHNPV1ZiZWl4RDRnbHgrMTRJbkx4Q2NKLzNQV0kvajJnN0JUTDlqVk9uWFFJOTZLTlNQUWV2eFpHZ3pnR0ZBCmxMeENPR0RRS2tjdGlIeFlHQzJXY0p6amFNaUNublI3RmZyMnptWDlLY3hCNWtieVJUdUp1UU9ibm5sRHpucloKWDhmdTZWa2xiWk0waDBkVVlUZDEzRk82OW5oWWNPLzdwUHVOMDZNamNjekVCdUlDNFZTK1Zaek5aNFBDWmlUQQpndVJ0bXBTa1dQR3NPb205Ly93YkY5RFlYQlprWWJ1bmd2WHV3U0paNzVmaUtmNHErUGlHCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
          auth:
            appRole:
              path: approle
              roleId: "ade8696a-5452-9219-0b89-e20d820ea1b9"
              secretRef:
                name: cert-manager-vault-approle
                key: secretId
      EOF
    EOT
  }
}
