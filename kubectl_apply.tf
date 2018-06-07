#------------------------------------------------------------------------------
# Various resources to help run applying
#------------------------------------------------------------------------------
resource local_file kubectl_config {
  content  = "${data.template_file.kubctl_config.rendered}"
  filename = "${path.module}/kubectl_config"
  count    = "${var.eks_grant_from_ws? 1 : 0}"
}

resource local_file aws_auth {
  content  = "${data.template_file.aws_auth_yaml.rendered}"
  filename = "${path.module}/aws-auth.yaml"
  count    = "${var.eks_grant_from_ws? 1 : 0}"
}

resource null_resource terraform_apply {
  count = "${var.eks_grant_from_ws? 1 : 0}"

  provisioner local-exec {
    # Bootstrap script called with private_ip of each node in the clutser
    command = "kubectl apply --kubeconfig=${local_file.kubectl_config.filename} -f ${local_file.aws_auth.filename}"
  }
}
