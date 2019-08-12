{%- from "metalk8s/repo/macro.sls" import repo_prefix with context %}

{%- set apiserver = 'https://' ~ pillar.metalk8s.api_server.host ~ ':6443' %}
{%- set version = pillar.metalk8s.nodes[pillar.bootstrap_id].version %}
{%- set kubeconfig = "/etc/kubernetes/admin.conf" %}
{%- set context = "kubernetes-admin@kubernetes" %}
{%- set custom_renderer =
  "jinja | kubernetes kubeconfig=" ~ kubeconfig ~ "&context=" ~ context
%}

# Init
Make sure "metalk8s-solutions" Namespace exists:
  metalk8s_kubernetes.namespace_present:
    - name: metalk8s-solutions
    - kubeconfig: {{ kubeconfig }}
    - context: {{ context }}

Make sure "admin-uis" Namespace exists:
  metalk8s_kubernetes.namespace_present:
    - name: admin-uis
    - kubeconfig: {{ kubeconfig }}
    - context: {{ context }}

Make sure "ui-branding" ConfigMap exists:
  metalk8s_kubernetes.configmap_present:
    - name: ui-branding
    - namespace: admin-uis
    - data:
        config.json: |
          {
            "url": "{{ apiserver }}"
          }
        theme.json: |
          {
            "brand": {"primary": "#403e40", "secondary": "#e99121"}
          }
    - kubeconfig: {{ kubeconfig }}
    - context: {{ context }}
    - require:
      - metalk8s_kubernetes: Make sure "admin-uis" Namespace exists

# Mount
Mount declared Solutions archives:
  salt.state:
  - tgt: {{ pillar.bootstrap_id }}
  - sls:
    - metalk8s.solutions.mounted
  - saltenv: metalk8s-{{ version }}