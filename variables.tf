variable "kubeconfig" {
    type = string
    description = "The kubeconfig file from the AKS cluster."
}

variable "cert_manager_namespace" {
    type = string
    description = "The namespace cert-manager will be deployed to."
}

variable "cert_manager_secret_id" {
    type = string
    description = "The secret id used in the Vault app role."
}
