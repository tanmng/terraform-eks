#cloud-config
write_files:
  - path: /root/script.sh
    permissions: '0700'
    owner: root:root
    encoding: base64
    content: |
      ${ boot_script_base64 }

runcmd:
  - /root/script.sh
