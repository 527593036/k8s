k8s安装流程:
1、iptables放开
salt -N k8s state.sls k8s.iptables

2、dirct-lvm安装
salt -N k8s state.sls k8s.direct-lvm

3、docker安装
salt -N k8s state.sls k8s.docker

4、flannel安装
salt -N k8s state.sls k8s.flannel
