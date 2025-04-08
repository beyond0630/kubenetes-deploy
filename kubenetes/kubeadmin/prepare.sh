#!/usr/bin/env bash

source ./environment.sh

function set_hostname() {
    echo "================ set hostname"

    for ((i = 0; i < ${NODE_NUM}; i++)); do
        echo ">>> ${NODE_IPS[i]} ${NODE_NAMES[i]}"
        ssh root@${NODE_IPS[i]} "hostnamectl set-hostname ${NODE_NAMES[i]} && hostnamectl status | grep Static"
    done
}

function modify_hosts() {
    for ((i = 0; i < ${NODE_NUM}; i++)); do
        echo ">>> ${NODE_IPS[i]} ${NODE_NAMES[i]}"
        for node_ip in ${NODE_IPS[@]}; do
            ssh root@${node_ip} "echo ${NODE_IPS[i]} ${NODE_NAMES[i]} >>/etc/hosts"
        done
    done

    for node_ip in ${NODE_IPS[@]}; do
        ssh root@${node_ip} "ping k8s-master -c 2"
        ssh root@${node_ip} "ping k8s-node1 -c 2"
        ssh root@${node_ip} "ping k8s-node2 -c 2"
    done
}

function stop_firewalld() {
    echo "================ stop firewalld"
    for node_ip in ${NODE_IPS[@]}; do
        echo ">> ${node_ip}"
        ssh root@${node_ip} "systemctl stop firewalld && systemctl disable firewalld && systemctl status firewalld | grep Active"
    done
}

function close_selinux() {
    echo "================ close selinux"
    for node_ip in ${NODE_IPS[@]}; do
        echo ">> ${node_ip}"
        ssh root@${node_ip} "sed -i 's/enforcing/disabled/' /etc/selinux/config && setenforce 0 "
    done
}

function close_swap() {
    echo "================ close swap"
    for node_ip in ${NODE_IPS[@]}; do
        echo ">> ${node_ip}"
        ssh root@${node_ip} "sed -ri 's/.*swap.*/#&/' /etc/fstab && swapoff -a "
    done
}

function set_iptables() {
    echo "================ set iptables"
    for node_ip in ${NODE_IPS[@]}; do
        echo ">> ${node_ip}"
        ssh root@${node_ip} "cat > /etc/sysctl.d/k8s.conf << EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF"
        ssh root@${node_ip} "sysctl --system"
        ssh root@${node_ip} "echo 1 > /proc/sys/net/bridge/bridge-nf-call-iptables"
        ssh root@${node_ip} "echo 'net.bridge.bridge-nf-call-iptables = 1' >> /etc/sysctl.conf"
        ssh root@${node_ip} "sysctl -p"
    done
}

function flush_time() {
    echo "================ flush time"
    for node_ip in ${NODE_IPS[@]}; do
        echo ">> ${node_ip}"
        ssh root@${node_ip} "yum install ntpdate -y && ntpdate time.windows.com"
    done
}

set_hostname
modify_hosts
stop_firewalld
close_selinux
close_swap
set_iptables
flush_time
