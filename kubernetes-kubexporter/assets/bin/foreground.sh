#!/bin/bash

# Wait for kutils to be available
while [ ! -f /usr/local/bin/kutils.sh ]; do sleep 1; done
source /usr/local/bin/kutils.sh

# Define the same tasks as in setup.sh
koda_task_add "apt-tree" "Installing tree utility"
koda_task_add "kubexporter-install" "Installing KubExporter"

# Render the UI
koda_render_ui "Installing KubExporter" "All Set! KubExporter is ready."
