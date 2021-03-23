#!/usr/bin/env bash

function create_json() {
    cat >daemon.json <<EOF
{
  "registry-mirrors": ["https://docker.mirrors.ustc.edu.cn","https://hub-mirror.c.163.com"]
}
EOF
}

function install() {

    yum install -y yum-utils device-mapper-persistent-data lvm2
    yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
    yum install -y docker-ce docker-ce-cli containerd.io
    mkdir -p /etc/docker
    cp daemon.json /etc/docker/
    systemctl daemon-reload && systemctl enable docker && systemctl restart docker
}

function check() {
    systemctl status docker | grep Active
}

create_json
install
check
