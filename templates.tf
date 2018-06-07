#--------------------------------------------------------------
# EKS Worker node User Data Template
#--------------------------------------------------------------
data template_file init {
  template = "${file("${path.module}/templates/userdata.tpl")}"

  vars {
    aws_auth_base64    = "${base64encode(data.template_file.aws_auth_yaml.rendered)}"
    boot_script_base64 = "${base64encode(data.template_file.aws_script.rendered)}"
  }
}

data template_file aws_auth_yaml {
  template = "${file("${path.module}/templates/aws-auth-cm.yaml.tpl")}"

  vars {
    role_arn = "${aws_iam_role.worker_node.arn}"
  }
}

data template_file aws_script {
  template = "${file("${path.module}/templates/aws_script.sh.tpl")}"

  vars {
    max_pod_count       = "${lookup(local.max_pod_per_node, var.eks_instance_type)}"
    region              = "${data.aws_region.current.name}"
    cluster_name        = "${var.eks_cluster_name}"
    endpoint            = "${aws_eks_cluster.main.endpoint}"
    cluster_auth_base64 = "${aws_eks_cluster.main.certificate_authority.0.data}"
  }
}

# For some reason I can't get output from Local, however much I tried (╯°□°）╯︵ ┻━┻
# Please send help
data template_file kubctl_config {
  template = <<KUBECONFIG
apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.main.endpoint}
    certificate-authority-data: ${aws_eks_cluster.main.certificate_authority.0.data}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: heptio-authenticator-aws
      args:
        - "token"
        - "-i"
        - "${var.eks_cluster_name}"
KUBECONFIG
}
