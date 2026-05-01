#!/bin/bash
source scripts/kutils.sh

# Mock Killercoda environment
export KODA_DIR="/tmp/koda-test"
rm -rf "$KODA_DIR"
mkdir -p "$KODA_DIR"

# Background process simulation
(
  koda_task_init "task1" "Download Assets"
  koda_task_init "task2" "Install Tools"
  koda_task_init "task3" "Configure System"

  sleep 2
  koda_task_start "task1"
  sleep 2
  koda_task_done "task1"

  sleep 1
  koda_task_start "task2"
  sleep 3
  koda_task_done "task2"

  sleep 1
  koda_task_start "task3"
  sleep 2
  koda_task_done "task3"
) &

# Foreground process
koda_task_add "task1" "Download Assets"
koda_task_add "task2" "Install Tools"
koda_task_add "task3" "Configure System"

koda_render_ui "Test Scenario" "Test Complete!"
