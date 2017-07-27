flannel_install:
  pkg.installed:
    - pkgs:
      - flannel: {{ pillar['k8s']['flannel_ver'] }}

flannel.conf:
  file.managed:
    - name: /opt/flannel/conf/flannel.conf
    - source: salt://k8s/templates/flannel.conf
    - user: root
    - mode: 0600
    - require:
      - pkg: flannel_install
    - template: jinja
    - defaults:
      ETCD_DOMAIN: {{ pillar['k8s']['master_cluster']['vip'] }}
      NODE1_IP: {{ pillar['k8s']['master_cluster']['node1']['ip'] }}
      NODE2_IP: {{ pillar['k8s']['master_cluster']['node2']['ip'] }}
      NODE3_IP: {{ pillar['k8s']['master_cluster']['node3']['ip'] }}

flannel.service.systemd:
  file.managed:
    - name: /usr/lib/systemd/system/flannel.service
    - source: salt://k8s/templates/flannel.service 
    - user: root
    - mode: 0644
    - template: jinja
    - defaults:
      INTERFACE: {{ pillar['k8s']['interface'] }}

systemd.service:
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges: 
      - file: flannel.service.systemd

flannel.service:
  service.running:
    - name: flannel
    - enable: True
    - restart: True
    - require:
      - pkg: flannel_install
      - file: flannel.conf
      - file: flannel.service.systemd
    - watch:
      - pkg: flannel_install
      - file: flannel.conf
      - file: flannel.service.systemd
