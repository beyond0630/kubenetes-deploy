#!/usr/bin/env bash

source ./environment.sh

function init() {
    kubeadm init \
        --apiserver-advertise-address=${NODE_IPS[0]} \
        --image-repository registry.aliyuncs.com/google_containers \
        --kubernetes-version ${VERSION} \
        --service-cidr=30.96.0.0/12 \
        --pod-network-cidr=30.244.0.0/16
}

init
