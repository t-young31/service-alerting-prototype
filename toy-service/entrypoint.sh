#!/bin/bash
set -o errexit
set -o nounset

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

pip install "${SCRIPT_DIR}"
cd "${SCRIPT_DIR}/src/toyapi" || exit
uvicorn main:app --port 8000
