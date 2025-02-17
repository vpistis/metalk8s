#!jinja | metalk8s_kubernetes

{%- from "metalk8s/repo/macro.sls" import build_image_name with context %}



{% raw %}

apiVersion: v1
automountServiceAccountToken: true
kind: ServiceAccount
metadata:
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/instance: ingress-nginx-control-plane
    app.kubernetes.io/managed-by: salt
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: metalk8s
    app.kubernetes.io/version: 1.2.0
    helm.sh/chart: ingress-nginx-4.1.2
    heritage: metalk8s
  name: ingress-nginx-control-plane
  namespace: metalk8s-ingress
---
apiVersion: v1
automountServiceAccountToken: true
kind: ServiceAccount
metadata:
  labels:
    app.kubernetes.io/component: default-backend
    app.kubernetes.io/instance: ingress-nginx-control-plane
    app.kubernetes.io/managed-by: salt
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: metalk8s
    app.kubernetes.io/version: 1.2.0
    helm.sh/chart: ingress-nginx-4.1.2
    heritage: metalk8s
  name: ingress-nginx-control-plane-backend
  namespace: metalk8s-ingress
---
apiVersion: v1
data:
  allow-snippet-annotations: 'true'
kind: ConfigMap
metadata:
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/instance: ingress-nginx-control-plane
    app.kubernetes.io/managed-by: salt
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: metalk8s
    app.kubernetes.io/version: 1.2.0
    helm.sh/chart: ingress-nginx-4.1.2
    heritage: metalk8s
  name: ingress-nginx-control-plane-controller
  namespace: metalk8s-ingress
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app.kubernetes.io/instance: ingress-nginx-control-plane
    app.kubernetes.io/managed-by: salt
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: metalk8s
    app.kubernetes.io/version: 1.2.0
    helm.sh/chart: ingress-nginx-4.1.2
    heritage: metalk8s
  name: ingress-nginx-control-plane
  namespace: metalk8s-ingress
rules:
- apiGroups:
  - ''
  resources:
  - configmaps
  - endpoints
  - nodes
  - pods
  - secrets
  - namespaces
  verbs:
  - list
  - watch
- apiGroups:
  - ''
  resources:
  - nodes
  verbs:
  - get
- apiGroups:
  - ''
  resources:
  - services
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - networking.k8s.io
  resources:
  - ingresses
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - ''
  resources:
  - events
  verbs:
  - create
  - patch
- apiGroups:
  - networking.k8s.io
  resources:
  - ingresses/status
  verbs:
  - update
- apiGroups:
  - networking.k8s.io
  resources:
  - ingressclasses
  verbs:
  - get
  - list
  - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:
    app.kubernetes.io/instance: ingress-nginx-control-plane
    app.kubernetes.io/managed-by: salt
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: metalk8s
    app.kubernetes.io/version: 1.2.0
    helm.sh/chart: ingress-nginx-4.1.2
    heritage: metalk8s
  name: ingress-nginx-control-plane
  namespace: metalk8s-ingress
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: ingress-nginx-control-plane
subjects:
- kind: ServiceAccount
  name: ingress-nginx-control-plane
  namespace: metalk8s-ingress
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/instance: ingress-nginx-control-plane
    app.kubernetes.io/managed-by: salt
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: metalk8s
    app.kubernetes.io/version: 1.2.0
    helm.sh/chart: ingress-nginx-4.1.2
    heritage: metalk8s
  name: ingress-nginx-control-plane
  namespace: metalk8s-ingress
rules:
- apiGroups:
  - ''
  resources:
  - namespaces
  verbs:
  - get
- apiGroups:
  - ''
  resources:
  - configmaps
  - pods
  - secrets
  - endpoints
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - ''
  resources:
  - services
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - networking.k8s.io
  resources:
  - ingresses
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - networking.k8s.io
  resources:
  - ingresses/status
  verbs:
  - update
- apiGroups:
  - networking.k8s.io
  resources:
  - ingressclasses
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - ''
  resourceNames:
  - ingress-control-plane-controller-leader
  resources:
  - configmaps
  verbs:
  - get
  - update
- apiGroups:
  - ''
  resources:
  - configmaps
  verbs:
  - create
- apiGroups:
  - ''
  resources:
  - events
  verbs:
  - create
  - patch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/instance: ingress-nginx-control-plane
    app.kubernetes.io/managed-by: salt
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: metalk8s
    app.kubernetes.io/version: 1.2.0
    helm.sh/chart: ingress-nginx-4.1.2
    heritage: metalk8s
  name: ingress-nginx-control-plane
  namespace: metalk8s-ingress
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: ingress-nginx-control-plane
subjects:
- kind: ServiceAccount
  name: ingress-nginx-control-plane
  namespace: metalk8s-ingress
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/instance: ingress-nginx-control-plane
    app.kubernetes.io/managed-by: salt
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: metalk8s
    app.kubernetes.io/version: 1.2.0
    helm.sh/chart: ingress-nginx-4.1.2
    heritage: metalk8s
  name: ingress-nginx-control-plane-controller-metrics
  namespace: metalk8s-ingress
spec:
  ports:
  - name: metrics
    port: 10254
    protocol: TCP
    targetPort: metrics
  selector:
    app.kubernetes.io/component: controller
    app.kubernetes.io/instance: ingress-nginx-control-plane
    app.kubernetes.io/name: ingress-nginx
  type: ClusterIP
---
apiVersion: v1
kind: Service
metadata:
  annotations: null
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/instance: ingress-nginx-control-plane
    app.kubernetes.io/managed-by: salt
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: metalk8s
    app.kubernetes.io/version: 1.2.0
    helm.sh/chart: ingress-nginx-4.1.2
    heritage: metalk8s
  name: ingress-nginx-control-plane-controller
  namespace: metalk8s-ingress
spec:
  externalTrafficPolicy: Local
  ipFamilies:
  - IPv4
  ipFamilyPolicy: SingleStack
  loadBalancerIP: {% endraw -%}{{ salt.metalk8s_network.get_control_plane_ingress_ip() }}{%- raw %}
  ports:
  - appProtocol: https
    name: https
    port: 8443
    protocol: TCP
    targetPort: https
  selector:
    app.kubernetes.io/component: controller
    app.kubernetes.io/instance: ingress-nginx-control-plane
    app.kubernetes.io/name: ingress-nginx
  type: LoadBalancer
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app.kubernetes.io/component: default-backend
    app.kubernetes.io/instance: ingress-nginx-control-plane
    app.kubernetes.io/managed-by: salt
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: metalk8s
    app.kubernetes.io/version: 1.2.0
    helm.sh/chart: ingress-nginx-4.1.2
    heritage: metalk8s
  name: ingress-nginx-control-plane-defaultbackend
  namespace: metalk8s-ingress
spec:
  ports:
  - appProtocol: http
    name: http
    port: 80
    protocol: TCP
    targetPort: http
  selector:
    app.kubernetes.io/component: default-backend
    app.kubernetes.io/instance: ingress-nginx-control-plane
    app.kubernetes.io/name: ingress-nginx
  type: ClusterIP
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/instance: ingress-nginx-control-plane
    app.kubernetes.io/managed-by: salt
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: metalk8s
    app.kubernetes.io/version: 1.2.0
    helm.sh/chart: ingress-nginx-4.1.2
    heritage: metalk8s
  name: ingress-nginx-control-plane-controller
  namespace: metalk8s-ingress
spec:
  minReadySeconds: 0
  replicas: {% endraw -%}{{ pillar.networks.control_plane.ingress.controller.replicas }}{%- raw %}
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      app.kubernetes.io/component: controller
      app.kubernetes.io/instance: ingress-nginx-control-plane
      app.kubernetes.io/name: ingress-nginx
  strategy:
    rollingUpdate:
      maxUnavailable: 1
    type: RollingUpdate
  template:
    metadata:
      labels:
        app.kubernetes.io/component: controller
        app.kubernetes.io/instance: ingress-nginx-control-plane
        app.kubernetes.io/name: ingress-nginx
    spec:
      affinity: {% endraw -%}{{ salt.metalk8s_service_configuration.get_pod_affinity(
        pillar.networks.control_plane.ingress.controller.affinity, {"app.kubernetes.io/component":
        "controller", "app.kubernetes.io/instance": "ingress-nginx-control-plane",
        "app.kubernetes.io/name": "ingress-nginx"}, "metalk8s-ingress") }}{%- raw %}
      containers:
      - args:
        - /nginx-ingress-controller
        - --default-backend-service=$(POD_NAMESPACE)/ingress-nginx-control-plane-defaultbackend
        - --publish-service=$(POD_NAMESPACE)/ingress-nginx-control-plane-controller
        - --election-id=ingress-control-plane-controller-leader
        - --controller-class=k8s.io/ingress-nginx-control-plane
        - --ingress-class=nginx-control-plane
        - --configmap=$(POD_NAMESPACE)/ingress-nginx-control-plane-controller
        - --default-ssl-certificate=metalk8s-ingress/ingress-control-plane-default-certificate
        - --metrics-per-host=false
        env:
        - name: POD_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        - name: POD_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        - name: LD_PRELOAD
          value: /usr/local/lib/libmimalloc.so
        image: {% endraw -%}{{ build_image_name("nginx-ingress-controller", False) }}{%- raw %}:v1.2.0
        imagePullPolicy: IfNotPresent
        lifecycle:
          preStop:
            exec:
              command:
              - /wait-shutdown
        livenessProbe:
          failureThreshold: 5
          httpGet:
            path: /healthz
            port: 10254
            scheme: HTTP
          initialDelaySeconds: 10
          periodSeconds: 10
          successThreshold: 1
          timeoutSeconds: 1
        name: controller
        ports:
        - containerPort: 80
          name: http
          protocol: TCP
        - containerPort: 443
          name: https
          protocol: TCP
        - containerPort: 10254
          name: metrics
          protocol: TCP
        readinessProbe:
          failureThreshold: 3
          httpGet:
            path: /healthz
            port: 10254
            scheme: HTTP
          initialDelaySeconds: 10
          periodSeconds: 10
          successThreshold: 1
          timeoutSeconds: 1
        resources:
          requests:
            cpu: 100m
            memory: 90Mi
        securityContext:
          allowPrivilegeEscalation: true
          capabilities:
            add:
            - NET_BIND_SERVICE
            drop:
            - ALL
          runAsUser: 101
      dnsPolicy: ClusterFirst
      nodeSelector:
        kubernetes.io/os: linux
        node-role.kubernetes.io/master: ''
      serviceAccountName: ingress-nginx-control-plane
      terminationGracePeriodSeconds: 300
      tolerations:
      - effect: NoSchedule
        key: node-role.kubernetes.io/bootstrap
        operator: Exists
      - effect: NoSchedule
        key: node-role.kubernetes.io/master
        operator: Exists
      - effect: NoSchedule
        key: node-role.kubernetes.io/infra
        operator: Exists
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app.kubernetes.io/component: default-backend
    app.kubernetes.io/instance: ingress-nginx-control-plane
    app.kubernetes.io/managed-by: salt
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: metalk8s
    app.kubernetes.io/version: 1.2.0
    helm.sh/chart: ingress-nginx-4.1.2
    heritage: metalk8s
  name: ingress-nginx-control-plane-defaultbackend
  namespace: metalk8s-ingress
spec:
  replicas: 1
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      app.kubernetes.io/component: default-backend
      app.kubernetes.io/instance: ingress-nginx-control-plane
      app.kubernetes.io/name: ingress-nginx
  template:
    metadata:
      labels:
        app.kubernetes.io/component: default-backend
        app.kubernetes.io/instance: ingress-nginx-control-plane
        app.kubernetes.io/name: ingress-nginx
    spec:
      containers:
      - image: {% endraw -%}{{ build_image_name("nginx-ingress-defaultbackend-amd64", False) }}{%- raw %}:1.5
        imagePullPolicy: IfNotPresent
        livenessProbe:
          failureThreshold: 3
          httpGet:
            path: /healthz
            port: 8080
            scheme: HTTP
          initialDelaySeconds: 30
          periodSeconds: 10
          successThreshold: 1
          timeoutSeconds: 5
        name: ingress-nginx-default-backend
        ports:
        - containerPort: 8080
          name: http
          protocol: TCP
        readinessProbe:
          failureThreshold: 6
          httpGet:
            path: /healthz
            port: 8080
            scheme: HTTP
          initialDelaySeconds: 0
          periodSeconds: 5
          successThreshold: 1
          timeoutSeconds: 5
        securityContext:
          allowPrivilegeEscalation: false
          capabilities:
            drop:
            - ALL
          readOnlyRootFilesystem: true
          runAsNonRoot: true
          runAsUser: 65534
      nodeSelector:
        kubernetes.io/os: linux
        node-role.kubernetes.io/master: ''
      serviceAccountName: ingress-nginx-control-plane-backend
      terminationGracePeriodSeconds: 60
      tolerations:
      - effect: NoSchedule
        key: node-role.kubernetes.io/bootstrap
        operator: Exists
      - effect: NoSchedule
        key: node-role.kubernetes.io/master
        operator: Exists
      - effect: NoSchedule
        key: node-role.kubernetes.io/infra
        operator: Exists
---
apiVersion: networking.k8s.io/v1
kind: IngressClass
metadata:
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/instance: ingress-nginx-control-plane
    app.kubernetes.io/managed-by: salt
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: metalk8s
    app.kubernetes.io/version: 1.2.0
    helm.sh/chart: ingress-nginx-4.1.2
    heritage: metalk8s
  name: nginx-control-plane
  namespace: metalk8s-ingress
spec:
  controller: k8s.io/ingress-nginx-control-plane
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/instance: ingress-nginx-control-plane
    app.kubernetes.io/managed-by: salt
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: metalk8s
    app.kubernetes.io/version: 1.2.0
    helm.sh/chart: ingress-nginx-4.1.2
    heritage: metalk8s
    metalk8s.scality.com/monitor: ''
  name: ingress-nginx-control-plane-controller
  namespace: metalk8s-ingress
spec:
  endpoints:
  - interval: 30s
    port: metrics
  namespaceSelector:
    matchNames:
    - metalk8s-ingress
  selector:
    matchLabels:
      app.kubernetes.io/component: controller
      app.kubernetes.io/instance: ingress-nginx-control-plane
      app.kubernetes.io/name: ingress-nginx

{% endraw %}
