{% set etcd_ver = '3.2.1' %}
{% set data = '/opt/etcd/data' %}
{% set ip = salt['network.ip_addrs']('ens192')[0] %}

etcd_install:
  pkg.installed:
    - sources:
      - etcd: http://example.com/pkgs/etcd-{{ etcd_ver }}-1.x86_64.rpm

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
      DATADIR: {{ data }}

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
