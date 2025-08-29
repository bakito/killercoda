Install additional tools

## External Secrets

```plain
helm repo add external-secrets-operator https://charts.external-secrets.io/
helm install external-secrets -n external-secrets --create-namespace external-secrets-operator/external-secrets --wait
```{{exec}}


## Cert Manager

```plain
helm repo add cert-manager https://charts.jetstack.io
helm install cert-manager cert-manager/cert-manager --set crds.enabled=true --wait
```{{exec}}