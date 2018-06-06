#------------------------------------------------------------------------------
# The actual EKS cluster
#------------------------------------------------------------------------------
resource aws_eks_cluster main {
  name     = "${var.eks_cluster_name}"
  role_arn = "${aws_iam_role.eks.arn}"

  vpc_config {
    subnet_ids         = ["${var.eks_subnets}"]
    security_group_ids = ["${aws_security_group.control_plane.id}"]
  }

  depends_on = [
    "aws_iam_role_policy_attachment.eksAmazonEKSClusterPolicy",
    "aws_iam_role_policy_attachment.eksAmazonEKSServicePolicy",
  ]
}
