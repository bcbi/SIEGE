#!/bin/bash
set -Eeu -o pipefail

echo
echo "SIEGE v0.1.0 (2022-11-15)"
echo

parent_dir="/Path/To/SIEGE"

unset JULIA_LOAD_PATH
unset LD_LIBRARY_PATH
export JULIA_PROJECT="${parent_dir}/env"
export JULIA_DEPOT_PATH=":${parent_dir}/build/depot"
export JULIA_PKG_OFFLINE=true

${parent_dir}/julia-1.8.2/bin/julia -J${parent_dir}/build/sysimage.so "$@"

