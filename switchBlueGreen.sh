#!/bin/bash

environment=$1
chartURL="charts/ingressrule"


if [ -z "$environment" ]; then
  echo "Environment is required"
  exit 1
fi

echo "Switching to $environment environment"

helm uninstall "ingressrule"
status=$?

if [ $status -eq 0 ]; then
  echo "Ingress deleted successfully"
else
  echo "Not found ingressrule release"
fi


helm install --set namespace=$environment ingressrule $chartURL
