#!/usr/bin/env bash

# 删除所有容器和关联的卷
docker rm -fv $(docker ps -aq)

# 卸载由 K8S 挂载的文件系统 (系统重启后也会清除)
for mount_path in $(mount | grep tmpfs | grep '/var/lib/kubelet' | awk '{ print $3 }')
    do umount ${mount_path}
done

# 删除各组件的配置文件和数据
rm -rf /etc/ceph \
       /etc/cni \
       /etc/kubernetes \
       /opt/cni \
       /opt/rke \
       /run/calico \
       /run/flannel \
       /run/secrets/kubernetes.io \
       /var/lib/calico \
       /var/lib/cni \
       /var/lib/etcd \
       /var/lib/kubelet \
       /var/lib/rancher \
       /var/log/containers \
       /var/log/pods \
       /var/log/kube-audit

# 删除网络插件生成的网卡，这里用的 flannel，不同网络插件可能不一样 (系统重启后也会清除)
ip link delete cni0
ip link delete flannel.1

# 清除所有 iptables 规则
iptables --flush
iptables --delete-chain

# 重启防火墙和 Docker，自动添加 iptables 规则
systemctl restart firewalld
systemctl restart docker
