# terraform-kubernetes-cert-manager
A Terraform module to deploy cert-manager into Kubernetes cluster using a helm chart.  This module can also configure a Hashicorp Vault certificate issuer.


## Using this module
Example of using this module.<br><br>
<b>main.tf</b> <br>
```
module "cert-manager" {
  source                 = "app.terraform.io/ANET/cert-manager/kubernetes"
  version                = "1.0.4"
  cert_manager_namespace = "cert-manager"
  values_filename        = "cert-manager-values.yaml"
  enable_vault_issuer    = false
}
```
<br><br>

## Getting the App Role Secret Id
This module can create a Kubernetes secret with the Secret Id for the Vault role used by the cert-manager issuer.  The following command generates a new Secret Id on the Vault.<br>
```
vault write -force auth/approle/role/approle-cert-manager/secret-id
```
<br><br>
These commands will list and revoke existing Secret Ids if needed.<br>
```
vault list auth/approle/role/approle-cert-manager/secret-id

vault write auth/approle/role/approle-cert-manager/secret-id/destroy secret_id=143cbb43-09fe-fbd8-0f17-b86f17431686
```

## Removing the helm chart
Use the following command to remove the chart.<br
```
helm --namespace cert-manager delete cert-manager
kubectl delete namespace cert-manager                                    
```
