一、rpm打包

1、采用fpm打包rpm

2、工具: /srv/salt/k8s/preinstall/pkg2rpm.sh

3、对应的包已经在yum.example.com源里面有了

4、对应的包目录,kube-master,kube-node,flannel,etcd对应的包目录结果如下
```shell
kube-master
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

kube-node
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

flannel
.
├── bin
│   ├── flanneld
│   ├── mk-docker-opts.sh
│   └── rm-flannel-opts.sh
├── conf
└── README.md

etcd
.
├── bin
│   ├── etcd
│   ├── etcdctl
│   └── flannel_net_add.sh
├── conf
└── data
```


二、创建秘钥

1、修改配置文件，/srv/salt/k8s/preinstall/config.sh中MASTER变量对应的IP

2、运行/srv/salt/k8s/preinstall/create_keys.sh生成秘钥


三、k8s安装流程:

1、iptables放开

salt -N k8s state.sls k8s.iptables

2、dirct-lvm安装,注意需要在/srv/pillar/k8s.sls参数lvm_dev配置direct-lvm对应的硬盘,对应的硬盘不需要格式化与挂在

salt -N k8s state.sls k8s.direct-lvm

3、docker安装

salt -N k8s state.sls k8s.docker

4、安装etcd,并设置k8s集群网段，这里要注意网络规划，稍复杂，当前是单点安装，后续完善集群化安装

salt etcd_machine state.sls k8s.etcd

5、flannel安装

salt -N k8s state.sls k8s.flannel

6、kube-master安装，当前是单点安装

salt masters state.sls k8s.kube-master

7、kube-node安装

salt nodes state.sls k8s.kube-node

四、/srv/pillar/k8s.sls中配置参数说明
```shell
k8s:
  lvm_dev: /dev/sdb				# direct-lvm对应的硬盘盘符
  docker_ver: 1.13.1				# docker版本
  etcd_ver: 3.2.1				# etcd 版本
  etcd_data: /opt/etcd/data			# etcd数据目录
  flannel_ver: 0.7.1				# flannel版本
  etcd_domain: 10.10.75.133			# etcd ip或者域名
  interface: ens192				# flannel对应的网卡
  master_addr: 10.10.75.133			# k8s master对应的IP
  kubever: 1.6.4				# k8s 版本
  service_cluster_ip_range: 172.24.0.0/16	# k8s中service对应的IP段
  service_node_port_range: 30000-65535		# k8s中service对应的port段
  k8s_domain: k8s.org				# k8s集群里面的域名开始字符串，需要进一步了解
  registry: registry.topsecret.xunlei.cn	# 镜像源域名
```

五、todo

1、etcd集群安装

2、镜像源安装salt化？

3、master集群化

4、一键部署
