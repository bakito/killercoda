#!/bin/bash

source /root/.assets/bin/kutils.sh

# Define the same tasks as in setup.sh
koda_task_add "helm-repo" "Add headlamp helm repo"
koda_task_add "headlamp-install" "Installing Headlamp"

# Render the UI
koda_render_ui "Installing Kubernetes Headlamp" "All Set! Headlamp is ready."
