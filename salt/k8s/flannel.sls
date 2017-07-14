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
      ETCD_DOMAIN: {{ pillar['k8s']['etcd_domain'] }}

flannel.service.systemd:
  file.managed:
    - name: /usr/lib/systemd/system/flannel.service
    - source: salt://k8s/templates/flannel.service 
    - user: root
    - mode: 0644
    - template: jinja
    - defaults:
      INTERFACE: {{ pillar['k8s']['interface'] }}

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
