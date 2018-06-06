#------------------------------------------------------------------------------
# IAM role for EKS to run
#------------------------------------------------------------------------------
resource aws_iam_role eks {
  name        = "EKS-${var.eks_cluster_name}"
  description = "An IAM role to grant EKS access to our Account and perform its magic with our cluster ${var.eks_cluster_name}"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource aws_iam_role_policy_attachment eksAmazonEKSClusterPolicy {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.eks.name}"
}

resource aws_iam_role_policy_attachment eksAmazonEKSServicePolicy {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.eks.name}"
}
