#!/usr/bin/env bash

# Wait for OTel Collector to be ready before proceeding
echo "Waiting for monitoring stack to be ready..."
kubectl wait --for=condition=available deployment/otel-collector -n monitoring --timeout=60s 2>/dev/null || true
kubectl wait --for=condition=available deployment/grafana -n monitoring --timeout=60s 2>/dev/null || true
kubectl wait --for=condition=available deployment/prometheus-server -n monitoring --timeout=60s 2>/dev/null || true
echo "Monitoring stack is ready."

mkdir -p "kubexporter"
clear
cd kubexporter
