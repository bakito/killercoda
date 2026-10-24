#!/usr/bin/env bash
set -euo pipefail

source /root/.assets/bin/kutils.sh

# Initialize tasks
koda_task_init "kubexporter-install" "Installing KubExporter"
koda_task_init "helm-repos" "Adding Helm repositories"
koda_task_init "prometheus-install" "Deploying Prometheus"
koda_task_init "otel-collector-install" "Deploying OTel Collector"
koda_task_init "grafana-install" "Deploying Grafana"
koda_task_init "grafana-dashboard" "Installing KubExporter dashboard"
koda_task_init "kubexporter-config" "Creating KubExporter config"

# Execute tasks
if koda_task_check "kubexporter-install" "kubexporter" "Installing KubExporter"; then
  # Get latest Version
  LATEST_VERSION=$(curl -s https://api.github.com/repos/bakito/kubexporter/releases/latest | grep tag_name | cut -d '"' -f 4)

  # Download the binary
  curl -s -L -o /tmp/kubexporter.tar.gz "https://github.com/bakito/kubexporter/releases/download/${LATEST_VERSION}/kubexporter_${LATEST_VERSION#v}_linux_amd64.tar.gz"

  # Extract the binary
  tar xzf /tmp/kubexporter.tar.gz -C /tmp

  # Move binary to /usr/local/bin
  mv /tmp/kubexporter /usr/local/bin/
  koda_task_done "kubexporter-install"
fi

koda_task_start "helm-repos"
if helm repo add grafana https://grafana.github.io/helm-charts >/dev/null 2>&1 && \
   helm repo update >/dev/null 2>&1; then
  koda_task_done "helm-repos"
else
  koda_task_error "helm-repos" "Failed to add Helm repositories"
  koda_task_fail "helm-repos" true
fi

# Create monitoring namespace
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f - >/dev/null 2>&1 || true

koda_task_start "prometheus-install"
if helm upgrade --install prometheus oci://ghcr.io/prometheus-community/charts/prometheus -n monitoring -f /root/.assets/manifests/prometheus-values.yaml --wait --timeout 180s >/dev/null 2>&1; then
  # Wait for Prometheus to be ready to accept remote-write
  if ! kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=prometheus -n monitoring --timeout=120s >/dev/null 2>&1; then
    koda_task_error "prometheus-install" "Prometheus pod not ready"
    koda_task_fail "prometheus-install" true
  fi
  koda_task_done "prometheus-install"
else
  koda_task_error "prometheus-install" "Helm install failed — see stderr for details"
  echo "ERROR: Prometheus Helm install failed!" >&2
  koda_debug_deployment prometheus-server monitoring
  koda_task_fail "prometheus-install" true
fi

koda_task_start "otel-collector-install"
if kubectl apply -f /root/.assets/manifests/otel-collector-config.yaml >/dev/null 2>&1 && \
   kubectl apply -f /root/.assets/manifests/otel-collector.yaml >/dev/null 2>&1 && \
   kubectl rollout status deployment otel-collector -n monitoring --timeout=180s >/dev/null 2>&1; then
  koda_task_done "otel-collector-install"
else
  koda_task_error "otel-collector-install" "Failed to deploy OTel Collector — see stderr for details"
  echo "ERROR: OTel Collector deployment failed!" >&2
  koda_debug_deployment otel-collector monitoring
  koda_task_fail "otel-collector-install" true
fi

koda_task_start "grafana-install"
if helm upgrade --install grafana grafana/grafana -n monitoring -f /root/.assets/manifests/grafana-values.yaml --wait --timeout 180s >/dev/null 2>&1; then
  koda_task_done "grafana-install"
else
  koda_task_error "grafana-install" "Helm install failed — see stderr for details"
  echo "ERROR: Grafana Helm install failed!" >&2
  koda_debug_deployment grafana monitoring
  koda_task_fail "grafana-install" true
fi

koda_task_start "grafana-dashboard"
# Wait for Grafana to be ready
if ! kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=grafana -n monitoring --timeout=120s >/dev/null 2>&1; then
  koda_task_error "grafana-dashboard" "Grafana pod not ready"
  koda_task_fail "grafana-dashboard" true
fi

# Get Grafana URL via NodePort (Killercoda remote ingress)
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
GRAFANA_URL="http://${NODE_IP}:30030"

# Download the raw v2 dashboard from GitHub
if ! wget -q -O /tmp/kubexporter-dashboard.json https://raw.githubusercontent.com/bakito/kubexporter/refs/heads/main/examples/grafana/dashboard.json; then
  koda_task_error "grafana-dashboard" "Failed to download dashboard from GitHub"
  koda_task_fail "grafana-dashboard" true
fi

# The v2 dashboard schema is served by the versioned API groups v2beta1 / v2alpha1.
# The upstream file declares the unversioned "dashboard.grafana.app/v2", which no scheme knows.
IMPORTED=false
for API_VERSION in v2beta1 v2alpha1; do
  sed "s#\"apiVersion\": *\"dashboard.grafana.app/v2[a-z0-9]*\"#\"apiVersion\": \"dashboard.grafana.app/${API_VERSION}\"#" \
    /tmp/kubexporter-dashboard.json > "/tmp/kubexporter-dashboard-${API_VERSION}.json"
  if curl -sf -X POST "${GRAFANA_URL}/apis/dashboard.grafana.app/${API_VERSION}/namespaces/default/dashboards" \
    -H "Content-Type: application/json" \
    -d "@/tmp/kubexporter-dashboard-${API_VERSION}.json" >/dev/null 2>&1; then
    IMPORTED=true
    break
  fi
done

if [ "$IMPORTED" = true ]; then
  koda_task_done "grafana-dashboard"
else
  koda_task_error "grafana-dashboard" "Failed to import dashboard via v2 API"
  echo "ERROR: Dashboard v2 API import failed! Available dashboard API versions:" >&2
  curl -s "${GRAFANA_URL}/apis/dashboard.grafana.app" >&2 2>&1 || true
  echo "ERROR: Response for v2beta1 import attempt:" >&2
  curl -s -X POST "${GRAFANA_URL}/apis/dashboard.grafana.app/v2beta1/namespaces/default/dashboards" \
    -H "Content-Type: application/json" \
    -d @/tmp/kubexporter-dashboard-v2beta1.json >&2 2>&1 || true
  koda_task_fail "grafana-dashboard" true
fi

koda_task_start "kubexporter-config"
mkdir -p ~/.kubexporter
cat > ~/.kubexporter/config.yaml << EOF
metrics:
  otlp:
    enabled: true
    endpoint: "${NODE_IP}:30031"
    insecure: true
EOF
koda_task_done "kubexporter-config"
