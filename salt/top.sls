{% import_yaml "config.yml" as config %}
base:
  '*':
    - common
    - salt-minion
  'k8s02-*':
{%- if config.container_runtime == "crio" %}
    - crio
{%- else %}
    - docker
{%- endif %}
    - kubernetes-basics
  'k8s02-salt-master*':
    - salt-keys
    - salt-master
  'k8s02-master*':
    - kubernetes-master
  'k8s02-worker*':
    - kubernetes-worker
  'move-to-k8s-saltstack': []
