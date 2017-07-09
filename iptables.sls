flannel_iptables:
  file.line:
    - name: /etc/sysconfig/iptables
    - content: |
         -A RH-Firewall-1-INPUT -s 172.20.0.0/16 -j ACCEPT
         -A RH-Firewall-1-INPUT -s 172.24.0.0/16 -j ACCEPT
    - mode: ensure
    - after: -A RH-Firewall-1-INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

iptables:
  service.running:
    - enable: True
    - reload: True
    - watch:
      - file: /etc/sysconfig/iptables
