variable "aks_kubeconfig" {
    type = string
    description = "The kubeconfig file from the AKS cluster."
}

variable "cert_manager_namespace" {
    type = string
    description = "The namespace cert-manager will be deployed to."
}

variable "cert_manager_version" {
    type = string
    description = "The version of cert-manager to deploy."
}

variable "image_path" {
    type = string
    description = "The path to the cert-manager container image."
}

variable "image_tag" {
    type = string
    description = "The cert-manager container image tag."
}

variable "webhook_image_path" {
    type = string
    description = "The path to the cert-manager webhook container image."
}

variable "webhook_image_tag" {
    type = string
    description = "The cert-manager webhook container image tag."
}

variable "cainjector_image_path" {
    type = string
    description = "The path to the cert-manager cainjector container image."
}

variable "cainjector_image_tag" {
    type = string
    description = "The cert-manager cainjector container image tag."
}

variable "replicas" {
    type = string
    description = "The number of replicas."
}

variable "service_account_name" {
    type = string
    description = "The name of a service account."
}

variable "vault_tls_cert_ca" {
    type = string
    description = "Base64 encoded CA cert used to issue Vault TLS certificate."
}

variable "vault_issuer_path" {
    type = string
    description = "The Vault path to the PKI secret engine."
}

variable "vault_role" {
    type = string
    description = "The Vault role being used for PKI."
}

variable "registry_server" {
    type = string
    description = "The container registery server."
}

variable "registry_username" {
    type = string
    description = "The container registry username."
}

variable "registry_password" {
    type = string
    description = "The container registry password."
}

variable "aks_cluster_name" {
    type = string
    description = "The name of the AKS cluster to apply ArgoCD to."
}

variable "aks_cluster_rg" {
    type = string
    description = "The name of the resource group the AKS cluster is in."
}
