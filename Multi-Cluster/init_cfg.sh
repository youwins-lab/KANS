#!/usr/bin/env bash

echo ">>>> Initial Config Start <<<<"
echo "[TASK 1] Setting Root Password"
printf "qwe123\nqwe123\n" | passwd >/dev/null 2>&1

echo "[TASK 2] Setting Sshd Config"
sed -i "s/^PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config
sed -i "s/^#PermitRootLogin prohibit-password/PermitRootLogin yes/g" /etc/ssh/sshd_config
systemctl restart sshd

echo "[TASK 3] Setting Profile & Bashrc"
echo 'alias vi=vim' >> /etc/profile
echo "sudo su -" >> .bashrc
# Change Timezone
ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime

echo "[TASK 4] Disable AppArmor"
systemctl stop ufw && systemctl disable ufw >/dev/null 2>&1
systemctl stop apparmor && systemctl disable apparmor >/dev/null 2>&1

echo "[TASK 5] Install Packages"
apt update -qq >/dev/null 2>&1
apt-get install sshpass bridge-utils net-tools jq tree resolvconf ngrep ipset wireguard iputils-arping ipvsadm -y -qq >/dev/null 2>&1

echo "[TASK 6] Change DNS Server IP Address"
echo -e "nameserver 1.1.1.1" > /etc/resolvconf/resolv.conf.d/head
resolvconf -u

echo "[TASK 7] Setting Local DNS Using Hosts file"
echo "192.168.10.10 k8s-c1-m" >> /etc/hosts
echo "192.168.20.10 k8s-c2-m" >> /etc/hosts
for (( i=1; i<=$1; i++  )); do echo "192.168.10.10$i k8s-c1-w$i" >> /etc/hosts; done
for (( i=1; i<=$1; i++  )); do echo "192.168.20.10$i k8s-c2-w$i" >> /etc/hosts; done

echo "[TASK 8] Install Docker Engine"
curl -fsSL https://get.docker.com | sh >/dev/null 2>&1
echo 'net.ipv4.conf.lxc*.rp_filter = 0' > /etc/sysctl.d/99-override_cilium_rp_filter.conf
systemctl restart systemd-sysctl >/dev/null 2>&1
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl -p >/dev/null 2>&1
sysctl --system >/dev/null 2>&1

echo "[TASK 9] Change Cgroup Driver Using Systemd"
cat <<EOT > /etc/docker/daemon.json
{"exec-opts": ["native.cgroupdriver=systemd"]}
EOT
systemctl daemon-reload >/dev/null 2>&1
systemctl restart docker

echo "[TASK 10] Disable and turn off SWAP"
swapoff -a

echo "[TASK 11] Install Kubernetes components (kubeadm, kubelet and kubectl) - v1.22.7"
curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg >/dev/null 2>&1
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
apt-get update >/dev/null 2>&1
apt-get install -y kubelet=1.22.7-00 kubectl=1.22.7-00 kubeadm=1.22.7-00 >/dev/null 2>&1
apt-mark hold kubelet kubeadm kubectl >/dev/null 2>&1
systemctl enable kubelet && systemctl start kubelet

echo ">>>> Initial Config End <<<<"