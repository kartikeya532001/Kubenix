# -------------------------
# IAM Role for Cluster Autoscaler
# -------------------------
module "eks_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.39.0"

  role_name = "${var.cluster_name}-cluster-autoscaler"

  attach_cluster_autoscaler_policy = true
  cluster_autoscaler_cluster_names = [var.cluster_name]

  oidc_providers = {
    eks = {
      provider_arn = module.eks.oidc_provider_arn
      namespace_service_accounts = [
        "kube-system:cluster-autoscaler"
      ]
    }
  }

  depends_on = [module.eks]
}

# -------------------------
# IAM Policy for ALB Controller
# -------------------------
resource "aws_iam_policy" "alb_controller" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  description = "IAM policy for AWS Load Balancer Controller"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "acm:DescribeCertificate",
          "iam:CreateServiceLinkedRole",
          "ec2:GetSecurityGroupsForVpc",
          "iam:GetRole",
          "tag:GetResources",
          "acm:ListCertificates",
          "acm:GetCertificate",
          "tag:GetTags",
          "ec2:CreateTags",              
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:CreateSecurityGroup",
          "ec2:DeleteSecurityGroup",
          "ec2:Describe*",
          "ec2:DeleteTags",
          "iam:ListRoles",
          "elasticloadbalancing:*",
          "iam:ListServerCertificates",
          "iam:GetServerCertificate",
          "cognito-idp:DescribeUserPoolClient",
          "waf-regional:GetWebACLForResource",
          "wafv2:GetWebACLForResource",
          "waf:GetWebACL",
          "waf:ListWebACLs",
          "wafv2:GetWebACL",
          "wafv2:ListWebACLs",
          "shield:GetSubscriptionState",
          "shield:DescribeProtection",
          "shield:CreateProtection",
          "shield:DeleteProtection",
          "shield:DescribeSubscription"
        ]
        Resource = "*"
      }
    ]
  })
}

# -------------------------
# IAM Role for ALB Controller (separate from cluster-autoscaler)
# -------------------------
resource "aws_iam_role" "alb_controller" {
  name = "${var.cluster_name}-alb-controller"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = module.eks.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(module.eks.oidc_provider_arn, "arn:aws:iam::996596548896:oidc-provider/", "")}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })
}

# -------------------------
# Attach ALB Policy to ALB Role
# -------------------------
resource "aws_iam_role_policy_attachment" "alb_controller" {
  role       = aws_iam_role.alb_controller.name
  policy_arn = aws_iam_policy.alb_controller.arn
}
