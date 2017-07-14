salt://k8s/templates/yum.sh:
  cmd.script:
    - cwd: /usr/local/bin
    - unless: test -f /etc/yum.repos.d/k8s.repo

docker_pkgs:
  pkg.installed:
    - pkgs:
      - docker-engine: {{ pillar['k8s']['docker_ver'] }}

daemon.json:
  file.managed:
    - name: /etc/docker/daemon.json
    - source: salt://k8s/templates/daemon.json
    - user: root
    - mode: 0600

docker.service:
  file.managed:
    - name: /usr/lib/systemd/system/docker.service
    - source: salt://k8s/templates/docker.service
    - user: root
    - mode: 0600
    
docker.options:
  file.managed:
    - name: /etc/sysconfig/docker
    - source: salt://k8s/templates/docker
    - user: root
    - mode: 0600

docker_service:
  service.running:
    - name: docker
    - enable: True
    - reload: True
    - require:
      - pkg: docker_pkgs
      - file: daemon.json
      - file: docker.service
      - file: docker.options
    - watch:
      - file: daemon.json
      - file: docker.service
      - file: docker.options

pause.tar:
  file.managed:
    - name: /usr/local/src/pause.tar
    - source: salt://k8s/templates/pause.tar
    - user: root
    - mode: 0600
  cmd.run:
    - name: cd /usr/local/src/;docker image load -i pause.tar
    - unless: docker images | grep pause
    - require:
      - file: pause.tar
