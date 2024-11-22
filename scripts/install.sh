#!/bin/bash

curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
sed -i 's|#force_color_prompt=yes|force_color_prompt=yes|g' /root/.bashrc
mkdir -p /root/.kube
cp /etc/rancher/k3s/k3s.yaml /root/.kube/config
