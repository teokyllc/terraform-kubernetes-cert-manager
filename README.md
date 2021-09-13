# terraform-kubernetes-cert-manager
A Terraform module to deploy cert-manager into Kubernetes cluster using a helm chart.  This project should be run from Terraform Enterprise in a source control workspace.  It is expected that the Azure service principal and the Artifactory credentials are stored as workspace variables.

## Required workspace variables
The following Terraform variables need to be present and populated in the workspace calling this module.<br>
* subscription_id
* aad_tenant_id
* client_id
* client_secret
* registry_username
* registry_password

## Using this module
You will need to place the following files into a git repo that is being used as a Terraform workspace.<br><br>
<b>TF-Workspace\main.tf</b> <br>
```
module "cert-manager" {
  source                 = "app.terraform.io/humana_tfc/cert-manager/kubernetes"
  version                = "1.0.1"
  aks_cluster_name       = "c3p0-pci"
  aks_cluster_rg         = "clusterUser_eastus2-dev-c3p0-PCI-App-RG_c3p0-pci"
  subscription_id        = var.subscription_id
  aad_tenant_id          = var.aad_tenant_id
  client_id              = var.client_id
  client_secret          = var.client_secret
  cert_manager_namespace = "cert-manager"
  cert_manager_version   = "v1.5.3"
  image_path             = "ataylor.jfrog.io/quay-remote/jetstack/cert-manager-controller"
  image_tag              = "v1.5.3"
  replicas               = "1"
  webhook_image_path     = "ataylor.jfrog.io/quay-remote/jetstack/cert-manager-webhook"
  webhook_image_tag      = "v1.5.3"
  cainjector_image_path  = "ataylor.jfrog.io/quay-remote/jetstack/cert-manager-cainjector"
  cainjector_image_tag   = "v1.5.3"
  service_account_name   = "cert-manager-service-account"
  registry_server        = "ataylor.jfrog.io"
  registry_username      = var.registry_username
  registry_password      = var.registry_password
  vault_issuer_path      = "pki_int/sign/teokyllc-internal"
  vault_server           = "https://52.177.243.221:8200"
  vault_ca               = "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUU2RENDQXRDZ0F3SUJBZ0lRVi8rb0FJNFhZaFRBMFNjWjg5cGFEekFOQmdrcWhraUc5dzBCQVFzRkFEQU4KTVFzd0NRWURWUVFERXdKallUQWdGdzB5TVRBNE16RXlNVEF6TlRoYUdBOHlNRFV4TURnek1USXhNVE0xT0ZvdwpEVEVMTUFrR0ExVUVBeE1DWTJFd2dnSWlNQTBHQ1NxR1NJYjNEUUVCQVFVQUE0SUNEd0F3Z2dJS0FvSUNBUUNwCityNEdrelQ0TlhPemhWenBPbUI5R0hKdHNvSWhEdlpSZUlqMVNzNUlpSHR5VTVWcjBCQmMzQ2R6R01JdlNkT1YKZ2t4QjhwOTFlMXM3RHR0aGtIYnVHOTdleFpHWFd5VjJFRll4TFoxUnF2STN0WUNFMEtlRGhpWWgzb2ppN2VNVApCVzlCRGlyUW44MTI5T2t6aFdPdmtyWWsxVCt2bG5pcjZ0Nkp1b0ZTdmhFa2o3bGk5RlkveWF6SDN2QlpzMk9mCjJyVGhpbVRYMm9QT0p6dHRJRGpjdXhkU1ZjWnN0Y3FXQXBFaFVLUWMxUzI1Q3N6L2lmNXhyWVVpR2VwbDVpbEMKVTVHSmxqSmhsS0lyVGt4MDNBOXJKYVcycmlhNFlaS3AxeFBXdkhOVVRjMWJZVUh1c1lveVh2QnduOExlSk5zSgp6SXBJWlJyWGtmVm52TmhXRjVJeUJlV20zQklkNDZacUtOUStQZlBHM0M5YzkxaXBrbFZNM2NEd2VMZGJ2KzVrCk9UaWxiU24xdHYrU0dla0hBZFZjUW53Sk9Yd0dIZjVSaWV6TjdDNmd3a1RBUDYyNVRRNHFYbUNJZUJnMU1oV24KbFN5QS92TVRTWG1Xcm0zRTlBQnBnQTBvZUdIYTNERnNrK3dIUWNGa0h2RGVQeGJmUGppazg4RVc4ekZRU0RObQpBenNJK05SaGplSXNCMkVlaVhDRGE4dGJDM1UzYUF4Z2tlSWxUbVoybk92QWxTS3F1dTFDSHBIa0oxdTVRdGRWCmRFeG9qclhzVEdnKzNYZ3Yvc0s3YkJJQlhScWtOQzFZcXNFdE1ibFV6VlVrbDMzRWljYnR4Ym5xeHBiQUM2WmYKK3pTS1p2OFM3b1hIWHJ6dS9aWGc0NjB0aWNoMDFmei9nS0xCczBuWEtRSURBUUFCbzBJd1FEQU9CZ05WSFE4QgpBZjhFQkFNQ0FxUXdEd1lEVlIwVEFRSC9CQVV3QXdFQi96QWRCZ05WSFE0RUZnUVU1dzFXQmJyaTBkMFk5OHhlCk00OTlJUHJKZ2pzd0RRWUpLb1pJaHZjTkFRRUxCUUFEZ2dJQkFDMHhSaHlBWFhOWTFCNDVmOVZWM3R1cURUMXQKNS9QY2lxZ3BJWU15MGFqVC8vWnR6NmwvekEzempWcVlERWkvNnQxc2hSSzlJZ2FYczU2dDVvZVcrWWJPWWV5egp2VXdLenVHeFlJZmgySXdJd0RQNGwxdmNWem96SzdzSXZFUkNmQUh4L3JHUEZ4UUhxSC9DNFpqV2tjWjNNYlVKCmNvMmV3dXNKWDlsdks4OGlkTGY4YW94bWRxai9KaWFob21hZXhLdUd4YW5lbUJXbkFmcFg2QmNYaWs1RXpWMngKWWU0cVF1YWlSWXRmRnFOdTFqZHorM1ovM3pJY2Q1QURCOXRJRXppWmUyT1ZjVy8zL2l1eEhZckNWNDdVbDZpSApRSVJWVkkvYkZXdDJWRjYyWWRGN0poa1o4VXN1SGNxbzlKeVkrV0dKVk9oWGtiaUVLa3JIM0c4Wmduc0tRNVJ2CnRKeHB6QnBaekk5RFdXTzU5a1RoaHRDbzFyVXo5VkxITTBpMGp1c0ZzY2wvNXY1NzdIQmljSHROeU82YWxGNmoKMkR2dmtZbm4xUGpheExYWDN1LzB5YkR1cXNYVWlQamoyOW4zbkNUUDY0eGpRNXlTTmU4VUlOS2dtREtpaHlmSApXNUE5SlgzM1ZtSGMrMWxaN3ZaVGpaajFJd1pIZmRPVlppc3NCVXhrNjVQTUs0YmY3dzRLV2hKcFpnTkMwbFU3CmdRMzQzNDlDbnBRak5UNG8wekFlOGxQTWJJaTBLbDJmNy9BWVpxbXIrYVNMZ3lEUVVNVWcyYk1qcUw2dGU2Z1IKanFTZEhNak9Fc1lPR0FCMjFocW9vd2diSkZpc0ovUFpYYy94b2Z0QTRReUkwcHFCUE1vMlM4eUtMNnJ0cXFQSQpDZXBrRFpVSG9XNTZNWnRQCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K"
  vault_role             = "pki_int"
}
```
<br><br>
<b>TF-Workspace\variables.tf</b> <br>
```
variable "subscription_id" {
    type = string
    description = "The Azure subscription id."
}

variable "aad_tenant_id" {
    type = string
    description = "The Azure AD tenant id."
}

variable "client_id" {
    type = string
    description = "The Azure service principal client id."
}

variable "client_secret" {
    type = string
    description = "The Azure service principal client secret."
}

variable "registry_username" {
    type = string
    description = "The container registry username."
}

variable "registry_password" {
    type = string
    description = "The container registry password."
}
```

## Configure Kubernetes auth method to Vault
The following steps will configure PKI on a new Vault instance.<br>
```
kubectl -n vault exec --stdin=true --tty=true vault-0 -- /bin/sh

vault auth enable kubernetes

vault write auth/kubernetes/config \
    token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
    kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443" \
    kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt


Get single line cert in base64
cat /var/run/secrets/kubernetes.io/serviceaccount/ca.crt | base64 -w 0


vault write auth/kubernetes/role/issuer \
    policies=pki_int \
    ttl=20m
```

## Removing the helm chart
Use the following command to remove the chart.<br
```
helm --namespace cert-manager delete cert-manager
kubectl delete namespace cert-manager                                    
```
