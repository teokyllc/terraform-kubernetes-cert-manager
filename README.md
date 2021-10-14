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

## Removing the helm chart
Use the following command to remove the chart.<br
```
helm --namespace cert-manager delete cert-manager
kubectl delete namespace cert-manager                                    
```
