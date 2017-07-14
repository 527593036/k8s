#{% set etcd_ver = '3.2.1' %}
#{% set data = '/opt/etcd/data' %}
#{% set net_dev =  pillar['k8s']['interface'] %}
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

etcd.service.systemd:
  file.managed:
    - name: /usr/lib/systemd/system/etcd.service
    - source: salt://k8s/templates/etcd.service 
    - user: root
    - mode: 0644

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

flannel_add_net:
  cmd.run:
    - name: bash /opt/etcd/bin/flannel_net_add.sh
    - require:
      - service: etcd.service
