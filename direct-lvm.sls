{% set lvm_dev = '/dev/sdb' %}

lvm2-install:
  pkg.installed:
    - pkgs:
      - lvm2

docker-thinpool.profile:
  file.managed:
    - name: /etc/lvm/profile/docker-thinpool.profile
    - user: root
    - mode: 0600
    - source: salt://k8s/templates/docker-thinpool.profile

direct-lvm-install:
  file.managed:
    - name: /usr/local/src/direct-lvm.sh
    - source: salt://k8s/templates/direct-lvm.sh
    - user: root
    - mode: 0600
    - template: jinja
    - defauts:
      LVMDEV: {{ lvm_dev }} 

  cmd.run:
    - name: bash /usr/local/src/direct-lvm.sh
    - require:
      - file: docker-thinpool.profile
      - file: direct-lvm-install
