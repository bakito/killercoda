#!/usr/bin/env bash

source /root/.assets/bin/kutils.sh

# Define the same tasks as in background.sh
koda_task_add "kubexporter-install" "Installing KubExporter"
koda_task_add "helm-repos" "Adding Helm repositories"
koda_task_add "prometheus-install" "Deploying Prometheus"
koda_task_add "otel-collector-install" "Deploying OTel Collector"
koda_task_add "grafana-install" "Deploying Grafana"
koda_task_add "grafana-dashboard" "Installing KubExporter dashboard"
koda_task_add "kubexporter-config" "Creating KubExporter config"

# Render the UI
koda_render_ui "Setting up KubExporter & Monitoring Stack" "All Set! KubExporter and monitoring stack are ready."
