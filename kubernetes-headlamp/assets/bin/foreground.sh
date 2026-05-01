#!/bin/bash

# Wait for kutils to be available
while [ ! -f /usr/local/bin/kutils.sh ]; do sleep 1; done
source /usr/local/bin/kutils.sh

# Define the same tasks as in setup.sh
koda_task_add "helm-repo" "Add headlamp helm repo"
koda_task_add "headlamp-install" "Installing Headlamp"

# Render the UI
koda_render_ui "Installing Kubernetes Headlamp" "All Set! Headlamp is ready."
