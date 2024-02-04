variable "enable_cert_manager" {
  type        = bool
  description = "If enabled, cert-manager Helm chart and IAM role will be deployed."
  default     = false
}

variable "cert_manager_version" {
  type        = string
  description = "The version of cert-manager to deploy."
  default     = null
}

variable "cert_manager_namespace" {
  type        = string
  description = "The namespace of cert-manager to deployment."
  default     = null
}

variable "route_53_hosted_zones" {
  type        = list(any)
  description = "The AWS Route 53 hosted zone for challenges."
  default     = null
}

variable "aws_region" {
  type        = string
  description = "The AWS region for Route 53 hosted zone."
  default     = null
}

variable "letsencrypt_issuer_email" {
  type        = string
  description = "An email address to send issuer problems to."
  default     = null
}

variable "cluster_issuer_names" {
  type        = list(any)
  description = "The name for the ClusterIssuer."
  default     = []
}

variable "cert_manager_role_name" {
  type        = string
  description = "The name for the IAM role for cert-manager."
  default     = null
}

variable "cert_manager_policy_name" {
  type        = string
  description = "The name for the IAM policy for cert-manager."
  default     = null
}

variable "eks_iodc_hash" {
  type        = string
  description = "The Open ID Connect hash from the EKS cluster."
  default     = null
}