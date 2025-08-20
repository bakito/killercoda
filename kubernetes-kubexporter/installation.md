Get the latest kubexporter release version

```plain
LATEST_VERSION=$(curl -s https://api.github.com/repos/bakito/kubexporter/releases/latest \
  | grep tag_name | cut -d '"' -f 4)
```{{exec}}

Install kubexporter binary

```plain
# Download the binary
curl -s -L -o /tmp/kubexporter.tar.gz "https://github.com/bakito/kubexporter/releases/download/${LATEST_VERSION}/kubexporter_${LATEST_VERSION#v}_linux_amd64.tar.gz"

# Extract the binary
tar xzf /tmp/kubexporter.tar.gz -C /tmp

# Move binary to /usr/local/bin
sudo mv /tmp/kubexporter /usr/local/bin/
```{{exec}}

Verify the installation

```plain
kubexporter --version
```{{exec}}