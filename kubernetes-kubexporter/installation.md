Get the latest kubexporter release from https://github.com/bakito/kubexporter/releases

Verify the installation

```plain
kubexporter --version
```{{exec}}

The scenario also deploys a monitoring stack automatically:

- **Prometheus** on NodePort 30090
- **OpenTelemetry Collector** on NodePort 30031 (OTLP gRPC)
- **Grafana** on NodePort 30030 with the kubexporter dashboard pre-loaded

KubExporter is pre-configured at `~/.kubexporter/config.yaml` to send metrics via OTLP to the collector. You can run `kubexporter --otlp-metrics` to export resources and view the metrics in the Grafana dashboard tab.