#!/usr/bin/env bash

ISTIO_VERSION=${1:-0.2.7}   ## version: 0.5.1, 0.5.0
WORKING_DIR=${PWD}
ISTIO_HOME=${WORKING_DIR}/istio-${ISTIO_VERSION}
ISTIO_SAMPLE_APP_NS=bookinfo

export PATH="$PATH:${ISTIO_HOME}/bin"
cd ${ISTIO_HOME}

kubectl create ns ${ISTIO_SAMPLE_APP_NS}
kubectl config set-context $(kubectl config current-context) --namespace=${ISTIO_SAMPLE_APP_NS}
kubectl apply -f <(istioctl kube-inject -f samples/bookinfo/kube/bookinfo.yaml)

cd ${WORKING_DIR}
