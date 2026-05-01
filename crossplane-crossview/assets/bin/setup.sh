#!/bin/bash
set -euo pipefail

echo starting...

cd /root/.assets/

helm repo add stable-crossplane https://charts.crossplane.io/stable
echo "done" >> /tmp/.crossplanerepoadded

helm install crossplane stable-crossplane/crossplane --version 2.2.1 -n crossplane-system --create-namespace --wait
echo "done" >> /tmp/.crossplaneinstalled

helm upgrade --install crossview oci://ghcr.io/crossplane-contrib/crossview-chart/crossview --version 4.3.0 --namespace crossview \
  --create-namespace -f values-crossplane.yaml --wait
echo "done" >> /tmp/.crossviewinstalled







