resource "null_resource" "setup_env" { 
  provisioner "local-exec" { 
    command = <<-EOT
      mkdir ~/.kube || echo "~/.kube already exists"
      echo "${var.aks_kubeconfig}" > ~/.kube/config
    EOT
  }
}

resource "null_resource" "configure_cert_manager" {
  depends_on = [null_resource.setup_env]
  provisioner "local-exec" {
    command = <<-EOT
      kubectl create namespace ${var.cert_manager_namespace}
      helm repo add jetstack https://charts.jetstack.io
      helm repo update
      helm install cert-manager jetstack/cert-manager --namespace ${var.cert_manager_namespace} --values cert-manager-values.yaml
    EOT
  }
}
