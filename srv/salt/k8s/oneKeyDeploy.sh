#!/usr/bin/env bash
#
# Created on 2017/7/24
#
# @author: zhujin


# saltstack nodegroup配置的节点组
if [ $# -ne 2 ];then
    echo "Usage: ./oneKeyDeploy k8s_masters k8s_nodes"
    exit 1
fi

k8s_masters=$1
k8s_nodes=$2


FILEPATH=$(cd "$(dirname "$0")"; pwd);cd ${FILEPATH}


# 生成秘钥
if [ ! -f "${FILEPATH}/templates/cert/master/server.crt" ] && [ ! -f "${FILEPATH}/templates/cert/node/kubelet.crt" ];then
    bash ${FILEPATH}/preinstall/create_keys.sh
fi


# iptables,路由添加
salt -N ${k8s_nodes} state.sls k8s.iptables


# xnet yum源更新
salt -N ${k8s_masters} state.sls k8s.yum
salt -N ${k8s_nodes} state.sls k8s.yum


# master安装
salt -N ${k8s_masters} state.sls k8s.etcd
salt -N ${k8s_masters} state.sls k8s.kube-master


# node安装
salt -N ${k8s_nodes} state.sls k8s.direct-lvm
salt -N ${k8s_nodes} state.sls k8s.docker
salt -N ${k8s_nodes} state.sls k8s.flannel
salt -N ${k8s_nodes} state.sls k8s.kube-node