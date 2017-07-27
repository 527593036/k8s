{% set ip = salt['network.ip_addrs'](pillar['k8s']['interface'])[0] %}

kube-node_install:
  pkg.installed:
    - pkgs:
      - kube-node: {{ pillar['k8s']['kubever'] }} 

node_cert:
  file.recurse:
    - name: /opt/kube-node/cert/node
    - source: salt://k8s/templates/cert/node
    - require:
      - pkg: kube-node_install

kubelet.conf:
  file.managed:
    - name: /opt/kube-node/conf/kubelet.conf
    - source: salt://k8s/templates/kubelet.conf
    - user: root
    - mode: 0600
    - template: jinja
    - defaults:
      NODE_ADDRESS: {{ ip }}
      NODE_HOSTNAME: {{ grains['fqdn'] }}
      MASTER_ADDRESS: {{ pillar['k8s']['master_cluster']['vip'] }}
      KUBE_DOMAIN: {{ pillar['k8s']['k8s_domain'] }}
      REGISTRY_DOMAIN: {{ pillar['k8s']['registry'] }}
    - require:
      - pkg: kube-node_install

kubelet.service.systemd:
  file.managed:
    - name: /usr/lib/systemd/system/kubelet.service
    - source: salt://k8s/templates/kubelet.service
    - user: root
    - mode: 0600

systemd.daemon-reload.service.kubelet:
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: kubelet.service.systemd

kubelet.service:
  service.running:
    - name: kubelet
    - enable: True
    - restart: True
    - require:
      - pkg: kube-node_install
      - file: node_cert
      - file: kubelet.service.systemd
      - file: kubelet.conf
    - watch:
      - file: kubelet.service.systemd
      - file: kubelet.conf
      - cmd: systemd.daemon-reload.service.kubelet

kube-proxy.conf:
  file.managed:
    - name: /opt/kube-node/conf/kube-proxy.conf
    - source: salt://k8s/templates/kube-proxy.conf
    - user: root
    - mode: 0600
    - template: jinja
    - defaults:
      NODE_ADDRESS: {{ ip }}
      MASTER_ADDRESS: {{ pillar['k8s']['master_cluster']['vip'] }}
    - require:
      - pkg: kube-node_install

kube-proxy.service.systemd:
  file.managed:
    - name: /usr/lib/systemd/system/kube-proxy.service
    - source: salt://k8s/templates/kube-proxy.service
    - user: root
    - mode: 0600

systemd.daemon-reload.service.kube-proxy:
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: kube-proxy.service.systemd

kube-proxy.service:
  service.running:
    - name: kube-proxy
    - enable: True
    - restart: True
    - require:
      - pkg: kube-node_install
      - file: node_cert
      - file: kube-proxy.service.systemd
      - file: kube-proxy.conf
    - watch:
      - file: kube-proxy.service.systemd
      - file: kube-proxy.conf

