#!/bin/bash
set -o errexit
set -o nounset

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
venv_path="${SCRIPT_DIR}/.venv"

python3 -m venv "$venv_path"
source "${venv_path}/bin/activate"
pip install "${SCRIPT_DIR}"
(
  cd "${SCRIPT_DIR}/src/toyapi" || exit
  uvicorn main:app --port 8000
)
