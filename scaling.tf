#---------------------------------------------------------------
# eks Autoscaling Group
#---------------------------------------------------------------
resource aws_autoscaling_group eks_asg {
  name                 = "eks-worker-cluster-${var.eks_cluster_name}-${var.eks_tag_environment}"
  vpc_zone_identifier  = ["${var.eks_subnets}"]
  launch_configuration = "${aws_launch_configuration.eks_lc.id}"
  max_size             = "${var.eks_workernode_asg_max}"
  min_size             = "${var.eks_workernode_asg_min}"
  desired_capacity     = "${var.eks_workernode_asg_desired_size}"
  health_check_type    = "EC2"

  tags = ["${
    list(
      map("key", "Name",
          "value", "eks-worker-cluster-${var.eks_cluster_name}-${var.eks_tag_environment}",
          "propagate_at_launch", true),
      map("key", "Product",        "value", "${var.eks_tag_product}",            "propagate_at_launch", true),
      map("key", "SubProduct",     "value", "${var.eks_tag_sub_product}",        "propagate_at_launch", true),
      map("key", "Contact",        "value", "${var.eks_tag_contact}",            "propagate_at_launch", true),
      map("key", "CostCode",       "value", "${var.eks_tag_cost_code}",          "propagate_at_launch", true),
      map("key", "Environment",    "value", "${var.eks_tag_environment}",        "propagate_at_launch", true),
      map("key", "Description",    "value", "${var.eks_tag_description}",        "propagate_at_launch", true),
      map("key", "Orchestration",  "value", "${var.eks_tag_orchestration}",      "propagate_at_launch", true),
      map("key", "EKSCluster",     "value", "${var.eks_cluster_name}",           "propagate_at_launch", true),
      map("key", "cpm backup",     "value", "${var.eks_tag_cpm_backup}",         "propagate_at_launch", true)
    )
  }"]
}

#---------------------------------------------------------------
# eks Autoscaling Launch Configuration
#---------------------------------------------------------------
resource aws_launch_configuration eks_lc {
  name_prefix   = "eks-lc-${var.eks_cluster_name}-${var.eks_tag_environment}"
  image_id      = "${local.worker_node_ami}"
  instance_type = "${var.eks_instance_type}"
  key_name      = "${var.eks_ec2_key}"

  security_groups = [
    "${distinct(concat(
      list(aws_security_group.worker_node.id),
      var.eks_workernode_additional_sgs
    ))}",
  ]

  user_data            = "${data.template_file.init.rendered}"
  iam_instance_profile = "${aws_iam_instance_profile.worker_node_profile.id}"

  root_block_device {
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
