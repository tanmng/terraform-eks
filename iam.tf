#------------------------------------------------------------------------------
# IAM role for EKS control plane. We allow this from Amazon own's AWS account
#------------------------------------------------------------------------------
resource aws_iam_role eks {
  name        = "EKS-${var.eks_cluster_name}-${var.eks_tag_environment}-${data.aws_region.current.name}"
  description = "An IAM role to grant EKS access to our Account and perform its magic with our cluster ${var.eks_cluster_name} in ${var.global_vpc_id}"

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

#------------------------------------------------------------------------------
# IAM role for our EKS worker node
#------------------------------------------------------------------------------
resource aws_iam_instance_profile worker_node_profile {
  name = "EKS-Worker-Node-${var.eks_cluster_name}-${var.eks_tag_environment}-${data.aws_region.current.name}"
  role = "${aws_iam_role.worker_node.name}"
}

resource aws_iam_role worker_node {
  name        = "EKS-Worker-Node-${var.eks_cluster_name}-${var.eks_tag_environment}-${data.aws_region.current.name}"
  description = "An IAM role to grant our worker node in cluster ${var.eks_cluster_name} access to EKS feature"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

locals {
  # List of managed policies that we should assign to the IAM role of Worker node
  worker_node_managed_policies = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
  ]
}

resource aws_iam_role_policy_attachment worker_node_policy {
  count      = "${length(local.worker_node_managed_policies)}"
  policy_arn = "${element(local.worker_node_managed_policies, count.index)}"
  role       = "${aws_iam_role.worker_node.name}"
}
