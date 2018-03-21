#!/usr/bin/env bash

if [ -z $KUBE_TOKEN ]; then
  echo "FATAL: Environment Variable KUBE_TOKEN must be specified."
  exit ${2:-1}
fi

if [ -z $NAMESPACE ]; then
  echo "FATAL: Environment Variable NAMESPACE must be specified."
  exit ${2:-1}
fi

BASE_URL="https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT"

function print_msg {
    echo "$1" >&2
}

print_msg "Namespace $NAMESPACE"

function exec_curl {


}

status_code=$(curl -sSk -H "Authorization: Bearer $KUBE_TOKEN" \
    "$BASE_URL/apis/apps/v1/namespaces/$NAMESPACE/deployments/bulletin-board-deployment" \
    -X GET -o /dev/null -w "%{http_code}")

if [ $status_code == 200 ]; then
  echo
  echo "Updating deployment"
  curl -H 'Content-Type: application/strategic-merge-patch+json' -sSk -H "Authorization: Bearer $KUBE_TOKEN" \
    "$BASE_URL/apis/apps/v1/namespaces/$NAMESPACE/deployments/bulletin-board-deployment" \
    -X PATCH -d @bulletin-board-deployment.json
else
 echo
 echo "Creating deployment"
 curl  -H 'Content-Type: application/json' -sSk -H "Authorization: Bearer $KUBE_TOKEN" \
    "$BASE_URL/apis/apps/v1/namespaces/$NAMESPACE/deployments" \
    -X POST -d @bulletin-board-deployment.json
fi


status_code=$(curl -sSk -H "Authorization: Bearer $KUBE_TOKEN" \
    "$BASE_URL/api/v1/namespaces/$NAMESPACE/services/bulletin-board-service" \
    -X GET -o /dev/null -w "%{http_code}")

if [ $status_code == 404 ]; then
 echo
 echo "Creating service"
 curl  -H 'Content-Type: application/json' -sSk -H "Authorization: Bearer $KUBE_TOKEN" \
    "$BASE_URL/api/v1/namespaces/$NAMESPACE/services" \
    -X POST -d @bulletin-board-service.json
fi

status_code=$(curl -sSk -H "Authorization: Bearer $KUBE_TOKEN" \
    "$BASE_URL/apis/extensions/v1beta1/namespaces/$NAMESPACE/ingresses/bulletin-board-ingress" \
    -X GET -o /dev/null -w "%{http_code}")

if [ $status_code == 404 ]; then
 echo
 echo "Creating ingress"
 curl  -H 'Content-Type: application/json' -sSk -H "Authorization: Bearer $KUBE_TOKEN" \
    "$BASE_URL/apis/extensions/v1beta1/namespaces/$NAMESPACE/ingresses" \
    -X POST -d @bulletin-board-ingress.json
fi