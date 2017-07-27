kube-master_install:
  pkg.installed:
    - pkgs:
      - kube-master: {{ pillar['k8s']['kubever'] }}

master_cert:
  file.recurse:
    - name: /opt/kube-master/cert/master
    - source: salt://k8s/templates/cert/master
    - require:
      - pkg: kube-master_install

kube-apiserver.conf:
  file.managed:
    - name: /opt/kube-master/conf/kube-apiserver.conf
    - source: salt://k8s/templates/kube-apiserver.conf
    - user: root
    - mode: 0600
    - template: jinja
    - defaults:
      ETCD_DOMAIN: {{ pillar['k8s']['master_cluster']['vip'] }}
      NODE1_IP: {{ pillar['k8s']['master_cluster']['node1']['ip'] }}
      NODE2_IP: {{ pillar['k8s']['master_cluster']['node2']['ip'] }}
      NODE3_IP: {{ pillar['k8s']['master_cluster']['node3']['ip'] }}
      MASTER_ADDRESS: {{ pillar['k8s']['master_cluster']['vip'] }}
      SERVICE_CLUSTER_IP_RANGE: {{ pillar['k8s']['service_cluster_ip_range'] }}
      SERVICE_NODE_PORT_RANGE: {{ pillar['k8s']['service_node_port_range'] }}
    - require:
      - pkg: kube-master_install

kube-apiserver.service.systemd:
  file.managed:
    - name: /usr/lib/systemd/system/kube-apiserver.service
    - source: salt://k8s/templates/kube-apiserver.service
    - user: root
    - mode: 0600

systemd.daemon-reload.service.apiserver:
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: kube-apiserver.service.systemd

kube-apiserver.service:
  service.running:
    - name: kube-apiserver
    - enable: True
    - restart: True
    - require:
      - pkg: kube-master_install
      - file: master_cert
      - file: kube-apiserver.service.systemd
      - file: kube-apiserver.conf
    - watch:
      - file: kube-apiserver.service.systemd
      - file: kube-apiserver.conf
      - cmd: systemd.daemon-reload.service.apiserver

kube-controller-manager.conf:
  file.managed:
    - name: /opt/kube-master/conf/kube-controller-manager.conf
    - source: salt://k8s/templates/kube-controller-manager.conf
    - user: root
    - mode: 0600
    - template: jinja
    - defaults:
      MASTER_ADDRESS: {{ pillar['k8s']['master_cluster']['vip'] }}
    - require:
      - pkg: kube-master_install

kube-controller-manager.service.systemd:
  file.managed:
    - name: /usr/lib/systemd/system/kube-controller-manager.service
    - source: salt://k8s/templates/kube-controller-manager.service
    - user: root
    - mode: 0600

systemd.daemon-reload.service.controller:
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: kube-controller-manager.service.systemd

kube-controller-manager.service:
  service.running:
    - name: kube-controller-manager
    - enable: True
    - restart: True
    - require:
      - pkg: kube-master_install
      - file: master_cert
      - file: kube-controller-manager.service.systemd
      - file: kube-controller-manager.conf
    - watch:
      - file: kube-controller-manager.service.systemd
      - file: kube-controller-manager.conf
      - cmd: systemd.daemon-reload.service.controller

kube-scheduler.conf:
  file.managed:
    - name: /opt/kube-master/conf/kube-scheduler.conf
    - source: salt://k8s/templates/kube-scheduler.conf
    - user: root
    - mode: 0600
    - template: jinja
    - defaults:
      MASTER_ADDRESS: {{ pillar['k8s']['master_cluster']['vip'] }}
    - require:
      - pkg: kube-master_install

kube-scheduler.service.systemd:
  file.managed:
    - name: /usr/lib/systemd/system/kube-scheduler.service
    - source: salt://k8s/templates/kube-scheduler.service
    - user: root
    - mode: 0600

systemd.daemon-reload.service.scheduler:
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: kube-scheduler.service.systemd

kube-scheduler.service:
  service.running:
    - name: kube-scheduler
    - enable: True
    - restart: True
    - require:
      - pkg: kube-master_install
      - file: master_cert
      - file: kube-scheduler.service.systemd
      - file: kube-scheduler.conf
    - watch:
      - file: kube-scheduler.service.systemd
      - file: kube-scheduler.conf
      - cmd: systemd.daemon-reload.service.scheduler

kube-dns.conf:
  file.managed:
    - name: /opt/kube-master/conf/kube-dns.conf
    - source: salt://k8s/templates/kube-dns.conf
    - user: root
    - mode: 0600
    - template: jinja
    - defaults:
      MASTER_ADDRESS: {{ pillar['k8s']['master_cluster']['vip'] }}
      KUBE_DOMAIN: {{ pillar['k8s']['k8s_domain'] }}
    - require:
      - pkg: kube-master_install

kube-dns.service.systemd:
  file.managed:
    - name: /usr/lib/systemd/system/kube-dns.service
    - source: salt://k8s/templates/kube-dns.service
    - user: root
    - mode: 0600

systemd.daemon-reload.service.dns:
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: kube-dns.service.systemd

kube-dns.service:
  service.running:
    - name: kube-dns
    - enable: True
    - restart: True
    - require:
      - pkg: kube-master_install
      - file: master_cert
      - file: kube-dns.service.systemd
      - file: kube-dns.conf
    - watch:
      - file: kube-dns.service.systemd
      - file: kube-dns.conf
      - cmd: systemd.daemon-reload.service.dns

