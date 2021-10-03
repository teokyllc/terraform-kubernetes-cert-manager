variable "kubeconfig" {
    type = string
    description = "The kubeconfig file from the AKS cluster."
}

variable "cert_manager_namespace" {
    type = string
    description = "The namespace cert-manager will be deployed to."
}
