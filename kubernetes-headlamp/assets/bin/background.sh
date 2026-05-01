#!/bin/bash
set -euo pipefail

# Copy kutils to /usr/local/bin if it exists in the assets
if [ -f /root/.assets/bin/kutils.sh ]; then
  cp /root/.assets/bin/kutils.sh /usr/local/bin/kutils.sh
  chmod +x /usr/local/bin/kutils.sh
fi

source /usr/local/bin/kutils.sh

# Initialize tasks
koda_task_init "helm-repo" "Add headlamp helm repo"
koda_task_init "headlamp-install" "Installing Headlamp"

# Execute tasks
koda_task_start "helm-repo"
if helm repo add headlamp https://kubernetes-sigs.github.io/headlamp/ ; then
  koda_task_done "helm-repo"
else
  koda_task_fail "helm-repo" true
fi

koda_task_start "headlamp-install"
if helm install headlamp headlamp/headlamp -n headlamp --create-namespace -f /root/.assets/headlamp/values.yaml --wait ; then
  koda_task_done "headlamp-install"
else
  koda_task_fail "headlamp-install" true
fi
