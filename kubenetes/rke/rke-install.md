# 使用 RKE 安装 Kubernetes

## 一、准备机器

准备 3 至 6 台机器并安装 CentOS 7 系统，如果机器少，Worker 节点可以和 ControlPlane 共用一台机器，机器的 IP 地址根据实际情况配置。如果是使用虚拟机，可以安装配置好一台后再克隆出多台。

机器规划参考：

| Node      | IP           | Role                  |
|-----------|--------------|-----------------------|
| centos-01 | 172.20.1.101 | etcd,controlplane,rke |
| centos-02 | 172.20.1.102 | etcd,controlplane     |
| centos-03 | 172.20.1.103 | etcd,controlplane     |
| centos-04 | 172.20.1.104 | worker                |
| centos-05 | 172.20.1.105 | worker                |
| centos-06 | 172.20.1.106 | worker                |


## 二、系统环境

参考：[RKE Requirements](https://rancher.com/docs/rke/latest/en/os)

所有会运行 K8S 组件的机器都需要安装和配置。

### 禁用 Swap

1. 修改 `/etc/fstab` 将所有 Swap 相关挂载删除
1. 运行 `swapoff -a` 关闭所有 Swap

### 加载内核模块

运行下面脚本检测模块是否已加载

```bash
for module in br_netfilter ip6_udp_tunnel ip_set ip_set_hash_ip ip_set_hash_net iptable_filter iptable_nat iptable_mangle iptable_raw nf_conntrack_netlink nf_conntrack nf_conntrack_ipv4   nf_defrag_ipv4 nf_nat nf_nat_ipv4 nf_nat_masquerade_ipv4 nfnetlink udp_tunnel veth vxlan x_tables xt_addrtype xt_conntrack xt_comment xt_mark xt_multiport xt_nat xt_recent xt_set  xt_statistic xt_tcpudp;
do
if ! lsmod | grep -q $module; then
    echo "module $module is not present";
fi;
done
```

未加载的模块使用命令 `modprobe {module_name}` 加载，并且需要配置启动自动加载。

### 修改内核参数

1. 修改 `/etc/sysctl.conf` 增加以下内容

    ```conf
    net.ipv4.ip_forward = 1
    net.bridge.bridge-nf-call-iptables = 1
    net.bridge.bridge-nf-call-ip6tables = 1
    ```

1. 运行 `sysctl -p` 重新加载配置

### SSH Server 配置

参照下面配置修改 `/etc/ssh/sshd_config`

```txt
AllowTcpForwarding yes
```

### 安装 Docker

1. 运行由 Rancher 提供的脚本自动完成安装和配置: `curl https://releases.rancher.com/install-docker/18.09.2.sh | sh`
1. 设置 Docker 自动运行: `systemctl enable docker` (备注：上面的脚本没做这个操作)
1. 配置仓库镜像加速镜像下载，修改文件 `/etc/docker/daemon.json`，加入一下内容

    ```json
    {
        "registry-mirrors":[
            "https://docker.mirrors.ustc.edu.cn/",
            "https://hub-mirror.c.163.com/"
        ]
    }
    ```

1. 重启 Docker，`systemctl daemon-reload && systemctl restart docker`
1. 运行 `systemctl status docker` 查看 Docker 的运行状态

### 配置防火墙规则

参照 [RKE Requirements](https://rancher.com/docs/rke/latest/en/os/#ports) 文档配置 firewalld 开放端口，注意不能偷懒关闭 firewalld，因为 RKE 需要使用 iptables 添加过滤规则。

- ETCD 节点入站规则

    ```bash
    firewall-cmd --zone=public --permanent \
        --add-port=2376/tcp \
        --add-port=2379/tcp \
        --add-port=2380/tcp \
        --add-port=8472/udp \
        --add-port=9099/tcp \
        --add-port=10250/tcp
    firewall-cmd --reload
    ```

- ControlPlane 节点入站规则

    ```bash
    firewall-cmd --zone=public --permanent \
        --add-port=80/tcp \
        --add-port=443/tcp \
        --add-port=2376/tcp \
        --add-port=6443/tcp \
        --add-port=8472/udp \
        --add-port=9099/tcp \
        --add-port=10250/tcp \
        --add-port=10254/tcp \
        --add-port=30000-32767/tcp \
        --add-port=30000-32767/udp
    firewall-cmd --reload
    ```

- Worker 节点入站规则

    ```bash
    firewall-cmd --zone=public --permanent \
        --add-port=22/tcp \
        --add-port=3389/tcp \
        --add-port=80/tcp \
        --add-port=443/tcp \
        --add-port=2376/tcp \
        --add-port=8472/udp \
        --add-port=9099/tcp \
        --add-port=10250/tcp \
        --add-port=10254/tcp \
        --add-port=30000-32767/tcp \
        --add-port=30000-32767/udp
    firewall-cmd --reload
    ```

### 配置 RKE 使用的用户

1. 新建用户: `useradd rke`
1. 修改密码: `passwd rke`
1. 将用户加到 `docker` 用户组: `usermod -aG docker rke`
1. 在运行 RKE 的节点生成 SSH 密钥 `ssh-keygen -t rsa`
1. 复制 SSH 密钥到各个节点的机器上 `ssh-copy-id rke@172.20.1.101`

## 三、安装 K8S

参考 [RKE Kubernetes Installation](https://rancher.com/docs/rke/latest/en/installation)

### 下载可执行文件

1. 在 [https://github.com/rancher/rke/releases](https://github.com/rancher/rke/releases) 下载合适的版本，Linux 可选择 `rke_linux-amd64`
1. 文件保存到运行 RKE 的机器上，路径为 `/opt/rke/rke`，赋予执行权限: `chmod +x /opt/rke/rke`，创建符号链接: `ln -sf /opt/rke/rke /usr/bin/rke`

### 生成集群配置文件

1. 切换到 rke 目录 `cd /opt/rke`
1. 运行 `rke config --name cluster.yml`
1. 按照提示逐步输入对应的参数

### 部署 K8S 集群

1. 切换到 rke 目录 `cd /opt/rke`
1. 运行 `rke up`

## 四、安装 kubectl

> 在 RKE 安装节点上操作

1. 添加 yum 仓库

    ```bash
    cat > /etc/yum.repos.d/kubernetes.repo <<EOF
    [kubernetes]
    name=Kubernetes
    baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
    enabled=1
    gpgcheck=1
    repo_gpgcheck=1
    gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
    EOF

    yum clean all
    yum makecache -y
    ```

1. 安装 kubectl，运行 `yum install -y kubectl` (如果提示 GPG 签名验证失败，修改 kubernetes.repo 中的 gpgcheck 值为 0 可暂时解决)
1. 配置 kubectl 的 Bash 自动补全

    1. 安装 bash-completion : `yum install -y bash-completion`
    1. 修改文件 `~/.bashrc` 加入以下内容

        ```bash
        source /usr/share/bash-completion/bash_completion
        source <(kubectl completion bash)
        ```

1. 复制 K8S 集群访问配置文件到用户目录

    ```bash
    mkdir ~/.kube
    cp kube_config_cluster.yml ~/.kube/config
    ```

1. 查看集群的运行状态

    ```bash
    kubectl get node
    kubectl get pod --all-namespaces
    ```

## 其它-准备 RKE 镜像

RKE 镜像下载速度比较慢，会增大部署失败的可能性，所以先在所有节点上拉取镜像再进行 K8S 部署会是个好办法。下面脚本会下载所有可能用到的镜像 (这些镜像能从 rke config 生成的配置文件中找到，不同 RKE 版本镜像也会有所区别，这里以 RKE v1.1.15 为例)。

1. 将下面内容保存为 `rke-images.txt`

    ```txt
    rancher/calico-cni:v3.13.4
    rancher/calico-ctl:v3.13.4
    rancher/calico-kube-controllers:v3.13.4
    rancher/calico-node:v3.13.4
    rancher/calico-pod2daemon-flexvol:v3.13.4
    rancher/cluster-proportional-autoscaler:1.7.1
    rancher/coredns-coredns:1.6.9
    rancher/coreos-etcd:v3.4.3-rancher1
    rancher/coreos-flannel:v0.12.0
    rancher/flannel-cni:v0.3.0-rancher6
    rancher/hyperkube:v1.18.16-rancher1
    rancher/k8s-dns-dnsmasq-nanny:1.15.2
    rancher/k8s-dns-kube-dns:1.15.2
    rancher/k8s-dns-node-cache:1.15.7
    rancher/k8s-dns-sidecar:1.15.2
    rancher/kubelet-pause:v0.1.6
    rancher/metrics-server:v0.3.6
    rancher/nginx-ingress-controller-defaultbackend:1.5-rancher1
    rancher/nginx-ingress-controller:nginx-0.35.0-rancher2
    rancher/pause:3.1
    rancher/rke-tools:v0.1.72
    weaveworks/weave-kube:2.6.4
    weaveworks/weave-npc:2.6.4
    ```

1. 将下面内容保存为 `rke-image-pull.sh`，执行后拉取所有镜像。

    ```bash
    #!/usr/bin/env bash

    log_info() {
        echo -e "\033[36m$1\033[0m"
    }

    for img in $(cat rke-images.txt)
    do
        log_info "Pulling image: ${img}"
        docker pull ${img}
    done
    ```

1. 镜像拉取后可以保存出来，以备后面使用，将下面内容保存为 `rke-image-save.sh`，执行后将所有镜像保存为 tar 文件。

    ```bash
    #!/usr/bin/env bash

    log_info() {
        echo -e "\033[36m$1\033[0m"
    }

    img_dir='./rke-images'
    mkdir -p ${img_dir}

    for img in $(cat rke-images.txt)
    do
        log_info "Saving image: ${img}"
        file_name=$(echo -n ${img} | sed -s "s/\//__/g" | sed -s "s/:/__/g")
        file_path="${img_dir}/${file_name}.tar"
        docker save -o ${file_path} ${img}
    done
    ```

1. 将下面内容保存为 `rke-image-load.sh`，执行后可以将 tar 格式的镜像加载回来。

    ```bash
    #!/usr/bin/env bash

    log_info() {
        echo -e "\033[36m$1\033[0m"
    }

    img_dir='./rke-images'

    for img in $(cat rke-images.txt)
    do
        log_info "Loading image: ${img}"
        file_name=$(echo -n ${img} | sed -s "s/\//__/g" | sed -s "s/:/__/g")
        file_path="${img_dir}/${file_name}.tar"
        docker load -i ${file_path}
    done
    ```

1. 还可以将镜像保存到私有的仓库，将下面内容保存为 `rke-image-upload.sh`

    ```bash
    #!/usr/bin/env bash

    log_info() {
        echo -e "\033[36m$1\033[0m"
    }

    repo="my.registry.io"

    for img in $(cat rke-images.txt)
    do
        log_info "Uploading image: ${img}"
        dst_img="${repo}/${img}"
        docker tag ${img} ${dst_img}
        docker push ${dst_img}
    done
    ```
