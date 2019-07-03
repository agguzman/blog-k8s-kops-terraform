#!/usr/bin/env bash

set -e -o pipefail

TF_OUTPUT=$1
ENV="$(echo ${TF_OUTPUT} | jq -r .env.value)"
CLUSTER_NAME="$(echo ${TF_OUTPUT} | jq -r .kubernetes_cluster_name.value)"
STATE="s3://$(echo ${TF_OUTPUT} | jq -r .kops_s3_bucket.value)"

if [ ! -d $ENV ]; then
    mkdir $ENV
fi

kops toolbox template --name ${CLUSTER_NAME} --values <( echo ${TF_OUTPUT}) --template cluster-template.yaml --format-yaml > $ENV/cluster.yaml

kops replace -f $ENV/cluster.yaml --state ${STATE} --name ${CLUSTER_NAME} --force

# This fails the first time it runs for a non existant cluster.
# A run without this line needs to happen, fail, and then re run with this line to work.
kops create secret --state ${STATE} --name ${CLUSTER_NAME} sshpublickey admin -i ${K8S_CLUSTER_ADMIN_SSHPUB}

kops update cluster --target terraform --state ${STATE} --name ${CLUSTER_NAME} --out ${ENV}
