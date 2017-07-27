{% set ip = salt['network.ip_addrs'](pillar['k8s']['interface'])[0] %}

etcd_install:
  pkg.installed:
    - pkgs:
      - etcd: {{ pillar['k8s']['etcd_ver'] }}

etcd.conf:
  file.managed:
    - name: /opt/etcd/conf/etcd.conf
    - source: salt://k8s/templates/etcd.conf
    - user: root
    - mode: 0600
    - require:
      - pkg: etcd_install
    - template: jinja
    - defaults:
      IP: {{ ip }}
      DATADIR: {{ pillar['k8s']['etcd_data'] }}
      NAME: {{ grains['fqdn'] }}
      HOSTNAME1: {{ pillar['k8s']['etcd_cluster']['node1']['hostname'] }}
      HOSTNAME2: {{ pillar['k8s']['etcd_cluster']['node2']['hostname'] }}
      HOSTNAME3: {{ pillar['k8s']['etcd_cluster']['node3']['hostname'] }}
      IP1: {{ pillar['k8s']['etcd_cluster']['node1']['ip'] }}
      IP2: {{ pillar['k8s']['etcd_cluster']['node2']['ip'] }}
      IP3: {{ pillar['k8s']['etcd_cluster']['node3']['ip'] }}

etcd.service.systemd:
  file.managed:
    - name: /usr/lib/systemd/system/etcd.service
    - source: salt://k8s/templates/etcd.service 
    - user: root
    - mode: 0644

systemd.service:
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges: 
      - file: etcd.service.systemd

etcd.service:
  service.running:
    - name: etcd
    - enable: True
    - restart: True
    - require:
      - pkg: etcd_install
      - file: etcd.conf
      - file: etcd.service.systemd
    - watch:
      - pkg: etcd_install
      - file: etcd.conf
      - file: etcd.service.systemd
      - cmd: systemd.service

network_plan_scripts:
  file.managed:
    - name: /opt/etcd/bin/flannel_net_add.sh
    - source:  salt://k8s/templates/flannel_net_add.sh
    - user: root
    - mode: 0755

flannel_add_net:
  cmd.run:
    - name: bash /opt/etcd/bin/flannel_net_add.sh
    - unless: /opt/etcd/bin/etcdctl get /coreos.com/network/config
    - require:
      - service: etcd.service
      - file: network_plan_scripts

