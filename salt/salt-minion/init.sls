install salt-minion package:
  pkg.latest:
    - name: salt-minion
    - refresh: True

configure salt-minion:
  file.managed:
    - name: /etc/salt/minion
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - source: salt://salt-minion/minion

start salt-minion:
  service.running:
    - name: salt-minion
    - require:
      - pkg: salt-minion
    - watch:
      - file: /etc/salt/minion
    - enable: True
