#!/usr/bin/env bash
FastCli -p 15 -c"
enable
configure
hostname leaf1a
!
spanning-tree mode none
!
vlan 10
!
interface Ethernet1
	switchport
	swtichport access vlan 10
	no shutdown
!
interface Ethernet2
	no switchport
	no shutdown
	ip address 192.168.20.254/24
!
interface vlan 10
	no shutdown
	ip address 192.168.10.254/24
!
ip routing
!
interface Loopback10
	ip address 10.1.1.254/24
!
interface Loopback20
	ip address 10.1.2.254/24
!
peer-filter K8S-AS-RANGE
	10 match as-range 64500-64999 result accept
!
router bgp 64512
	router-id 10.1.1.254
	maximum-paths 4 ecmp 4
	bgp listen range 192.168.0.0/16 peer-group K8S-PEERS peer-filter K8S-AS-RANGE
	neighbor K8S-PEERS peer group
	neighbor K8S-PEERS maximum-routes 12000
	network 10.1.1.0/24
	network 10.1.2.0/24
"

