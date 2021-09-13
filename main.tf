resource "null_resource" "setup_env" { 
  provisioner "local-exec" { 
    command = <<-EOT
      # Add bins
      wget https://get.helm.sh/helm-v3.6.3-linux-amd64.tar.gz
      tar -xzvf helm-v3.6.3-linux-amd64.tar.gz
      mv linux-amd64/helm .
      curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
      chmod +x kubectl
      
      # Create kubeconfig
      mkdir ~/.kube || echo "~/.kube already exists"
      echo "${var.aks_kubeconfig}" > ~/.kube/config
    EOT
  }
}

resource "null_resource" "configure_cert_manager" {
  depends_on = [null_resource.setup_env]
  provisioner "local-exec" {
    command = <<-EOT
      ./kubectl create namespace ${var.cert_manager_namespace}
      ./kubectl create secret docker-registry artifactory-access \
        --namespace ${var.cert_manager_namespace} \
        --docker-server=${var.registry_server} \
        --docker-username=${var.registry_username} \
        --docker-password=${var.registry_password}
      ./helm repo add jetstack https://charts.jetstack.io
      ./helm repo update
      ./helm install cert-manager jetstack/cert-manager \
        --namespace ${var.cert_manager_namespace} \
        --version ${var.cert_manager_version} \
        --set installCRDs=true \
        --set image.repository=${var.image_path} \
        --set image.tag=${var.image_tag} \
        --set image.replicaCount=${var.replicas} \
        --set global.imagePullSecrets[0].name="artifactory-access" \
        --set serviceAccount.name=${var.service_account_name} \
        --set webhook.image.repository=${var.webhook_image_path} \
        --set webhook.image.tag=${var.webhook_image_tag} \
        --set webhook.serviceType="ClusterIP" \
        --set cainjector.image.repository=${var.cainjector_image_path} \
        --set cainjector.image.tag=${var.cainjector_image_tag}    
    EOT
  }
}

resource "null_resource" "configure_cert_manager_vault_issuer" {
  depends_on = [null_resource.configure_cert_manager]
  provisioner "local-exec" {
    command = <<-EOT
      b64token=$(echo "$VAULT_TOKEN" | base64)
      cat <<EOF | ./kubectl apply -f -
      apiVersion: v1
      kind: Secret
      type: Opaque
      metadata:
        name: cert-manager-vault-token
        namespace: cert-manager
      data:
        token: $b64token
      ---         
      apiVersion: cert-manager.io/v1
      kind: ClusterIssuer
      metadata:
        name: vault-issuer
      spec:
        vault:
          path: ${var.vault_issuer_path}
          server: $VAULT_ADDR
          caBundle: ${var.vault_tls_cert_ca}
          auth:
            tokenSecretRef:
                name: cert-manager-vault-token
                key: token
      EOF
    EOT
  }
}
