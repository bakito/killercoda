Generate Access Token

```plain
kubectl create token headlamp -n headlamp
```{{exec}}


Use the generated token to access the [Headlamp Dashboard]({{TRAFFIC_HOST1_30080}})

External Secrets 

```plain
helm repo add external-secrets-operator https://charts.external-secrets.io/
helm install external-secrets -n external-secrets --create-namespace  external-secrets-operator/external-secrets  --wait
```{{exec}}


Cert Manager

```plain
helm repo add cert-manager https://charts.jetstack.io
helm install my-cert-manager cert-manager/cert-manager --set crds.enabled=true  --wait
```{{exec}}