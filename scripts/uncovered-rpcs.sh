#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0

# uncovered-rpcs.sh: print the RPCs in the generated gRPC stubs
# (src/openshell/_proto/*_pb2_grpc.py) that no SDK code under src/openshell
# calls, one "Service.Method" per line. The bindings themselves don't count.
# Full method names in the stubs look like "/openshell.v1.OpenShell/CreateSandbox".
set -euo pipefail

ls src/openshell/_proto/*_pb2_grpc.py >/dev/null 2>&1 || exit 0
grep -ho "['\"]/[a-zA-Z0-9_.]*\.[A-Za-z0-9_]*/[A-Za-z0-9_]*['\"]" \
  src/openshell/_proto/*_pb2_grpc.py | tr -d "'\"" | sort -u |
  while read -r m; do
    service=${m#/}; service=${service%%/*}; service=${service##*.}
    method=${m##*/}
    grep -rqE "\.${method}\(" src/openshell --include='*.py' --exclude-dir=_proto ||
      echo "${service}.${method}"
  done
