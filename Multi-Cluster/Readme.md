# Lab Topology 
<img src="https://github.com/youwins-lab/KANS/blob/main/Multi-Cluster/Topology.png" title="Topology" alt="Topology"></img>

# Lab 배포
```
curl -O https://raw.githubusercontent.com/youwins-lab/KANS/main/Multi-Cluster/Vagrantfile
vagrant up
```
# vagrant 상태 확인
```
vagrant status
```

# vagrant SSH 접속
```
vagrant ssh k8s-c1-m
vagrant ssh k8s-c1-w1
vagrant ssh k8s-c2-m
vagrant ssh k8s-c2-w1
vagrant ssh k8s-rtr
```

# k8s-c1-m에서 BGP를 위한 config-map 생성
```
cat <<EOF | kubectl create -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: bgp-config
  namespace: kube-system
data:
  config.yaml: |
    peers:
      - peer-address: 192.168.10.254
        peer-asn: 64513
        my-asn: 64512
    address-pools:
      - name: default
        protocol: bgp
        avoid-buggy-ips: true
        addresses:
          - 10.10.0.0/16
EOF
```

# k8s-c2-m에서 BGP를 위한 config-map 생성
```
cat <<EOF | kubectl create -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: bgp-config
  namespace: kube-system
data:
  config.yaml: |
    peers:
      - peer-address: 192.168.20.254
        peer-asn: 64513
        my-asn: 64514
    address-pools:
      - name: default
        protocol: bgp
        avoid-buggy-ips: true
        addresses:
          - 10.20.0.0/16
EOF
```


# config 확인
```
kubectl get cm -n kube-system bgp-config
```

# k8s-c1-m에서 설정
```
VERSION=1.11.2
helm upgrade cilium cilium/cilium --version $VERSION \
  --namespace kube-system \
  --reuse-values --set bgp.enabled=true \
  --set bgp.announce.loadbalancerIP=true \
  --set bgp.announce.podCIDR=true \
  --set nodeinit.enabled=true \
  --set kubeProxyReplacement=partial \
  --set hostServices.enabled=false \
  --set externalIPs.enabled=true \
  --set nodePort.enabled=true \
  --set hostPort.enabled=true \
  --set clustermesh.useAPIServer=true \
  --set cluster.name=c1 \
  --set cluster.id=1
```

# k8s-c2-m에서 설정
```
VERSION=1.11.2
helm upgrade cilium cilium/cilium --version $VERSION \
  --namespace kube-system \
  --reuse-values --set bgp.enabled=true \
  --set bgp.announce.loadbalancerIP=true \
  --set bgp.announce.podCIDR=true \
  --set nodeinit.enabled=true \
  --set kubeProxyReplacement=partial \
  --set hostServices.enabled=false \
  --set externalIPs.enabled=true \
  --set nodePort.enabled=true \
  --set hostPort.enabled=true \
  --set clustermesh.useAPIServer=true \
  --set cluster.name=c2 \
  --set cluster.id=2
```

# cilium 파드 재시작
```
kubectl -n kube-system rollout restart ds/cilium
```

# cilium 설정 확인
```
cilium config view | egrep "bgp|cluster"
```

# (옵션) Quagga 에서 라우팅 정보 확인
```
vtysh -c 'show ip route bgp'
vtysh -c 'show ip bgp summary'
vtysh -c 'show running-config'
```


# Clustermesh-apiserver 확인
```
kubectl get pods -l k8s-app=clustermesh-apiserver \
  -o jsonpath='{range .items[*].spec.containers[*]}{.image}{"\n"}{end}'
```

# Cluster1에서 Clustermesh을 위한 secret 추출
```
git clone https://github.com/cilium/cilium.git
cd cilium
contrib/k8s/k8s-extract-clustermesh-nodeport-secret.sh > ../cluster1-secret.json
```

# Cluster2에서 Clustermesh을 위한 secret 추출
```
git clone https://github.com/cilium/cilium.git
cd cilium
contrib/k8s/k8s-extract-clustermesh-nodeport-secret.sh > ../cluster2-secret.json
```

# Cluster1에서 Clustermesh 설정
```
cd ~
scp root@k8s-c2-m:/root/cluster2-secret.json ./
contrib/k8s/k8s-import-clustermesh-secrets.sh cluster2-secret.json
```
