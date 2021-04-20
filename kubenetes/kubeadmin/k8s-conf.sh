#!/usr/bin/env bash

source ./environment.sh

function mkdir() {
    for node_ip in ${NODE_IPS[@]}; do
        echo ">>> ${node_ip}"
        ssh root@${node_ip} "rm -rf $HOME/.kube"
        ssh root@${node_ip} "mkdir -p $HOME/.kube"
    done
}

function scp_file() {
    for node_ip in ${NODE_IPS[@]}; do
        echo ">>> ${node_ip}"
        scp /etc/kubernetes/admin.conf root@${node_ip}:$HOME/.kube/config
    done
}

function chn() {
    for node_ip in ${NODE_IPS[@]}; do
        echo ">>> ${node_ip}"
        ssh root@${node_ip} "sudo chown $(id -u):$(id -g) $HOME/.kube/config"
    done
}

function check_k8s() {
    for node_ip in ${NODE_IPS[@]}; do
        echo ">>> ${node_ip}"
        ssh root@${node_ip} "kubectl get pod"
    done
}

mkdir
scp_file
chn
check_k8s
