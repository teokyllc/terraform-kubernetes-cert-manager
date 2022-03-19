resource "kubernetes_namespace" "cert_manager_ns" {
  metadata {
    name = var.cert_manager_namespace
  }
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "jetstack/cert-manager"
  namespace  = var.cert_manager_namespace
  values     = [
    "${file(var.values_filename)}"
  ]
}

resource "kubernetes_secret" "vault_role_secret" {
  count    = "${var.enable_vault_issuer == true ? 1 : 0}"
  metadata {
    name = "cert-manager-vault-approle"
    namespace = var.cert_manager_namespace
  }
  data = {
    secretId = var.cert_manager_secret_id
  }
  type = "Opaque"
}

resource "kubernetes_manifest" "vault_issuer" {
  count    = "${var.enable_vault_issuer == true ? 1 : 0}"
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind" = "ClusterIssuer"
    "metadata" = {
      "name" = "vault-issuer"
      "namespace" = "${var.cert_manager_namespace}"
    }
    "spec" = {
      "vault" = {
        "auth" = {
          "appRole" = {
            "path" = "approle"
            "roleId" = "${var.cert_manager_role_id}"
            "secretRef" = {
              "key" = "secretId"
              "name" = "cert-manager-vault-approle"
            }
          }
        }
        "caBundle" = "${var.vault_ca_bundle}"
        "path" = "${var.vault_path}"
        "server" = "${var.vault_server}"
      }
    }
  }
}