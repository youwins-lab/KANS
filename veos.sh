#!/usr/bin/env bash
FastCli -p 15 -c"
enable
configure
hostname leaf1a
!
!
interface Ethernet1
description Network10
no switchport
ip address 192.168.10.254/24
!
interface Ethernet2
description Network20
no switchport
ip address 192.168.20.254/24
!
!
ip routing
!
interface Loopback10
ip address 10.1.1.254/24
!
interface Loopback20
ip address 10.1.2.254/24
!
router bgp 64512
maximum-paths 4 ecmp 4
router-id 10.1.1.254
neighbor 192.168.10.10 remote-as 64512
neighbor 192.168.20.100 remote-as 64512
neighbor 192.168.10.101 remote-as 64512
neighbor 192.168.10.102 remote-as 64512
network 10.1.1.0/24
network 10.1.2.0/24
"



