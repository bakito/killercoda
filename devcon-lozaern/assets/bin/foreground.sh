#!/usr/bin/env bash

source /root/.assets/bin/kutils.sh

# Define the same tasks as in background.sh
koda_task_add "devbox-install" "Preparing Environment"
koda_task_add "presentation-setup" "Preparing Presentation"

# Render the UI
koda_render_ui "Wait until we prepare the Presentation..." "All Set! Presentation is ready! - Continue with START"

cd devcon-lozaern/killercoda
devbox run k8s-setup killercoda/devbox.json
