#!/usr/bin/env bash

source ./environment.sh

function create_config() {
    cat > config.toml <<EOF
version = 2

[plugins]
  [plugins."io.containerd.grpc.v1.cri"]
    sandbox_image = "registry.aliyuncs.com/google_containers/pause:3.9"
    [plugins."io.containerd.grpc.v1.cri".containerd]
      snapshotter = "overlayfs"
      default_runtime_name = "runc"
      [plugins."io.containerd.grpc.v1.cri".containerd.runtimes]
        [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
          runtime_type = "io.containerd.runc.v2"
          [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
            SystemdCgroup = true

[plugins."io.containerd.grpc.v1.cri".registry]
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors]
    [plugins."io.containerd.grpc.v1.cri".registry.mirrors."docker.io"]
      endpoint = ["https://registry.aliyuncs.com"]
    [plugins."io.containerd.grpc.v1.cri".registry.mirrors."k8s.gcr.io"]
      endpoint = ["https://registry.aliyuncs.com/google_containers"]
    [plugins."io.containerd.grpc.v1.cri".registry.mirrors."gcr.io"]
      endpoint = ["https://gcr.mirrors.ustc.edu.cn"]
    [plugins."io.containerd.grpc.v1.cri".registry.mirrors."quay.io"]
      endpoint = ["https://quay.mirrors.ustc.edu.cn"]

[metrics]
  address = "127.0.0.1:1338"
  grpc_histogram = false

[debug]
  level = "info"
EOF
}

function install() {
    for node_ip in ${NODE_IPS[@]}; do
        echo ">>> ${node_ip}"
        ssh root@${node_ip} "yum install -y yum-utils device-mapper-persistent-data lvm2 wget curl"
        ssh root@${node_ip} "sudo yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo"
        ssh root@${node_ip} "yum install -y containerd.io-${CONTAINERD_VERSION}"
        ssh root@${node_ip} "mkdir -p /etc/containerd"
        scp config.toml root@${node_ip}:/etc/containerd/
        ssh root@${node_ip} "systemctl daemon-reexec && systemctl daemon-reload && systemctl enable containerd --now "
    done
}

function check() {
    for node_ip in ${NODE_IPS[@]}; do
        echo ">>> ${node_ip}"
        ssh root@${node_ip} "systemctl status containerd |grep Active"
    done
}

create_config
install
check
