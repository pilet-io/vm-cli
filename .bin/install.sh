#!/bin/bash

git clone https://github.com/pilet-io/vm-cli.git

mv /root/vm-cli /root/cli
echo "export PATH=\$PATH:/root/cli" >> /root/.profile
/root/cli/with host setup completion

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC='server --tls-san system.kueb.io --flannel-ipv6-masq --cluster-cidr 10.42.0.0/16,2001:cafe:42:0::/56 --service-cidr 10.43.0.0/16,2001:cafe:43:1::/112' sh -s -
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

wget https://github.com/open-telemetry/opentelemetry-collector-releases/releases/download/v0.119.0/otelcol-contrib_0.119.0_linux_amd64.deb
dpkg -i otelcol-contrib_0.119.0_linux_amd64.deb
rm otelcol-contrib_0.119.0_linux_amd64.deb