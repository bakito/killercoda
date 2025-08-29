#!/bin/bash
set -euo pipefail

echo starting...

cd /root/.assets/

helm repo add headlamp https://kubernetes-sigs.github.io/headlamp/
echo "done" >> /tmp/.headlamprepoadded

helm install headlamp headlamp/headlamp -n headlamp --create-namespace -f headlamp/values.yaml --wait
echo "done" >> /tmp/.headlampinstalled
