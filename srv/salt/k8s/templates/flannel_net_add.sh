#!/bin/bash

/opt/etcd/bin/etcdctl mk /coreos.com/network/config '{"Network":"172.20.0.0/16","SubnetLen": 27,"Backend":{"Type":"vxlan","VNI":1}}'
