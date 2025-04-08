#!/usr/bin/bash

# Docker 版本号
export CONTAINERD_VERSION=1.6.6

# kubernetes 版本
export K8S_VERSION=1.28.0

# 集群节点数
export NODE_NUM=4

# 集群各机器 IP 数组
export NODE_IPS=(192.168.154.128 192.168.154.129 192.168.154.130)

# 集群各 IP 对应的主机名数组
export NODE_NAMES=(k8s-master k8s-worker1 k8s-worker2)
