resource "aws_iam_role" "cert_manager_role" {
  name               = var.cert_manager_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = ""
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::621672204142:oidc-provider/oidc.eks.us-east-2.amazonaws.com/id/${var.eks_iodc_hash}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "oidc.eks.us-east-2.amazonaws.com/id/${var.eks_iodc_hash}:sub" = "system:serviceaccount:${var.cert_manager_namespace}:cert-manager"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "cert_manager_policy" {
  name        = var.cert_manager_policy_name
  path        = "/"
  description = var.cert_manager_policy_description
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
  role       = aws_iam_role.cert_manager_role.name
  policy_arn = aws_iam_policy.cert_manager_policy.arn
}

resource "helm_release" "cert_manager" {
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
    value = aws_iam_role.cert_manager_role.arn
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
