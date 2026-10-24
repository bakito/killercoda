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
ls -alh ~/kubexporter/exports
```{{exec}}

## Send Metrics via OTLP to Grafana

The scenario includes a pre-configured monitoring stack with Prometheus, OpenTelemetry Collector, and Grafana. Run kubexporter with OTLP metrics enabled to send metrics to the collector:

```plain
kubexporter --config ~/.kubexporter/config.yaml
```{{exec}}

After running, view the kubexporter metrics in the monitoring dashboards:

- [Grafana Dashboard]({{TRAFFIC_HOST1_30030}}/d/kubexporter-metrics/kubexporter-metrics) — visual charts and metrics
- [Prometheus]({{TRAFFIC_HOST1_30090}}) — raw metrics query interface

The Grafana dashboard shows:

- **Duration & Errors Trend** — execution time and error counts over time
- **Resource Instances** — count of exported resources by kind
- **Exported Resources** — total resources and data size per run
- **Query & Export Duration** — time spent querying and exporting
- **Kinds & Namespaces** — breakdown by resource kind and namespace

The kubexporter config is pre-configured at `~/.kubexporter/config.yaml` with the OTLP endpoint pointing to the OpenTelemetry Collector.


