系统需求: centos7 x86_64

一、rpm打包

1、工具: /srv/salt/k8s/preinstall/pkg2rpm.sh, etcd, flannel, k8s rpm包制作如下: 
```shell
获取kubernetes包: https://github.com/kubernetes/kubernetes/releases
kubernetes/cluster/get-kube-binaries.sh获取对应的包: kubernetes-server-linux-amd64.tar.gz,获取编译好的文件
	
获取etcd包: https://github.com/coreos/etcd/releases
	
获取flannel包: https://github.com/coreos/flannel/releases
```

```shell
etcd包目录:
[root@my_test etcd]# pwd
/opt/etcd
[root@my_test etcd]# tree .
.
├── bin
│   ├── etcd
│   ├── etcdctl
│   └── flannel_net_add.sh
├── conf
└── data

flannel包目录
[root@my_test flannel]# pwd
/opt/flannel
[root@my_test flannel]# tree .
.
├── bin
│   ├── flanneld
│   ├── mk-docker-opts.sh
│   └── rm-flannel-opts.sh
├── conf
└── README.md

kube-master包目录
[root@my_test kube-master]# pwd
/opt/kube-master
[root@my_test kube-master]# tree .
.
├── bin
│   ├── kube-apiserver
│   ├── kube-controller-manager
│   ├── kubectl
│   ├── kube-dns
│   └── kube-scheduler
├── cert
│   └── master
├── conf
└── logs

kube-node包目录
[root@my_test kube-node]# pwd
/opt/kube-node
[root@my_test kube-node]# tree .
.
├── bin
│   ├── kubectl
│   ├── kubelet
│   └── kube-proxy
├── cert
│   └── node
├── conf
├── logs
└── manifests
```

```shell
fpm打包,比如打etcd的rpm, 生对应的etcd包，并上传到yum源服务器
/srv/salt/k8s/preinstall/pkg2rpm.sh etcd 3.2.1 /opt/etcd /opt/etcd
```

2、生效yum源服务器，支持yum源安装k8s对应的包

二、配置文件修改，/srv/pillar/k8s.sls配置文件说明
```python
k8s:
  lvm_dev: /dev/sdb                                 # direct-lvm对应的硬盘盘符
  docker_ver: 1.13.1                                # docker版本
  etcd_ver: 3.2.1                                   # etcd版本
  etcd_data: /opt/etcd/data                         # etcd数据存储目录
  flannel_ver: 0.7.1                                # flannel版本
  master_cluster:                                   # master集群
    vip: 10.10.75.133                               # master集群vip
    node1:                                          # master集群node1
      hostname: test75vm6                           # master集群node1主机名
      ip: 10.10.75.133                              # master集群node1 ip
    node2:                                          # master集群node2
      hostname: test75vm7                           # master集群node2主机名
      ip: 10.10.75.134                              # master集群node2 ip
    node3:                                          # master集群node3
      hostname: test75vm8                           # master集群node3主机名
      ip: 10.10.75.135                              # master集群node3 ip
  interface: ens192                                 # flannel关联的网卡
  kubever: 1.6.4                                    # k8s版本
  service_cluster_ip_range: 172.24.0.0/16           # k8s中service对应的ip段
  service_node_port_range: 50-65535                 # k8s中service对应的端口段
  k8s_domain: k8s.org                               # k8s集群里面的域名开始字符串，需要进一步了解
  registry: registry.example.com                    # 镜像源域名
```

二、创建秘钥

1、运行/srv/salt/k8s/preinstall/create_keys.sh生成秘钥


三、k8s安装流程:

1、iptables放开

```shell
salt -N k8s state.sls k8s.iptables
```

2、dirct-lvm安装,注意需要在/srv/pillar/k8s.sls参数lvm_dev配置direct-lvm对应的硬盘,对应的硬盘不需要格式化与挂在

```shell
salt -N k8s state.sls k8s.direct-lvm
```

3、docker安装

```shell
salt -N k8s state.sls k8s.docker
```

4、安装etcd集群,并设置k8s集群网段, 注意网络规划，规划脚本/srv/salt/k8s/templates/flannel_net_add.sh

```shell
salt -N k8s_master state.sls k8s.etcd
```

5、flannel安装

```shell
salt -N k8s state.sls k8s.flannel
```

6、kube-master集群安装

```shell
salt -N k8s_masters state.sls k8s.kube-master
```

7、kube-node安装

```shell
salt -N k8s_nodes state.sls k8s.kube-node
```

五、一键安装

1、规划好k8s的master, node节点,并在saltstack的nodegroup配置

2、在/srv/pillar/k8s.sls文件,配置好k8s集群对应的信息

3、执行/srv/salt/k8s/oneKeyDeploy.sh

4、备注: master的高可用接入lvs或haproxy,不属于k8s安装范畴,暂不考虑接入一键安装


六、todo

1、镜像源安装salt化？

