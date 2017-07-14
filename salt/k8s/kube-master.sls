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
      ETCD_DOMAIN: {{ pillar['k8s']['etcd_domain'] }}
      MASTER_ADDRESS: {{ pillar['k8s']['master_addr'] }}
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

kube-controller-manager.conf:
  file.managed:
    - name: /opt/kube-master/conf/kube-controller-manager.conf
    - source: salt://k8s/templates/kube-controller-manager.conf
    - user: root
    - mode: 0600
    - template: jinja
    - defaults:
      MASTER_ADDRESS: {{ pillar['k8s']['master_addr'] }}
    - require:
      - pkg: kube-master_install

kube-controller-manager.service.systemd:
  file.managed:
    - name: /usr/lib/systemd/system/kube-controller-manager.service
    - source: salt://k8s/templates/kube-controller-manager.service
    - user: root
    - mode: 0600

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

kube-scheduler.conf:
  file.managed:
    - name: /opt/kube-master/conf/kube-scheduler.conf
    - source: salt://k8s/templates/kube-scheduler.conf
    - user: root
    - mode: 0600
    - template: jinja
    - defaults:
      MASTER_ADDRESS: {{ pillar['k8s']['master_addr'] }}
    - require:
      - pkg: kube-master_install

kube-scheduler.service.systemd:
  file.managed:
    - name: /usr/lib/systemd/system/kube-scheduler.service
    - source: salt://k8s/templates/kube-scheduler.service
    - user: root
    - mode: 0600

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

kube-dns.conf:
  file.managed:
    - name: /opt/kube-master/conf/kube-dns.conf
    - source: salt://k8s/templates/kube-dns.conf
    - user: root
    - mode: 0600
    - template: jinja
    - defaults:
      MASTER_ADDRESS: {{ pillar['k8s']['master_addr'] }}
      KUBE_DOMAIN: {{ pillar['k8s']['k8s_domain'] }}
    - require:
      - pkg: kube-master_install

kube-dns.service.systemd:
  file.managed:
    - name: /usr/lib/systemd/system/kube-dns.service
    - source: salt://k8s/templates/kube-dns.service
    - user: root
    - mode: 0600

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
