#!/usr/bin/env bash
FastCli -p 15 -c"
enable
configure
hostname leaf1a
!
!
interface Ethernet1
description EBGP-TO-TOP
switchport
ip address 192.168.10.254/24
!
interface Ethernet2
description POD2
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








neighbor EBGP-TO-TOP peer-group
neighbor EBGP-TO-TOP remote-as 64512
neighbor EBGP-TO-TOP send-community
neighbor IBGP-TO-LEAF-PEER peer-group
neighbor IBGP-TO-LEAF-PEER remote-as 65001
neighbor IBGP-TO-LEAF-PEER next-hop-self
neighbor IBGP-TO-LEAF-PEER send-community
neighbor EBGP-TO-EDGE peer-group
neighbor EBGP-TO-EDGE remote-as 65002
neighbor EBGP-TO-EDGE send-community
neighbor 1.1.1.2 peer-group IBGP-TO-LEAF-PEER
neighbor 10.10.10.2 peer-group EBGP-TO-TOP
neighbor 192.168.1.2 peer-group EBGP-TO-EDGE
network 10.10.10.0/30
network 100.100.100.1/32