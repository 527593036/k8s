{% set flannel_ver = '0.7.1' %}
{% set etcd_domain = '10.10.75.133' %}
{% set interface = 'ens192' %}

flannel_install:
  pkg.installed:
    - sources:
      - flannel: http://example.com/pkgs/flannel-{{ flannel_ver }}-1.x86_64.rpm

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
      ETCD_DOMAIN: {{ etcd_domain }}

flannel.service.systemd:
  file.managed:
    - name: /usr/lib/systemd/system/flannel.service
    - source: salt://k8s/templates/flannel.service 
    - user: root
    - mode: 0644
    - template: jinja
    - defaults:
      INTERFACE: {{ interface }}

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

flannel.route:
  cmd.run:
    - name: ip ro add 172.24.0.0/16 dev ens192
  file.append:
    - name: /etc/rc.local
    - text: ip ro add 172.24.0.0/16 dev ens192

