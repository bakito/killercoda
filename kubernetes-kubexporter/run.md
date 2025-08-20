Run with default configuration

```plain
kubexporter
```{{exec}}

Run with multiple worker and different theme

```plain
kubexporter --worker 5 --progress bubbles
```{{exec}}

Run only on namespace `kube-system` with plain mode and summary

```plain
kubexporter --worker 5 \
  --progress simple \
  --summary \
  --size \
  --namespace kube-system
```{{exec}}

Find exported files in folder kubexporter

```plain
tree ~/kubexporter
```{{exec}}


