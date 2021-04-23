#!/usr/bin/bash

export VERSION=1.20.5

# 集群节点数
export NODE_NUM=4

# 集群各机器 IP 数组
export NODE_IPS=(172.2.1.100 172.2.1.101 172.2.1.102 172.2.1.103)

# 集群各 IP 对应的主机名数组
export NODE_NAMES=(k8s-master k8s-node1 k8s-node2 k8s-node3)
