#!/usr/bin/env bash

# NOTE: Killercoda runs foreground scripts inside the user's interactive terminal shell.
# Do not use 'set -e', 'exec' or 'exit' here, otherwise the terminal session is terminated.
while [ ! -f /root/.assets/bin/foreground.sh ]; do sleep 1; done
/root/.assets/bin/foreground.sh
