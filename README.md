# BRIX Configuration - GitOps Repository

Production-grade GitOps repository for the BRIX platform, managed by ArgoCD on K3s.

## Architecture

```
Internet
   |
Traefik Ingress (K3s built-in)
   |
FE (Next.js)        <-- public (only service with Ingress)
   | (server-side)
BE (NestJS)          <-- internal (ClusterIP)
   |
Image Service (Flask) <-- internal (ClusterIP)
   |
PostgreSQL / Redis / MinIO  <-- internal (ClusterIP)
```

## Repository Structure

```
BRIX-Configuration/
|
|-- charts/                    # Custom Helm charts
|   |-- fe/                    # Next.js frontend
|   |-- be/                    # NestJS backend
|   |-- image-service/         # Flask image processor
|   |-- redis-commander/       # Redis Web UI (dev only)
|
|-- environments/              # Per-environment value overrides
|   |-- dev/                   # Development values
|   |-- prod/                  # Production values
|
|-- apps/                      # ArgoCD Application manifests
|   |-- dev/                   # Dev ArgoCD apps
|   |-- prod/                  # Prod ArgoCD apps
|
|-- projects/                  # ArgoCD AppProjects
|   |-- brix-dev.yaml
|   |-- brix-prod.yaml
|
|-- root-app.yaml              # App-of-Apps bootstrap
```

## Quick Start

### Prerequisites

- K3s cluster with Traefik Ingress Controller
- ArgoCD installed in the cluster
- `kubectl` configured to access the cluster

### 1. Install ArgoCD (if not installed)

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### 2. Apply AppProjects

```bash
kubectl apply -f projects/
```

### 3. Bootstrap with App-of-Apps

```bash
# This single command deploys EVERYTHING
kubectl apply -f root-app.yaml
```

### 4. Access ArgoCD UI

```bash
# Get the initial admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Port forward to access UI
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Open https://localhost:8080 and login with `admin` / (password from above).

## Services

| Service | Type | Port | Namespace (dev) | Namespace (prod) |
|---------|------|------|-----------------|-------------------|
| Frontend (Next.js) | Ingress (public) | 80/443 | brix-dev | brix-prod |
| Backend (NestJS) | ClusterIP (internal) | 3000 | brix-dev | brix-prod |
| Image Service (Flask) | ClusterIP (internal) | 5000 | brix-dev | brix-prod |
| PostgreSQL | ClusterIP (internal) | 5432 | brix-dev | brix-prod |
| Redis | ClusterIP (internal) | 6379 | brix-dev | brix-prod |
| MinIO | ClusterIP (internal) | 9000 | brix-dev | brix-prod |
| Redis Commander | ClusterIP (dev only) | 8081 | brix-dev | N/A |

## Internal DNS (Service Discovery)

Services communicate via Kubernetes DNS:

```
# From within brix-dev namespace
http://brix-be:3000                    # Backend API
http://brix-image-service:5000         # Image processing
brix-postgres-postgresql:5432          # Database
brix-redis-master:6379                 # Redis
brix-minio:9000                        # Object storage

# Full FQDN (cross-namespace)
http://brix-be.brix-dev.svc.cluster.local:3000
```

## Deployment Flow

```
Developer pushes code
       |
CI/CD builds Docker image
       |
CI/CD updates image tag in environments/{env}/*-values.yaml
       |
Git commit + push
       |
ArgoCD detects change
       |
ArgoCD syncs to cluster
       |
Done!
```

## Environment Differences

| Feature | Dev | Prod |
|---------|-----|------|
| Replicas | 1 | 2-3 (HPA) |
| Image tag | `dev-latest` | `v1.0.0` (pinned) |
| Image pull | `Always` | `IfNotPresent` |
| Auto sync | Yes | Manual |
| Redis auth | Disabled | Enabled |
| PostgreSQL | Standalone | Replication |
| Redis Commander | Enabled | Disabled |
| TLS | Optional | Required |
| Metrics | Disabled | Enabled |

## Important Notes

### Security

- **Only FE is publicly accessible** via Traefik Ingress
- BE, Flask, DB, Redis, MinIO are **internal only** (ClusterIP)
- Browser cannot directly call BE; use Next.js server-side (API routes / Server Actions)
- Replace all `CHANGE_ME` placeholders in prod values before deploying

### Secrets Management

For production, consider using:
- [Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets)
- [External Secrets Operator](https://external-secrets.io/)
- Never commit real production secrets to git

### Infra Charts

Infrastructure services use official Bitnami Helm charts:
- PostgreSQL: `https://charts.bitnami.com/bitnami/postgresql`
- Redis: `https://charts.bitnami.com/bitnami/redis`
- MinIO: `https://charts.bitnami.com/bitnami/minio`

## Customization

### Change Domain

Update these files:
- `environments/dev/fe-values.yaml` → `ingress.hosts[0].host`
- `environments/prod/fe-values.yaml` → `ingress.hosts[0].host` + `ingress.tls`
- `environments/dev/redis-commander-values.yaml` → `ingress.hosts[0].host`

### Change Docker Registry

Update `image.repository` in all `environments/{env}/*-values.yaml` files.

### Enable TLS (HTTPS)

1. Install cert-manager: `kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.0/cert-manager.yaml`
2. Create a ClusterIssuer for Let's Encrypt
3. Uncomment `cert-manager.io/cluster-issuer` annotation in prod fe-values.yaml