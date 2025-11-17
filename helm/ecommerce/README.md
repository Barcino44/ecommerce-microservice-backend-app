# Ecommerce Helm chart

This umbrella Helm chart packages the microservices in this repository as subcharts. It provides a minimal, opinionated set of manifests to deploy each Spring Boot microservice.

Quick start
1. Build and push Docker images for each microservice (the repo contains Dockerfiles per module).
2. Update `helm/ecommerce/values.yaml` with your image repository and tags, or use `--set` to override per-service values.
3. Install the chart:

```bash
# example
helm install my-ecommerce ./helm/ecommerce -f helm/ecommerce/values.yaml
```

Environments and namespaces
- The chart supports three environments: `dev`, `qa`, `prod` via `global.targetEnvironment` in `values.yaml`.
- By default the chart will create namespaces defined in `global.namespaces` (dev/qa/prod). The subcharts will place resources in the namespace selected by `global.targetEnvironment`.

Example: install to `qa` namespace set in the chart values:

```bash
helm upgrade --install my-ecommerce ./helm/ecommerce -f helm/ecommerce/values.yaml --set global.targetEnvironment=qa
```

ConfigMaps and Secrets
- Each subchart reads `config` (non-sensitive) and `secrets` (sensitive) keys under its values and will create a ConfigMap and/or Secret.
- Example override in `values.yaml`:

```yaml
product-service:
	config:
		SPRING_PROFILES_ACTIVE: dev
		PRODUCT_DB_URL: jdbc:postgresql://db:5432/products
	secrets:
		PRODUCT_DB_PASSWORD: s3cr3t
```

The deployment will load these as environment variables (via envFrom).

Notes
- Default container ports are set per service in `values.yaml`. Adjust if necessary.
- This is a minimal scaffold. Customize health checks, liveness/readiness probes, resource requests/limits and configmaps as needed.

Suggested next steps
- Add `Ingress` resources or an ingress controller chart to expose `api-gateway` externally.
- Integrate with your CI to build images and run `helm upgrade --install`.
