variable "cert_manager_namespace" {
    type = string
    description = "The namespace cert-manager will be deployed to."
}

variable "enable_vault_issuer" {
    type = bool
    description = "Enables a Hashi Vault issuer."
}

variable "cert_manager_secret_id" {
    type = string
    description = "The secret id used in the Vault app role."
}

variable "cert_manager_role_id" {
    type = string
    description = "The role id used in the Vault app role."
}

variable "vault_ca_bundle" {
    type = string
    description = "The CA bundle file where Vault is the root or intermediate CA."
}

variable "vault_path" {
    type = string
    description = "The path to the Vault PKI engine."
}

variable "vault_server" {
    type = string
    description = "The Vault server URL."
}