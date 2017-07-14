#!/usr/bin/env bash
#
# Created on 2017/7/9
#
# @author: zhujin

# define the service cluster IP for service Kubernetes
export SERVICE_CLUSTER_IP=${SERVICE_CLUSTER_IP_RANGE:-"172.24.0.1"}

# master ip
export MASTER=${MASTER:-"10.10.75.133"}

# define the IP range used for service cluster IPs.
# according to rfc 1918 ref: https://tools.ietf.org/html/rfc1918 choose a private ip range here.
export SERVICE_CLUSTER_IP_RANGE=${SERVICE_CLUSTER_IP_RANGE:-"172.24.0.0/16"}

# define the node port range used for service node PORTs.
export SERVICE_NODE_PORT_RANGE=${SERVICE_NODE_PORT_RANGE:-"50-32767"}

