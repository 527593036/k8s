#!/usr/bin/env bash

FILEPATH=$(cd "$(dirname "$0")"; pwd);cd ${FILEPATH}

. ${FILEPATH}/config.sh

# create the keys for server and kubelet
function create-keys() {
  cd ${FILEPATH}/cert
  ./master-ssl.sh ${MASTER} ${SERVICE_CLUSTER_IP}
  ./keys.sh
  ./node-kubeconfig.sh
  ./master-kubeconfig.sh
}

# Instantiate the keys for a kubernetes cluster
function keys-up() {
  create-keys
}

function sync() {
  rsync -avzP ${FILEPATH}/cert/master ${FILEPATH}/../templates/cert/
  rsync -avzP ${FILEPATH}/cert/node ${FILEPATH}/../templates/cert/
}

function main() {
  keys-up
  sync
}

