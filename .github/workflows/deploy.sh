#!/usr/bin/env bash
set -e

ROOT=${GITHUB_WORKSPACE:-$(cd $(dirname $0)/../.. && pwd)}

function app_push() {
  NAME=$1
  OUTPUT_FN=$ROOT/tmp/${NAME}-generated.yaml
  mkdir -p "$(dirname $OUTPUT_FN)" || echo "could not create ${OUTPUT_FN}."
  cat $ROOT/.github/workflows/k8s.yaml.template |
    sed -e 's,<NS>,'${K8S_NS}',g' |
    sed -e 's,<APP>,'${NAME}',g' |
    sed -e 's,<GCR_PROJECT>,'${GCLOUD_PROJECT}',g' >$OUTPUT_FN
  cat "$OUTPUT_FN"
  kubectl apply -f "$OUTPUT_FN" -n "$K8S_NS" || echo "could not deploy."
}

echo "starting in $ROOT. "
cd $ROOT/../..
#kubectl delete ns/$K8S_NS || echo "couldn't delete the $K8S_NS namespace. Maybe it doesn't exist?"
app_push customers
app_push orders
app_push edge
