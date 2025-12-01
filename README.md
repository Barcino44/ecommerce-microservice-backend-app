E-Commerce Microservices Platform - Kubernetes Deployment

https://helm.sh/
https://kubernetes.io/

📋 Tabla de Contenidos

Descripción General
Arquitectura
Características Principales
Requisitos Previos
Instalación
Estructura del Proyecto
Configuración de Servicios
Network Policies
Monitoreo y Observabilidad
Seguridad
CI/CD
Estrategias de Despliegue
Operaciones
Troubleshooting


🎯 Descripción General
Plataforma de e-commerce basada en microservicios desplegada en Kubernetes utilizando Helm charts. El proyecto implementa patrones modernos de arquitectura cloud-native incluyendo:

Microservicios Spring Boot con patrón API Gateway
Service Discovery con Eureka
Configuración centralizada con Spring Cloud Config
Observabilidad completa con Prometheus, Grafana y Jaeger
Seguridad robusta con Network Policies, Sealed Secrets y RBAC
CI/CD automatizado con GitHub Actions
Múltiples estrategias de despliegue (Blue-Green, Canary)


🏗️ Arquitectura
```bash
Diagrama de Arquitectura
                                    ┌─────────────────┐
                                    │   Internet      │
                                    └────────┬────────┘
                                             │
                                    ┌────────▼────────┐
                                    │ Ingress (NGINX) │
                                    │   TLS/HTTPS     │
                                    └────────┬────────┘
                                             │
                                    ┌────────▼────────┐
                                    │  API Gateway    │
                                    │   (Port 8080)   │
                                    └────────┬────────┘
                                             │
                ┌────────────────────────────┼────────────────────────────┐
                │                            │                            │
        ┌───────▼──────┐          ┌─────────▼────────┐        ┌─────────▼────────┐
        │ User Service │          │ Product Service  │        │ Order Service    │
        │  (Port 8700) │          │   (Port 8500)    │        │  (Port 8300)     │
        └──────┬───────┘          └────────┬─────────┘        └────────┬─────────┘
               │                           │                            │
        ┌──────▼───────┐          ┌────────▼─────────┐        ┌────────▼─────────┐
        │   MySQL DB   │          │    MySQL DB      │        │    MySQL DB      │
        └──────────────┘          └──────────────────┘        └──────────────────┘

┌──────────────────────────────────────────────────────────────────────────────┐
│                         Infrastructure Services                               │
├──────────────────────────────────────────────────────────────────────────────┤
│  Service Discovery  │  Cloud Config  │   Jaeger   │  Prometheus  │  Grafana │
│     (Eureka)        │   (Port 9296)  │ (Tracing)  │  (Metrics)   │   (UI)   │
│    (Port 8761)      │                │            │              │           │
└──────────────────────────────────────────────────────────────────────────────┘
```
```
| Servicio          | Puerto | Descripción                                      | Base de Datos |
|-------------------|--------|--------------------------------------------------|---------------|
| API Gateway       | 8080   | Punto de entrada único, enrutamiento y balanceo | No            |
| User Service      | 8700   | Gestión de usuarios y autenticación             | MySQL         |
| Product Service   | 8500   | Catálogo de productos                           | MySQL         |
| Order Service     | 8300   | Procesamiento de órdenes                        | MySQL         |
| Payment Service   | 8400   | Gestión de pagos                                | MySQL         |
| Shipping Service  | 8600   | Gestión de envíos                               | MySQL         |
| Favourite Service | 8800   | Lista de favoritos de usuarios                  | MySQL         |
| Proxy Client      | 8900   | Cliente proxy para llamadas HTTP                | No            |
```


✨ Características Principales
🔒 Seguridad

Pod Security Standards: Políticas baseline (dev/qa) y restricted (prod)
Network Policies: Segmentación de red granular
Sealed Secrets: Encriptación de secretos con Bitnami Sealed Secrets
RBAC: Control de acceso basado en roles
TLS/HTTPS: Certificados para endpoints públicos
Security Contexts: Ejecución sin privilegios, filesystem read-only

📊 Observabilidad

Métricas: Spring Boot Actuator + Prometheus
Visualización: Dashboards personalizados en Grafana
Trazabilidad: Jaeger con compatibilidad Zipkin
Logging: Logs centralizados por servicio
Alertas: Sistema de alertas en Prometheus

🚀 Deployment

Blue-Green: Para servicios críticos (Cloud Config, Service Discovery)
Canary: Para servicios orientados al cliente
HPA: Autoescalado horizontal basado en CPU/memoria
Health Checks: Liveness y readiness probes
Rolling Updates: Actualizaciones sin downtime

🔄 CI/CD

GitHub Actions: Pipeline completo automatizado
Escaneo de vulnerabilidades: Trivy para imágenes Docker
Validación de Helm: Lint y template rendering
Testing: Pruebas automatizadas en cluster Kind
Multi-ambiente: Despliegue en dev, qa, prod


📦 Requisitos Previos
Software Necesario
bash# Kubernetes
kubectl >= 1.24

# Helm
helm >= 3.10

# Docker (opcional, para desarrollo local)
docker >= 20.10

# Kubeseal (para gestión de secrets)
kubeseal >= 0.23.0
Cluster Kubernetes

Mínimo: 4 CPU, 8GB RAM
Recomendado: 8 CPU, 16GB RAM
Storage Class: standard disponible
Ingress Controller: NGINX instalado


🚀 Instalación
1. Instalación Rápida (Producción)
bash# Clonar repositorio
git clone <repository-url>
cd helm/ecommerce

# Instalar en producción
helm install my-ecommerce . -f values-prod.yaml

# Aplicar sealed secrets
kubectl apply -f ../secrets/sealedsecrets/prod/
2. Instalación por Ambientes
Desarrollo (dev)
bashhelm install my-ecommerce . -f values-dev.yaml
Características:

Base de datos H2 en memoria
1 réplica por servicio
Pod Security: baseline
Sin persistencia de datos

QA/Staging
bashhelm install my-ecommerce . -f values-qa.yaml
kubectl apply -f ../secrets/sealedsecrets/qa/
Características:

MySQL persistente
1 réplica por servicio
Pod Security: baseline
PersistentVolumes de 10Gi

Producción
bashhelm install my-ecommerce . -f values-prod.yaml
kubectl apply -f ../secrets/sealedsecrets/prod/
Características:

MySQL persistente con backup
HPA habilitado
Pod Security: restricted
Network Policies estrictas

3. Instalación de Monitoreo
bashcd helm/monitoring
helm install my-monitoring . -f values-monitoring.yaml
4. Verificación
bash# Verificar pods
kubectl get pods -n <namespace>

# Verificar servicios
kubectl get svc -n <namespace>

# Verificar ingress
kubectl get ingress -n <namespace>

# Verificar HPA
kubectl get hpa -n <namespace>

```bash

## 📁 Estructura del Proyecto

helm/
├── ecommerce/                          # Chart principal (umbrella)
│   ├── Chart.yaml                      # Metadata del chart
│   ├── values-dev.yaml                 # Valores para desarrollo
│   ├── values-qa.yaml                  # Valores para QA
│   ├── values-prod.yaml                # Valores para producción
│   ├── templates/
│   │   ├── namespace.yaml              # Definición de namespace
│   │   └── networkpolicies.yaml        # Network Policies
│   └── charts/                         # Subcharts de microservicios
│       ├── api-gateway/
│       │   ├── Chart.yaml
│       │   ├── values.yaml
│       │   ├── files/
│       │   │   ├── gateway.crt         # Certificado TLS
│       │   │   └── gateway.key         # Llave privada TLS
│       │   └── templates/
│       │       ├── configmap.yaml
│       │       ├── deployment-stable.yaml
│       │       ├── deployment-canary.yaml
│       │       ├── service.yaml
│       │       ├── ingress.yaml
│       │       ├── hpa.yaml
│       │       ├── service-account.yaml
│       │       └── tls-secret.yaml
│       ├── user-service/
│       ├── product-service/
│       ├── order-service/
│       ├── payment-service/
│       ├── shipping-service/
│       ├── favourite-service/
│       ├── proxy-client/
│       ├── service-discovery/
│       ├── cloud-config/
│       ├── jaeger/
│       └── locust/
├── monitoring/                         # Monitoreo y observabilidad
│   ├── Chart.yaml
│   ├── values-monitoring.yaml
│   ├── charts/
│   │   ├── prometheus/
│   │   │   └── templates/
│   │   │       ├── configmap.yaml      # Scrape configs
│   │   │       ├── deployment.yaml
│   │   │       ├── clusterrole.yaml
│   │   │       └── clusterrolebinding.yaml
│   │   └── grafana/
│   │       ├── dashboards/             # Dashboards JSON
│   │       │   ├── springboot-metrics.json
│   │       │   ├── eureka.json
│   │       │   └── jaeger.json
│   │       └── provisioning/           # Datasources y dashboards
│   └── templates/
│       └── networkpolicies.yaml
└── secrets/                            # Gestión de secretos
    ├── sealedSecrets.sh               # Script para generar sealed secrets
    ├── mycert.pem                     # Certificado público del controlador
    └── sealedsecrets/
        ├── prod/
        │   ├── user-service-db.yaml
        │   ├── product-service-db.yaml
        │   └── ...
        └── qa/
            └── ...
```
⚙️ Configuración de Servicios
ConfigMaps
Los ConfigMaps almacenan configuración no sensible inyectada como variables de entorno:
yamlapiVersion: v1
kind: ConfigMap
metadata:
  name: my-ecommerce-user-service-config
data:
  SPRING_PROFILES_ACTIVE: "prod"
  SPRING_ZIPKIN_BASE_URL: "http://my-ecommerce-zipkin:9411"
  SPRING_CONFIG_IMPORT: "optional:configserver:http://my-ecommerce-cloud-config:9296/"
  EUREKA_CLIENT_SERVICE_URL_DEFAULTZONE: "http://my-ecommerce-service-discovery:8761/eureka/"
  EUREKA_INSTANCE_PREFER_IP_ADDRESS: "true"
Secrets (Sealed Secrets)
Las credenciales de base de datos se gestionan con Sealed Secrets:
bash# Generar sealed secrets
./helm/secrets/sealedSecrets.sh

# Aplicar en el cluster
kubectl apply -f helm/secrets/sealedsecrets/prod/
Estructura de un Sealed Secret:
yamlapiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  name: user-service-db-credentials
  namespace: prod
spec:
  encryptedData:
    DB_USER: AgBYPKY6A8K0gYgB0JOujJ0...
    DB_PASSWORD: AgCU2JZE+o/Ix41cEd68dNo...
Service Accounts
Cada microservicio tiene su propio ServiceAccount con permisos mínimos:
yamlapiVersion: v1
kind: ServiceAccount
metadata:
  name: my-ecommerce-user-service
  namespace: prod
automountServiceAccountToken: false  # Seguridad adicional
Horizontal Pod Autoscaler (HPA)
Configuración de autoescalado:
yamlapiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: my-ecommerce-user-service-hpa-stable
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: my-ecommerce-user-service-stable
  minReplicas: 1
  maxReplicas: 2
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 60
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 80

🔐 Network Policies
Modelo de Seguridad
El proyecto implementa un modelo de Zero Trust con las siguientes capas:

Default Deny All: Todo el tráfico bloqueado por defecto
Allow DNS: Resolución de nombres permitida
Políticas específicas por servicio: Solo tráfico necesario

Tabla de Network Policies
```
| Política                   | Scope / Servicio       | Ingress Permitido                                                                 | Egress Permitido                                                                 | Descripción                 |
|---------------------------|-------------------------|-----------------------------------------------------------------------------------|----------------------------------------------------------------------------------|-----------------------------|
| default-deny-all          | Namespace completo      | ❌ Deny All                                                                        | ❌ Deny All                                                                       | Bloqueo por defecto         |
| allow-dns                 | Namespace completo      | -                                                                                 | ✅ kube-system:53/UDP                                                             | Resolución DNS              |
| api-gateway-policy        | api-gateway             | ✅ Ingress Controller<br>✅ Prometheus<br>✅ Todos los microservicios<br>✅ DNS       | -                                                                                | Gateway principal           |
| user-service-policy       | user-service            | ✅ api-gateway<br>✅ favourite-service<br>✅ Prometheus<br>✅ user-service-db:3306<br>✅ eureka:8761<br>✅ cloud-config:9296<br>✅ jaeger:9411 | - | Gestión de usuarios |
| product-service-policy    | product-service         | ✅ proxy-client<br>✅ favourite-service<br>✅ shipping-service<br>✅ Prometheus<br>✅ product-service-db:3306<br>✅ eureka:8761<br>✅ cloud-config:9296<br>✅ jaeger:9411 | - | Catálogo de productos |
| order-service-policy      | order-service           | ✅ shipping-service<br>✅ payment-service<br>✅ Prometheus<br>✅ order-service-db:3306<br>✅ eureka:8761<br>✅ cloud-config:9296<br>✅ jaeger:9411 | - | Procesamiento de órdenes |
| payment-service-policy    | payment-service         | ✅ api-gateway<br>✅ Prometheus<br>✅ payment-service-db:3306<br>✅ order-service:8300<br>✅ eureka:8761<br>✅ cloud-config:9296<br>✅ jaeger:9411 | - | Gestión de pagos |
| shipping-service-policy   | shipping-service        | ✅ api-gateway<br>✅ Prometheus<br>✅ shipping-service-db:3306<br>✅ order-service:8300<br>✅ product-service:8500<br>✅ eureka:8761<br>✅ cloud-config:9296<br>✅ jaeger:9411 | - | Gestión de envíos |
| favourite-service-policy  | favourite-service       | ✅ api-gateway<br>✅ Prometheus<br>✅ favourite-service-db:3306<br>✅ product-service:8500<br>✅ user-service:8700<br>✅ eureka:8761<br>✅ cloud-config:9296<br>✅ jaeger:9411 | - | Lista de favoritos |
| service-discovery-policy  | service-discovery       | ✅ Todos los microservicios<br>✅ Prometheus<br>✅ jaeger:9411<br>✅ DNS              | -                                                                                | Eureka Server               |
| cloud-config-policy       | cloud-config            | ✅ Todos los microservicios<br>✅ Prometheus<br>✅ GitHub 443/HTTPS<br>✅ eureka:8761<br>✅ jaeger:9411<br>✅ DNS | - | Configuración centralizada |
| jaeger-policy             | jaeger                  | ✅ Todos los microservicios<br>✅ Prometheus:14269<br>✅ Internet (80/443)<br>✅ DNS | -                                                                                | Trazabilidad distribuida    |
| *-db-policy               | Bases de datos MySQL    | -                                                                                 | ✅ Solo su microservicio<br>✅ DNS                                                | Aislamiento de datos        |

```
Ejemplo de Network Policy
yamlapiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: user-service-network-policy
  namespace: prod
spec:
  podSelector:
    matchLabels:
      app: user-service
  policyTypes:
    - Ingress
    - Egress
  ingress:
    # Desde API Gateway
    - from:
        - podSelector:
            matchLabels:
              app: api-gateway
      ports:
        - protocol: TCP
          port: 8700
    # Desde Prometheus (monitoreo)
    - from:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: monitoring
          podSelector:
            matchLabels:
              app: prometheus
  egress:
    # DNS
    - to:
        - namespaceSelector: {}
      ports:
        - protocol: UDP
          port: 53
    # Base de datos
    - to:
        - podSelector:
            matchLabels:
              app: user-service-db
      ports:
        - protocol: TCP
          port: 3306
    # Eureka
    - to:
        - podSelector:
            matchLabels:
              app: service-discovery
      ports:
        - protocol: TCP
          port: 8761

📊 Monitoreo y Observabilidad
Prometheus
Configuración de Scraping:
yamlscrape_configs:
  # Spring Boot Actuator
  - job_name: "spring-boot-actuator"
    kubernetes_sd_configs:
      - role: pod
        namespaces:
          names: [dev, qa, prod]
    relabel_configs:
      # Solo pods con prometheus.io/scrape=true
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
        action: keep
        regex: true
      # Construir endpoint
      - source_labels: [__meta_kubernetes_pod_ip, __meta_kubernetes_pod_annotation_prometheus_io_port]
        separator: ":"
        regex: (.+);(.+)
        replacement: "$1:$2"
        target_label: __address__

  # Jaeger
  - job_name: "jaeger"
    static_configs:
      - targets: ['jaeger:14269']

  # Eureka
  - job_name: "eureka"
    static_configs:
      - targets: ['service-discovery:8761']
Grafana Dashboards
El proyecto incluye 3 dashboards predefinidos:
1. Spring Boot Metrics Dashboard
Paneles principales:

HTTP Request Rate (req/s)
Average JVM Heap Usage (%)
Service Health (UP/DOWN)
Response Time Percentiles (p50, p95, p99)
HTTP Error Rates (4xx/5xx)
JVM Memory (Heap Used vs Max)
JVM Threads (Live/Daemon)
Pod CPU/Memory Usage
Liveness/Readiness Status
Garbage Collector Activity

Variables de Template:

$namespace: Filtrar por namespace
$service: Filtrar por servicio
$pod: Filtrar por pod

2. Eureka Service Discovery Dashboard
Paneles:

Eureka Server Status
Registered Instances
Heartbeats Received
Failed Registrations
Response Time
JVM Memory

3. Jaeger Tracing Dashboard
Paneles:

Received Spans
Dropped Spans
Queue Length
Spans by Transport
Ingest Errors
Jaeger Instances

Acceso a Interfaces
bash# Grafana (LoadBalancer)
kubectl get svc -n monitoring my-monitoring-grafana
# Credenciales por defecto: admin / admin123

# Prometheus
kubectl port-forward -n monitoring svc/my-monitoring-prometheus 9090:9090

# Jaeger UI
kubectl port-forward -n prod svc/my-ecommerce-zipkin 16686:16686

# Eureka Dashboard
kubectl get svc -n prod my-ecommerce-service-discovery

🛡️ Seguridad
Pod Security Standards
AmbientePolicyCaracterísticasdevbaseline- Permite contenedores privilegiados limitados- Filesystem parcialmente restringido- Ideal para desarrolloqabaseline- Configuración similar a dev- Mayor auditoríaprodrestricted- Máxima seguridad- runAsNonRoot obligatorio- readOnlyRootFilesystem- Todas las capabilities eliminadas- Seccomp RuntimeDefault
Security Context (Producción)
yaml# Pod Level
podSecurityContext:
  runAsNonRoot: true
  runAsUser: 1000
  fsGroup: 1000
  seccompProfile:
    type: RuntimeDefault

# Container Level
containerSecurityContext:
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: true
  capabilities:
    drop:
      - ALL
  seccompProfile:
    type: RuntimeDefault
Sealed Secrets Workflow
mermaidgraph LR
    A[Secret Plaintext] -->|kubeseal| B[Sealed Secret]
    B -->|kubectl apply| C[Kubernetes Cluster]
    C -->|Controller decrypt| D[Secret]
    D -->|Mount| E[Pod]
Comandos:
bash# 1. Obtener certificado público
kubeseal --fetch-cert > mycert.pem

# 2. Crear secret y sellarlo
echo -n "mypassword" | kubectl create secret generic my-secret \
  --dry-run=client \
  --from-file=password=/dev/stdin \
  -o yaml | kubeseal --cert mycert.pem -o yaml > sealed-secret.yaml

# 3. Aplicar
kubectl apply -f sealed-secret.yaml
Escaneo de Vulnerabilidades
El pipeline CI/CD incluye escaneo con Trivy:
yaml- name: Scan Docker image with Trivy
  uses: aquasecurity/trivy-action@0.11.2
  with:
    image-ref: ${{ env.DOCKER_USERNAME }}/${{ matrix.service }}:${{ steps.scan-tag.outputs.SCAN_TAG }}
    format: 'template'
    template: '@/contrib/html.tpl'
    output: 'trivy-${{ matrix.service }}.html'
    vuln-type: 'os,library'
    severity: 'HIGH,CRITICAL'

🔄 CI/CD
Pipeline GitHub Actions
El workflow se compone de 4 jobs principales:
mermaidgraph TD
    A[Push/PR] --> B[Build Maven]
    B --> C[Build & Scan Images]
    C --> D[Validate Helm Charts]
    D --> E[Deploy & Test]
    
    B --> B1[Maven Compile]
    B --> B2[Run Tests]
    B --> B3[Upload Artifacts]
    
    C --> C1[Build Docker Image]
    C --> C2[Push to Registry]
    C --> C3[Trivy Scan]
    
    D --> D1[Helm Lint]
    D --> D2[Template Render]
    
    E --> E1[Kind Cluster]
    E --> E2[Helm Install]
    E --> E3[Verify Deployment]
Job 1: Build Maven
Estrategia: Matrix paralela (10 servicios)
yamlstrategy:
  matrix:
    service:
      - user-service
      - product-service
      - payment-service
      # ... otros servicios
Pasos:

✅ Detectar cambios (git diff)
✅ Compilar con Maven
✅ Ejecutar tests
✅ Subir artifacts (.jar)

Job 2: Build & Scan Images
Condicional: Solo en push (no en PRs)
yamlif: github.event_name == 'push'
Pasos:

✅ Descargar artifacts de Maven
✅ Build imagen Docker
✅ Push a Docker Hub (tags: feature-X y latest)
✅ Scan con Trivy (console + HTML report)

Output: Reporte HTML descargable como artifact
Job 3: Validate Helm Charts
yaml- name: Helm lint
  run: helm lint helm/ecommerce/charts/${{ matrix.service }} -f values-ci.yaml

- name: Helm template
  run: helm template ${{ matrix.service }} helm/ecommerce/charts/${{ matrix.service }} \
    -f values-ci.yaml > rendered.yaml
Job 4: Deploy & Test
Ambiente: Cluster Kind local
Flujo:

✅ Crear cluster Kind
✅ Detectar cambios por servicio
✅ Desplegar con tags inteligentes:

Si cambió → tag nuevo (feature-X)
Si no → tag estable (feature-monitoring)


✅ Espera ordenada (Eureka → Config → Servicios)
✅ Verificar deployments
✅ Debug logs si falla

Ejemplo de tag inteligente:
yaml# Si user-service cambió
--set user-service.image.tag=${{ needs.set-env.outputs.IMAGE_TAG }}

# Si no cambió
--set user-service.image.tag=feature-monitoring

🚀 Estrategias de Despliegue
Blue-Green Deployment
Servicios: cloud-config, service-discovery, shipping-service, user-service
Ventajas:

✅ Cambio instantáneo
✅ Rollback inmediato
✅ Zero downtime

Configuración:
yaml# values.yaml
deploymentStrategy:
  type: blue-green
  active: blue  # o green

blue:
  image:
    repository: barcino/cloud-config
    tag: v1.0.0

green:
  image:
    repository: barcino/cloud-config
    tag: v1.1.0
Cambio de versión:
bash# Cambiar a green
helm upgrade my-ecommerce ./helm/ecommerce \
  -f values-prod.yaml \
  --set cloud-config.deploymentStrategy.active=green
Comportamiento:

Solo el deployment activo tiene réplicas > 0
El Service apunta al deployment activo vía label color

Canary Deployment
Servicios: api-gateway, user-service, product-service, order-service, payment-service, favourite-service, proxy-client
Ventajas:

✅ Prueba gradual con tráfico real
✅ Menor riesgo
✅ Feedback rápido

Configuración:
yamlstable:
  image:
    repository: barcino/api-gateway
    tag: v1.0.0
  replicaCount: 3

canary
