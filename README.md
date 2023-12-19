# terraform-kubernetes-cert-manager
This is a Terraform module that deploys cert-manager onto Kubernetes via the official Helm chart.  This will also create a ClusterIssuer resoruce after the Helm chart is deployed.<br>
[Cert-Manager](https://cert-manager.io/docs/)<br>
[Cert-Manager ClusterIssuer with Route53](https://cert-manager.io/docs/configuration/acme/dns01/route53/)<br>
[Terraform Helm Release](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release)<br>

## Using specific versions of this module
You can use versioned release tags to ensure that your project using this module does not break when this module is updated in the future.<br>

<b>Repo latest commit</b><br>
```
module "cert-manager" {
  source = "github.com/Medality-Health/terraform-kubernetes-cert-manager"
  ...
```
<br>

<b>Tagged release</b><br>

```
module "cert-manager" {
  source = "github.com/Medality-Health/terraform-kubernetes-cert-manager?ref=1.0"
  ...
```
<br>

## Examples of using this module
This is an example of using this module to deploy cert-manager.<br>

```
module "cert-manager" {
  source                   = "github.com/Medality-Health/terraform-kubernetes-cert-manager?ref=1.0"
  cert_manager_version     = "v1.11.0"
  cert_manager_namespace   = "cert-manager"
  cert_manager_iam_role    = "arn:aws:iam::621672204142:role/mrionline-global-test-cert_manager-irsa"
  route_53_hosted_zones    = ["Z07487492I6J7Q3XR93FJ"]
  aws_region               = "us-east-2"
  letsencrypt_issuer_email = "support@mrionline.com"
  cluster_issuer_name      = "letsencrypt"
}
```

<br><br>
Module can be tested locally:<br>
```
git clone https://github.com/Medality-Health/terraform-kubernetes-cert-manager.git
cd terraform-kubernetes-cert-manager

cat <<EOF > cert-manager.auto.tfvars
cert_manager_version     = "v1.11.0"
cert_manager_namespace   = "cert-manager"
cert_manager_iam_role    = "arn:aws:iam::621672204142:role/mrionline-global-test-cert_manager-irsa"
route_53_hosted_zones    = ["Z07487492I6J7Q3XR93FJ"]
aws_region               = "us-east-2"
letsencrypt_issuer_email = "support@mrionline.com"
cluster_issuer_names     = ["letsencrypt"]
EOF

terraform init
terraform apply
```