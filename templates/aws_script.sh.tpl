#!/bin/bash -xe

# This script is from the CloudFormation template in 
# https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-06-05/amazon-eks-nodegroup.yaml

# Global settings
CA_CERTIFICATE_DIRECTORY=/etc/kubernetes/pki
CA_CERTIFICATE_FILE_PATH=$CA_CERTIFICATE_DIRECTORY/ca.crt
mkdir -p $CA_CERTIFICATE_DIRECTORY

# Authenticatoin
echo "${cluster_auth_base64}" | base64 -d >  $CA_CERTIFICATE_FILE_PATH
INTERNAL_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
sed -i s,MASTER_ENDPOINT,${endpoint},g /var/lib/kubelet/kubeconfig
sed -i s,CLUSTER_NAME,${cluster_name},g /var/lib/kubelet/kubeconfig
sed -i s,REGION,${region},g /etc/systemd/system/kubelet.service
sed -i s,MAX_PODS,${max_pod_count},g /etc/systemd/system/kubelet.service
sed -i s,MASTER_ENDPOINT,${endpoint},g /etc/systemd/system/kubelet.service
sed -i s,INTERNAL_IP,$INTERNAL_IP,g /etc/systemd/system/kubelet.service

# DNS cluster ID
DNS_CLUSTER_IP=10.100.0.10
if [[ $INTERNAL_IP == 10.* ]] ; then DNS_CLUSTER_IP=172.20.0.10; fi
sed -i s,DNS_CLUSTER_IP,$DNS_CLUSTER_IP,g /etc/systemd/system/kubelet.service
sed -i s,CERTIFICATE_AUTHORITY_FILE,$CA_CERTIFICATE_FILE_PATH,g /var/lib/kubelet/kubeconfig
sed -i s,CLIENT_CA_FILE,$CA_CERTIFICATE_FILE_PATH,g  /etc/systemd/system/kubelet.service

# Actually start the service to register our instances
systemctl daemon-reload
systemctl restart kubelet
