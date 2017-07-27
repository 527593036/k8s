#!/usr/bin/env bash
#
# Created on 2017/7/9
#
# @author: zhujin

FILEPATH=$(cd "$(dirname "$0")"; pwd);cd ${FILEPATH}

# define the service cluster IP for service Kubernetes
export SERVICE_CLUSTER_IP=${SERVICE_CLUSTER_IP_RANGE:-"172.24.0.1"}

# CLUSTER IP
IPS=$(python ${FILEPATH}/clusterInfo.py)

# master ip
MASTER=$(echo ${IPS} | awk '{print $1}')
export MASTER=${MASTER:-"127.0.0.1"}

# master node1 ip
MASTER_NODE1_IP=$(echo ${IPS} | awk '{print $2}')
export MASTER_NODE1_IP=${MASTER_NODE1_IP:-"127.0.0.1"}

# master node2 ip
MASTER_NODE2_IP=$(echo ${IPS} | awk '{print $3}')
export MASTER_NODE2_IP=${MASTER_NODE2_IP:-"127.0.0.1"}

# master node3 ip
MASTER_NODE3_IP=$(echo ${IPS} | awk '{print $4}')
export MASTER_NODE3_IP=${MASTER_NODE3_IP:-"127.0.0.1"}

# k8s domain
K8S_DOMAIN=$(echo ${IPS} | awk '{print $5}')
export K8S_DOMAIN=${K8S_DOMAIN:-"k8s.org"}
