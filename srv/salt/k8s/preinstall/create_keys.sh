#!/usr/bin/env bash
#
# Created on 2017/7/9
#
# @author: zhujin

set -o errexit
set -o nounset
set -o pipefail

FILEPATH=$(cd "$(dirname "$0")"; pwd);cd ${FILEPATH}

source "${FILEPATH}/util.sh"

echo "... calling keys-up" >&2
main

exit 0