resource "aws_iam_role" "cert_manager_role" {
  count              = var.enable_cert_manager ? 1 : 0
  name               = var.cert_manager_role_name
  description        = "IAM role for cert-manager Kubernetes service account."
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "AllowCertManagerServiceAccount"
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/oidc.eks.${var.aws_region}.amazonaws.com/id/${var.eks_iodc_hash}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "oidc.eks.${var.aws_region}.amazonaws.com/id/${var.eks_iodc_hash}:sub" = "system:serviceaccount:${var.cert_manager_namespace}:cert-manager"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "cert_manager_policy" {
  count       = var.enable_cert_manager ? 1 : 0
  name        = var.cert_manager_policy_name
  path        = "/"
  description = "Allows creating records for automated challenges."
  policy      = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "route53:GetChange",
        "Resource" : "arn:aws:route53:::change/*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "route53:ChangeResourceRecordSets",
          "route53:ListResourceRecordSets"
        ],
        "Resource" : formatlist("arn:aws:route53:::hostedzone/%s", var.route_53_hosted_zones)
      },
      {
        "Effect" : "Allow",
        "Action" : "route53:ListHostedZonesByName",
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cert_manager_policy_attachment" {
  count      = var.enable_cert_manager ? 1 : 0
  role       = aws_iam_role.cert_manager_role[0].name
  policy_arn = aws_iam_policy.cert_manager_policy[0].arn
}

resource "helm_release" "cert_manager" {
  count            = var.enable_cert_manager ? 1 : 0
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = var.cert_manager_version
  namespace        = var.cert_manager_namespace
  create_namespace = true
  atomic           = true

  set {
    name  = "installCRDs"
    value = "true"
  }

  set {
    name  = "serviceAccount.annotations.\\eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.cert_manager_role[0].arn
  }
}

resource "kubernetes_manifest" "clusterissuer" {
  count      = length(var.cluster_issuer_names)
  depends_on = [helm_release.cert_manager]
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind" = "ClusterIssuer"
    "metadata" = {
      "name" = var.cluster_issuer_names[count.index]
    }
    "spec" = {
      "acme" = {
        "email" = var.letsencrypt_issuer_email
        "privateKeySecretRef" = {
          "name" = "letsencrypt"
        }
        "server" = "https://acme-v02.api.letsencrypt.org/directory"
        "solvers" = [
          {
            "dns01" = {
              "route53" = {
                "hostedZoneID" = var.route_53_hosted_zones[count.index]
                "region" = var.aws_region
              }
            }
          },
        ]
      }
    }
  }
  field_manager {
    force_conflicts = true
  }
}
