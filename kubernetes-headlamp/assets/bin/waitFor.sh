#!/bin/bash
set -e
while [ ! -f $1 ]; do
  sleep 2
done