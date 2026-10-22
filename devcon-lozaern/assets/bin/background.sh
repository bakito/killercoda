#!/usr/bin/env bash
set -euo pipefail

source /root/.assets/bin/kutils.sh

# Initialize tasks
koda_task_init "devbox-install" "Preparing Environment"
koda_task_init "presentation-setup" "Preparing Presentation"

# Execute tasks
if koda_task_check "devbox-install" "devbox" "Preparing Environment"; then
  # Install DevBox using the official install script
  curl -fsSL https://get.jetify.com/devbox | bash -s -- -f
  koda_task_done "devbox-install"
fi

if koda_task_check "presentation-setup" "presentation" "Preparing Presentation"; then
  git clone https://github.com/bakito/devcon-lozaern.git
  cd devcon-lozaern

  devbox install --config $(pwd)/killercoda/devbox.json 2>&1 | tee /tmp/devbox-nix.log
  koda_task_done "presentation-setup"
fi
