salt://k8s/templates/yum.sh:
  cmd.script:
    - cwd: /usr/local/bin
    - unless: test -f /etc/yum.repos.d/xnet.repo