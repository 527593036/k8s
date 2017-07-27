k8s:
  lvm_dev: /dev/sdb
  docker_ver: 1.13.1
  etcd_ver: 3.2.1
  etcd_data: /opt/etcd/data
  flannel_ver: 0.7.1
  master_cluster:
    vip: 10.10.75.133
    node1:
      hostname: test75vm6
      ip: 10.10.75.133
    node2:
      hostname: test75vm7
      ip: 10.10.75.134
    node3:
      hostname: test75vm8
      ip: 10.10.75.135
  interface: ens192
  kubever: 1.6.4
  service_cluster_ip_range: 172.24.0.0/16
  service_node_port_range: 50-32765
  k8s_domain: k8s.org
  registry: registry.example.com
