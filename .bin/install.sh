#!/bin/bash

git clone https://github.com/pilet-io/vm-cli.git

mv /root/vm-cli /root/cli
echo "export PATH=\$PATH:/root/cli" >> /root/.profile
/root/cli/with host setup completion

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --tls-san $VMNAME.kueb.io --flannel-ipv6-masq --cluster-cidr 10.42.0.0/16,2001:cafe:42:0::/56 --service-cidr 10.43.0.0/16,2001:cafe:43:1::/112" sh -s -
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

wget https://github.com/open-telemetry/opentelemetry-collector-releases/releases/download/v0.119.0/otelcol-contrib_0.119.0_linux_amd64.deb
dpkg -i otelcol-contrib_0.119.0_linux_amd64.deb
rm otelcol-contrib_0.119.0_linux_amd64.deb

cat <<EOF > /etc/otelcol-contrib/config.yaml
extensions:
  health_check:
  pprof:
    endpoint: 0.0.0.0:1777
  zpages:
    endpoint: 0.0.0.0:55679

receivers:
  hostmetrics:
    collection_interval: 30s
    scrapers:
      cpu:
      memory:
      disk:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318

processors:
  batch:
  resource:
    attributes:
    - key: "host.name"
      value: "SYS_HOSTNAME"
      action: upsert

exporters:
  otlphttp:
    endpoint: https://system.kueb.io:4318

service:

  pipelines:

    traces:
      receivers: [otlp]
      processors: [batch]
      exporters: [otlphttp]

    metrics:
      receivers: [otlp, hostmetrics]
      processors: [resource,batch]
      exporters: [otlphttp]

    logs:
      receivers: [otlp]
      processors: [batch]
      exporters: [otlphttp]

  extensions: [health_check, pprof, zpages]
EOF