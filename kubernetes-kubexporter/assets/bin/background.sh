#!/bin/bash
set -euo pipefail

source /root/.assets/bin/kutils.sh

# Initialize tasks
koda_task_init "apt-tree" "Installing tree utility"
koda_task_init "kubexporter-install" "Installing KubExporter"

# Execute tasks
if koda_task_check "apt-tree" "tree" "Installing tree utility"; then
  apt update && apt install -y tree
  koda_task_done "apt-tree"
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
