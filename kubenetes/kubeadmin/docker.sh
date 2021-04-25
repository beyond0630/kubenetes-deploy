#!/usr/bin/env bash

source ./environment.sh

function create_json() {
    cat >daemon.json <<EOF
{
  "registry-mirrors": ["https://docker.mirrors.ustc.edu.cn","https://hub-mirror.c.163.com"]
}
EOF
}

function install() {
    for node_ip in ${NODE_IPS[@]}; do
        echo ">>> ${node_ip}"
        ssh root@${node_ip} "yum install -y yum-utils device-mapper-persistent-data lvm2"
        ssh root@${node_ip} "sudo yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo"
        ssh root@${node_ip} "yum install  -y docker-ce-${DOCKER_VERSION} docker-ce-cli-${DOCKER_VERSION} containerd.io"
        ssh root@${node_ip} "mkdir -p /etc/docker"
        scp daemon.json root@${node_ip}:/etc/docker/
        ssh root@${node_ip} "systemctl daemon-reload && systemctl enable docker && systemctl restart docker "
    done
}

function check() {
    for node_ip in ${NODE_IPS[@]}; do
        echo ">>> ${node_ip}"
        ssh root@${node_ip} "systemctl status docker |grep Active"
    done
}

create_json
install
check
