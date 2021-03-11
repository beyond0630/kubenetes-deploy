#!/usr/bin/env bash

source ./environment.sh



function run() {
    for node_ip in ${NODE_IPS[@]}; do
        echo ">>> ${node_ip}"
        ssh root@${node_ip} "mkdir -p $HOME/.kube && \
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config && \
sudo chown $(id -u):$(id -g) $HOME/.kube/config"
    done
}

function check_k8s() {
    for node_ip in ${NODE_IPS[@]}; do
        echo ">>> ${node_ip}"
        ssh root@${node_ip} "kubectl get pod"
    done
}

run
check_k8s
