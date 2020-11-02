# 使用 Kubeadmin 快速部署 Kubenetes 集群

## 1. 安装要求

* 一台或多台机器, 操作系统  CentOS 7
* CPU: 至少2核 RAM:至少2GB 硬盘:至少30GB
* 集群所有机器之间网络互通, 且都可以访问外网  

## 2. 环境配置

* 根据实际情况修改 `environment.sh` 中的参数配置, 其中 NODE_IPS 数组中的第一台机器将作业集群的 `Master` 主机
* `Master` 主机可以`免密`远程登录其它所有节点

## 3. 开始部署 

* -- 后面表示在哪个节点执行
 
### 1) 执行 `prepare.sh` 系统初始化 -- Master
### 2) 执行 `kubeadmin_kubelet_kubectl` 安装 Kubeadmin Kubelet Kubectl -- Master
### 3) 执行 `docker.sh` 安装 Docker -- Master
### 4) 执行 `master.sh` 初始化 Master 节点 -- Master
### 4) 执行 `kubectl apply -f kube-flannel.yml` 安装 flanner -- Master
### 6) kubeadm join `192.168.110.177`:6443 --token ejvsr4.ymm499ugpgeusxrc     --discovery-token-ca-cert-hash sha256:83e902ce4904156e195c1237b59a8c13853ea5ea0bdeb7cea90ea978d75ecbc0 -- Node
* 参数说明
    - 192.168.110.177 Master Ip
### 7) 执行 `kubectl apply -f kube-metrics.yml` 安装 metrics-server --Master 
### 8) 执行 `kubectl apply -f kube-ingress.yml` 安装 ingress --Master

## 4. 集群验证

* kubectl get node

```shell 
NAME         STATUS   ROLES    AGE     VERSION
k8s-master   Ready    master   2d22h   v1.19.3
k8s-node1    Ready    <none>   2d22h   v1.19.3
k8s-node2    Ready    <none>   2d22h   v1.19.3
```

* kubectl top node
```shell
NAME         CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%   
k8s-master   94m          4%     1611Mi          41%       
k8s-node1    35m          1%     851Mi           22%       
k8s-node2    33m          1%     713Mi           18%  
```

## 5. kubectl 命令自动补全

```shell
yum install -y epel-release bash-completion
source /usr/share/bash-completion/bash_completion
source <(kubectl completion bash)
echo "source <(kubectl completion bash)" >> ~/.bashrc
```


