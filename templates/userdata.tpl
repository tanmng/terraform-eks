#cloud-config
write_files:
  - path: /root/aws-auth-cm.yaml
    permissions: '0644'
    owner: root:root
    encoding: base64
    content: |
      ${ aws_auth_base64 }
  - path: /root/script.sh
    permissions: '0700'
    owner: root:root
    encoding: base64
    content: |
      ${ boot_script_base64 }

runcmd:
  - /root/script.sh >> /root/logs
  - kubectl apply -f /root/aws-auth-cm.yaml
