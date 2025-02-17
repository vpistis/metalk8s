{%- from "metalk8s/macro.sls" import pkg_installed with context %}
{%- from "metalk8s/map.jinja" import metalk8s with context %}
{%- from "metalk8s/map.jinja" import kubelet with context %}
{%- from "metalk8s/map.jinja" import repo with context %}
{%- from "metalk8s/map.jinja" import networks with context %}
{%- from "metalk8s/map.jinja" import proxies with context %}
{%- from "metalk8s/repo/macro.sls" import build_image_name with context %}

{%- set registry_eps = [] %}
{%- set pillar_endpoints = metalk8s.endpoints.repositories %}
{%- if not pillar_endpoints | is_list %}
  {%- set pillar_endpoints = [pillar_endpoints] %}
{%- endif %}
{%- for ep in pillar_endpoints %}
  {%- do registry_eps.append('"http://' ~ ep.ip ~ ":" ~ ep.ports.http ~ '"') %}
{%- endfor %}

include:
  - metalk8s.repo
  - .running

{%- if grains['os_family'].lower() == 'redhat' %}
Install container-selinux:
  {{ pkg_installed('container-selinux') }}
    - require:
      - test: Repositories configured
{%- endif %}

Install runc:
  {{ pkg_installed('runc') }}
    - require:
      - test: Repositories configured
      {%- if grains['os_family'].lower() == 'redhat' %}
      - metalk8s_package_manager: Install container-selinux
      {%- endif %}

Install containerd:
  {{ pkg_installed('containerd') }}
    - require:
      - test: Repositories configured
      - metalk8s_package_manager: Install runc
      - file: Create containerd service drop-in
      - file: Configure registry IP in containerd conf
      {%- if grains['os_family'].lower() == 'redhat' %}
      - metalk8s_package_manager: Install container-selinux
      {%- endif %}
    - watch_in:
      - service: Ensure containerd running

Create containerd service drop-in:
  file.managed:
    - name: /etc/systemd/system/containerd.service.d/50-metalk8s.conf
    - source: salt://{{ slspath }}/files/50-metalk8s.conf.j2
    - template: jinja
    - user: root
    - group: root
    - mode: '0644'
    - makedirs: true
    - dir_mode: '0755'
    - context:
        containerd_args:
          - --log-level
          - {{ "debug" if metalk8s.debug else "info" }}
        environment:
        {%- if proxies %}
          {%- set no_proxy = ["localhost", "127.0.0.1"] %}
          {%- do no_proxy.extend(networks.control_plane.cidr) %}
          {%- do no_proxy.extend(networks.workload_plane.cidr) %}
          {%- do no_proxy.append(networks.pod) %}
          {%- do no_proxy.append(networks.service) %}
          {%- if proxies.no_proxy | default %}
            {%- do no_proxy.extend(proxies.no_proxy) %}
          {%- endif %}
          NO_PROXY: "{{ no_proxy | unique | join(",") }}"
          {%- if proxies.http | default %}
          HTTP_PROXY: "{{ proxies.http }}"
          {%- endif %}
          {%- if proxies.https | default %}
          HTTPS_PROXY: "{{ proxies.https }}"
          {%- endif %}
        {%- endif %}
    - watch_in:
      - service: Ensure containerd running

Install and configure cri-tools:
  {{ pkg_installed('cri-tools') }}
    - require:
      - test: Repositories configured
    - require_in:
      - test: Ensure containerd is ready
  file.serialize:
    - name: /etc/crictl.yaml
    - dataset:
        runtime-endpoint: {{ kubelet.service.options.get("container-runtime-endpoint") }}
        image-endpoint: {{ kubelet.service.options.get("container-runtime-endpoint") }}
    - merge_if_exists: true
    - user: root
    - group: root
    - mode: '0644'
    - formatter: yaml
    - require_in:
      - test: Ensure containerd is ready

Configure registry IP in containerd conf:
  file.managed:
    - name: /etc/containerd/config.toml
    - makedirs: true
    - contents: |
        version = 2

        [plugins."io.containerd.grpc.v1.cri"]
        sandbox_image = "{{ build_image_name("pause") }}"

        [plugins."io.containerd.grpc.v1.cri".registry.mirrors."{{ repo.registry_endpoint }}"]
        endpoint = [{{ registry_eps | join(",") }}]

        [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
        runtime_type = "io.containerd.runc.v2"
        [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
        SystemdCgroup = true

        [debug]
        level = "{{ 'debug' if metalk8s.debug else 'info' }}"
    - watch_in:
        - service: Ensure containerd running
