#!/usr/bin/env bash

source ./environment.sh

function init() {
    kubeadm init \
        --apiserver-advertise-address=${NODE_IPS[0]} \
        --image-repository registry.aliyuncs.com/google_containers \
        --kubernetes-version ${K8S_VERSION} \
        --service-cidr=10.96.0.0/12 \
        --pod-network-cidr=10.244.0.0/16 \
        --ignore-preflight-errors=...
}

init
