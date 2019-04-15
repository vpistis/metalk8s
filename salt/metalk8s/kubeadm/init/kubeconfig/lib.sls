{%- from "metalk8s/map.jinja" import defaults with context %}
{%- from "metalk8s/map.jinja" import kube_api with context %}

{% macro kubeconfig(name, cert_info) %}

{%- set apiserver = 'https://' ~ pillar.metalk8s.api_server.host ~ ':6443' %}

include:
  - metalk8s.kubeadm.init.certs.installed

Create kubeconf file for {{ name }}:
  metalk8s_kubeconfig.managed:
    - name: /etc/kubernetes/{{ name }}.conf
    - ca_server: {{ pillar['metalk8s']['ca']['minion'] }}
    - signing_policy: {{ kube_api.cert.client_signing_policy }}
    - client_cert_info:
        {%- for key, value in cert_info.items() %}
        {{ key }}: {{ value }}
        {%- endfor %}
    - apiserver: {{ apiserver }}
    - cluster: {{ defaults.cluster }}
    - require:
      - pkg: Install m2crypto

{%- endmacro %}
