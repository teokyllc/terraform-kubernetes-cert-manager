# terraform-kubernetes-cert-manager
A Terraform module to deploy cert-manager into Kubernetes cluster using a helm chart.  This module will also configure a Kubernetes secret to hold the <b>SecretId</b> on the AppRole used by the issuer which gets created as well.


## Using this module
Example of using this module.<br><br>
<b>main.tf</b> <br>
```
module "cert_manager" {
  depends_on             = [module.aks]
  source                 = "github.com/teokyllc/terraform-kubernetes-cert-manager"
  kubeconfig             = module.aks.aks_kubeconfig
  cert_manager_namespace = "cert-manager"
  cert_manager_secret_id = var.cert_manager_secret_id
}
```
<br><br>

## Getting the App Role Secret Id
This module creates a Kubernetes secret with the Secret Id for the Vault role used by the cert-manager issuer.  The following command generates a new Secret Id.<br>
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
