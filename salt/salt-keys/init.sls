{% import_yaml "nodes-salt.yml" as nodes %}

{% for node in nodes.nodes %}
salt minion accept key for {{ node.hostname }}:
  cmd.run:
    - name: salt-key -a '{{ node.hostname }}' -y
    - onlyif: 'test ! -e /etc/salt/pki/master/{{ node.hostname }}.pub'
    - creates: /etc/salt/pki/master/{{ node.hostname }}.pub
{% endfor %}
