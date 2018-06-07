output kubctl_conf_base64 {
  description = "Base64 encoded content for kubectl config file, you can use it to connect to EKS"
  value       = "${base64encode(data.template_file.kubctl_config.rendered)}"
}

output worker_node_sg {
  description = "ID of the security group we created for our worker node, you can use it to filter out the instances that you need"
  value       = "${aws_security_group.worker_node.id}"
}

output aws_auth_map_base64 {
  description = "Base64 encoded content aws authentication file, you might want to update this file later to grant other users/role the permission to access"
  value       = "${base64encode(data.template_file.aws_auth_yaml.rendered)}"
}
