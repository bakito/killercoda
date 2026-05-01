#!/bin/bash

source /root/.assets/bin/kutils.sh

# Define the same tasks as in setup.sh
koda_task_add "apt-tree" "Installing tree utility"
koda_task_add "kubexporter-install" "Installing KubExporter"

# Render the UI
koda_render_ui "Installing KubExporter" "All Set! KubExporter is ready."
