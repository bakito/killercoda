#!/bin/bash
set +ex
echo starting...

cd /root/.assets/

helm repo add headlamp https://kubernetes-sigs.github.io/headlamp/
helm install headlamp headlamp/headlamp -n headlamp --create-namespace -f headlamp/values.yaml --wait

touch /tmp/finished