#!/usr/bin/env bash
set -euo pipefail

source /root/.assets/bin/kutils.sh

# Initialize tasks
koda_task_init "devbox-install" "Preparing Environment"
koda_task_init "kubexporter-install" "Installing KubExporter"
koda_task_init "presentation-setup" "Preparing Presentation"

# Execute tasks
if koda_task_check "devbox-install" "devbox" "Preparing Environment"; then
  # Install DevBox using the official install script
  curl -fsSL https://get.jetify.com/devbox | bash -s -- -f
  koda_task_done "devbox-install"
fi

if koda_task_check "kubexporter-install" "kubexporter" "Installing KubExporter"; then
  # Get latest Version
  LATEST_VERSION=$(curl -s https://api.github.com/repos/bakito/kubexporter/releases/latest | grep tag_name | cut -d '"' -f 4)

  # Download the binary
  curl -s -L -o /tmp/kubexporter.tar.gz "https://github.com/bakito/kubexporter/releases/download/${LATEST_VERSION}/kubexporter_${LATEST_VERSION#v}_linux_amd64.tar.gz"

  # Extract the binary
  tar xzf /tmp/kubexporter.tar.gz -C /tmp

  # Move binary to /usr/local/bin
  mv /tmp/kubexporter /usr/local/bin/
  koda_task_done "kubexporter-install"
fi


if koda_task_check "presentation-setup" "presentation" "Preparing Presentation"; then
  git clone https://github.com/bakito/devcon-lozaern.git
  cd devcon-lozaern

  devbox install --config $(pwd)/killerkoda/devbox.json 2>&1 | tee /tmp/devbox-nix.log
  koda_task_done "presentation-setup"
fi
