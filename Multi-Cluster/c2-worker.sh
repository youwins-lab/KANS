#!/usr/bin/env bash

echo ">>>> K8S Node config Start <<<<"

echo "[TASK 1] K8S Controlplane Join - API Server 192.168.20.10" 
kubeadm join --token 123456.1234567890123456 --discovery-token-unsafe-skip-ca-verification 192.168.20.10:6443 >/dev/null 2>&1

echo "[TASK 2] Config kubeconfig" 
mkdir -p $HOME/.kube
sshpass -p "qwe123" scp -o StrictHostKeyChecking=no root@k8s-m:/etc/kubernetes/admin.conf $HOME/.kube/config >/dev/null 2>&1

echo "[TASK 3] Source the completion"
source <(kubectl completion bash)
echo 'source <(kubectl completion bash)' >> /etc/profile

echo "[TASK 4] Alias kubectl to k"
echo 'alias k=kubectl' >> /etc/profile
echo 'complete -F __start_kubectl k' >> /etc/profile

echo "[TASK 5] Install Cilium Cli"
curl -s -L --remote-name-all https://github.com/cilium/cilium-cli/releases/download/v0.10.4/cilium-linux-amd64.tar.gz
tar xzvfC cilium-linux-amd64.tar.gz /usr/local/bin >/dev/null 2>&1
curl -s -L --remote-name-all https://github.com/cilium/hubble/releases/download/v0.9.0/hubble-linux-amd64.tar.gz
tar xzvfC hubble-linux-amd64.tar.gz /usr/local/bin >/dev/null 2>&1

echo ">>>> K8S Node config End <<<<"
