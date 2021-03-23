#!/usr/bin/env bash

source ./environment.sh

function add_aliyum_k8s_config() {
    for node_ip in ${NODE_IPS[@]}; do
        ssh root@${node_ip} "cat >/etc/yum.repos.d/kubernetes.repo <<EOF
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF"
    done
}

function install_kubeadm_kubelet_kubectl() {
    for node_ip in ${NODE_IPS[@]}; do
        echo ">>> ${node_ip}"
        ssh root@${node_ip} "yum install -y kubelet kubeadm kubectl"
        ssh root@${node_ip} "systemctl enable kubelet"
    done
}

add_aliyum_k8s_config
install_kubeadm_kubelet_kubectl
