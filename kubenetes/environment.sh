#!/usr/bin/bash

# 集群节点数
export NODE_NUM=3

# 集群各机器 IP 数组
export NODE_IPS=(192.168.110.177 192.168.110.178 192.168.110.180)

# 集群各 IP 对应的主机名数组
export NODE_NAMES=(k8s-master k8s-node1 k8s-node2)
