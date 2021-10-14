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
