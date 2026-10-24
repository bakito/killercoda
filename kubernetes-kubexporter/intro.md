Install and run kubexporter

This scenario demonstrates KubExporter with a full observability stack:

- **Prometheus** — metrics storage and scraping
- **OpenTelemetry Collector** — receives OTLP metrics from KubExporter
- **Grafana** — pre-configured dashboard for visualizing KubExporter metrics

The monitoring stack is deployed automatically when the scenario starts. KubExporter is configured to send metrics via
OTLP to the collector, which exposes them to Prometheus. The Grafana dashboard tab shows sync metrics after you run
KubExporter with `--otlp-metrics`.
