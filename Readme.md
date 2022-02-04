

root@k8s-m:~# calicoctl get bgppeer

root@k8s-m:~# cat <<EOF | calicoctl apply -f -
apiVersion: projectcalico.org/v3
kind: BGPPeer
metadata:
  name: bgppeer
spec:
  peerIP: 192.168.10.254
  asNumber: 64512
EOF






root@k8s-m:~# calicoctl get bgppeer

root@k8s-m:~# cat <<EOF | calicoctl apply -f -
apiVersion: projectcalico.org/v3
kind: BGPPeer
metadata:
  name: bgppeer-m
spec:
  node: k8s-m
  peerIP: 192.168.10.254
  asNumber: 64512
EOF



root@k8s-m:~# cat <<EOF | calicoctl apply -f -
apiVersion: projectcalico.org/v3
kind: BGPPeer
metadata:
  name: bgppeer-w0
spec:
  node: k8s-w0
  peerIP: 192.168.20.254
  asNumber: 64512
EOF



root@k8s-m:~# calicoctl label nodes k8s-m rack=rack1
Successfully set label rack on nodes k8s-m

root@k8s-m:~# calicoctl get node k8s-m --output yaml
apiVersion: projectcalico.org/v3
kind: Node
metadata:
  annotations:
    projectcalico.org/kube-labels: '{"beta.kubernetes.io/arch":"amd64","beta.kubernetes.io/os":"linux","kubernetes.io/arch":"amd64","kubernetes.io/hostname":"k8s-m","kubernetes.io/os":"linux","node-role.kubernetes.io/control-plane":"","node-role.kubernetes.io/master":"","node.kubernetes.io/exclude-from-external-load-balancers":""}'
  creationTimestamp: "2022-02-04T13:35:03Z"
  labels:
    beta.kubernetes.io/arch: amd64
    beta.kubernetes.io/os: linux
    kubernetes.io/arch: amd64
    kubernetes.io/hostname: k8s-m
    kubernetes.io/os: linux
    node-role.kubernetes.io/control-plane: ""
    node-role.kubernetes.io/master: ""
    node.kubernetes.io/exclude-from-external-load-balancers: ""
    rack: rack1
  name: k8s-m
  resourceVersion: "9156"
  uid: 7935beeb-615c-4385-8128-93bc32c3dfb4
spec:
  addresses:
  - address: 192.168.10.10/24
    type: CalicoNodeIP
  - address: 192.168.10.10
    type: InternalIP
  bgp:
    ipv4Address: 192.168.10.10/24
    ipv4IPIPTunnelAddr: 172.16.116.0
  orchRefs:
  - nodeName: k8s-m
    orchestrator: k8s
status:
  podCIDRs:
  - 172.16.0.0/24


root@k8s-m:~# calicoctl label nodes k8s-w1 rack=rack1
Successfully set label rack on nodes k8s-w1
root@k8s-m:~# calicoctl label nodes k8s-w2 rack=rack1
Successfully set label rack on nodes k8s-w2
root@k8s-m:~# calicoctl label nodes k8s-w0 rack=rack2
Successfully set label rack on nodes k8s-w0

root@k8s-m:~# cat <<EOF | calicoctl apply -f -
apiVersion: projectcalico.org/v3
kind: BGPPeer
metadata:
  name: rack1-tor
spec:
  peerIP: 192.168.10.254
  asNumber: 64512
  nodeSelector: rack == 'rack1'
EOF

root@k8s-m:~# cat <<EOF | calicoctl apply -f -
apiVersion: projectcalico.org/v3
kind: BGPPeer
metadata:
  name: rack2-tor
spec:
  peerIP: 192.168.20.254
  asNumber: 64512
  nodeSelector: rack == 'rack2'
EOF

root@k8s-m:~# calicoctl get bgppeer
NAME         PEERIP           NODE              ASN
bgppeer-m    192.168.10.254   k8s-m             64512
bgppeer-w0   192.168.20.254   k8s-w0            64512
bgppeer-w1   192.168.10.254   k8s-w1            64512
bgppeer-w2   192.168.10.254   k8s-w2            64512
rack1-tor    192.168.10.254   rack == 'rack1'   64512
rack2-tor    192.168.20.254   rack == 'rack2'   64512


root@k8s-m:~# calicoctl delete bgppeer bgppeer-m
Successfully deleted 1 'BGPPeer' resource(s)
root@k8s-m:~# calicoctl delete bgppeer bgppeer-w0
Successfully deleted 1 'BGPPeer' resource(s)
root@k8s-m:~# calicoctl delete bgppeer bgppeer-w1
Successfully deleted 1 'BGPPeer' resource(s)
root@k8s-m:~# calicoctl delete bgppeer bgppeer-w2
Successfully deleted 1 'BGPPeer' resource(s)

root@k8s-m:~# calicoctl get bgppeer
NAME        PEERIP           NODE              ASN
rack1-tor   192.168.10.254   rack == 'rack1'   64512
rack2-tor   192.168.20.254   rack == 'rack2'   64512
