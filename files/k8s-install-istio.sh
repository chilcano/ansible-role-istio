#!/usr/bin/env bash

ISTIO_VERSION=${1:-0.2.7}     # version: 0.5.1, 0.5.0
WORKING_DIR=${PWD}
ISTIO_HOME=${WORKING_DIR}/istio-${ISTIO_VERSION}

curl -kL https://git.io/getLatestIstio | sed 's/curl/curl -k /g' | ISTIO_VERSION=${ISTIO_VERSION} sh -
export PATH="$PATH:${ISTIO_HOME}/bin"
cd ${ISTIO_HOME}

# workaround bug
sed -i'.bak' 's/mtlsExcludedServices/#mtlsExcludedServices/' install/kubernetes/istio.yaml
#sed -i'.bak' 's/mtlsExcludedServices/#mtlsExcludedServices/' install/kubernetes/istio-auth.yaml

# creating istio namespace
kubectl create ns istio-system

# installing istio core
kubectl apply -f install/kubernetes/istio.yaml


if [ $ISTIO_VERSION = '0.5.0' ]; then
  # fixing bug in servicegraph
  DATE=$(date '+%Y%m%d%H%M%S')
  sed -i'.bak' 's/servicegraph:0.5.0/servicegraph:0.5.1/g' install/kubernetes/addons/servicegraph.yaml
fi

if [ $ISTIO_VERSION = '0.5.1' ]; then
  # adding 'namespace: istio-system' prometheus ServiceAccount
  perl -i'.bak' -0pe 's/(.*apiVersion: v1\nkind: ServiceAccount\nmetadata:\n\s\sname: prometheus.*)/$1\n  namespace: istio-system/' install/kubernetes/addons/prometheus.yaml
fi

# installing istio addons: monitoring/metrics, dashboard, service graph, tracing (zipkin or jaeger)
kubectl apply -f install/kubernetes/addons/prometheus.yaml
kubectl apply -f install/kubernetes/addons/grafana.yaml
kubectl apply -f install/kubernetes/addons/servicegraph.yaml
kubectl apply -f install/kubernetes/addons/zipkin.yaml
#kubectl apply -f https://raw.githubusercontent.com/jaegertracing/jaeger-kubernetes/master/all-in-one/jaeger-all-in-one-template.yml -n istio-system

cd ${WORKING_DIR}
