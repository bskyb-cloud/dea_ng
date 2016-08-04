#!/bin/bash
set -e -x -u

cd $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/..
vagrant up
echo "===== VAGRANT BOX PROVISIONED AND STARTED ====="


echo "about to ssh to run tests"
date

if [ -z ${NOTEST:=} ]; then
  vagrant ssh -c "/var/cf-release/src/dea-hm-workspace/src/dea_next/bin/start_warden_and_run_specs.sh"
fi
