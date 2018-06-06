#------------------------------------------------------------------------------
# Security group and rules to set on to our work nodes and control plane
# https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html
#------------------------------------------------------------------------------

# Control Plane Security Group
resource aws_security_group control_plane {
  name        = "control-plane-${var.eks_cluster_name}-${var.eks_tag_environment}"
  description = "Security group for EC2 instances running the control plane in our EKS cluster ${var.eks_cluster_name}"
  vpc_id      = "${var.global_vpc_id}"

  tags = "${map("Name",          "${join(".",list(var.eks_tag_product, var.eks_tag_environment, "control_plane"))}",
                "Product",       "${var.eks_tag_product}",
                "SubProduct",    "${var.eks_tag_sub_product}",
                "Contact",       "${var.eks_tag_contact}",
                "CostCode",      "${var.eks_tag_cost_code}",
                "Environment",   "${var.eks_tag_environment}",
                "Description",   "security_group_eks_elb",
                "Orchestration", "${var.eks_tag_orchestration}")}"
}

resource aws_security_group_rule allow_ingress_from_worker_node {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.control_plane.id}"
  source_security_group_id = "${aws_security_group.worker_node.id}"
}

resource aws_security_group_rule allow_egress_to_worker_node {
  type                     = "egress"
  from_port                = "${var.eks_cp_to_wn_from_port}"
  to_port                  = "${var.eks_cp_to_wn_to_port}"
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.control_plane.id}"
  source_security_group_id = "${aws_security_group.worker_node.id}"
}

# Worker node security group
resource aws_security_group worker_node {
  name        = "worker-node-${var.eks_cluster_name}-${var.eks_tag_environment}"
  description = "Security group for EC2 instances running the worker node in our EKS cluster ${var.eks_cluster_name}"
  vpc_id      = "${var.global_vpc_id}"

  tags = "${map("Name",          "${join(".",list(var.eks_tag_product, var.eks_tag_environment, "worker_node"))}",
                "Product",       "${var.eks_tag_product}",
                "SubProduct",    "${var.eks_tag_sub_product}",
                "Contact",       "${var.eks_tag_contact}",
                "CostCode",      "${var.eks_tag_cost_code}",
                "Environment",   "${var.eks_tag_environment}",
                "Description",   "Security group for EC2 instances running the worker node in our EKS cluster ${var.eks_cluster_name}",
                "Orchestration", "${var.eks_tag_orchestration}")}"
}

resource aws_security_group_rule worker_node_egress_self {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  security_group_id = "${aws_security_group.control_plane.id}"
  self              = true
  description       = "Inter-worker node traffic"
}

resource aws_security_group_rule worker_node_ingress_self {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  security_group_id = "${aws_security_group.control_plane.id}"
  self              = true
  description       = "Inter-worker node traffic"
}

resource aws_security_group_rule allow_ingress_from_control_plane {
  type                     = "egress"
  from_port                = "${var.eks_cp_to_wn_from_port}"
  to_port                  = "${var.eks_cp_to_wn_to_port}"
  description              = "Allow connection from control plane according to AWS recommendation"
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.worker_node.id}"
  source_security_group_id = "${aws_security_group.control_plane.id}"
}

resource aws_security_group_rule worker_node_https_to_control {
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  description              = "HTTPS to control plane"
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.worker_node.id}"
  source_security_group_id = "${aws_security_group.control_plane.id}"
}

resource aws_security_group_rule worker_node_https_anywhere {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  description       = "HTTPS to anywhere"
  protocol          = "tcp"
  security_group_id = "${aws_security_group.worker_node.id}"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource aws_security_group_rule worker_node_full_egress {
  count             = "${var.eks_allow_worker_node_all_egress? 1 : 0}"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  description       = "Allow Worker node to egress everywhere on any port"
  protocol          = "-1"
  security_group_id = "${aws_security_group.worker_node.id}"
  cidr_blocks       = ["0.0.0.0/0"]
}
