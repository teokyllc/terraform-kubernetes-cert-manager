variable "cert_manager_values_filename" {
    type = string
    description = "The filename for values.yaml."
}

variable "cert_manager_namespace" {
    type = string
    description = "The namespace cert-manager will be deployed to."
}

variable "enable_vault_issuer" {
    type = bool
    description = "Enables a Hashi Vault issuer."
    default = false
}

variable "cert_manager_secret_id" {
    type = string
    description = "The secret id used in the Vault app role."
    default = null
}

variable "cert_manager_role_id" {
    type = string
    description = "The role id used in the Vault app role."
    default = null
}

variable "vault_ca_bundle" {
    type = string
    description = "The CA bundle file where Vault is the root or intermediate CA."
    default = null
}

variable "vault_path" {
    type = string
    description = "The path to the Vault PKI engine."
    default = null
}

variable "vault_server" {
    type = string
    description = "The Vault server URL."
    default = null
}