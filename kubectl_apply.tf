resource local_file kubectl_config {
  content  = "foo!"
  filename = "${path.module}/foo.bar"
}
