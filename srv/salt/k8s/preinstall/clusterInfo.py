#!/usr/bin/env python
#-*-coding: utf-8-*-
'''
Created on 2017/7/18

@author: zhujin
'''


import yaml

def cluster_info():
    fp = open('/srv/pillar/k8s.sls', 'r')
    yml = yaml.safe_load(fp)
    fp.close()

    return yml

def main():
    ret = cluster_info()
    vip = ret['k8s']['master_cluster']['vip']
    node1_ip = ret['k8s']['master_cluster']['node1']['ip']
    node2_ip = ret['k8s']['master_cluster']['node2']['ip']
    node3_ip = ret['k8s']['master_cluster']['node3']['ip']
    k8s_domain = ret['k8s']['k8s_domain']
    print("%s %s %s %s %s" % (vip, node1_ip, node2_ip, node3_ip, k8s_domain))


if __name__ == '__main__':
    main()
