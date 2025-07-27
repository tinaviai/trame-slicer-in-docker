#!/usr/bin/env bash

# Exit immediately if a simple command exits with a non-zero status.
set -o errexit

function set_apt-mirrors() {
  cp /workspace/runtime/apt/sources.aliyun.list /etc/apt/sources.list
}

function install_apt-dependencies() {
  apt update
  apt install --yes wget git
  apt clean
}

function get_trame-slicer() {
  cd /workspace/apps/

  echo "PATH=${PATH}"
  echo "LD_LIBRARY_PATH=${LD_LIBRARY_PATH}"

  python --version --version
  python -m pip --version
  python -m pip install --upgrade pip
  python -m pip install --index-url=https://mirrors.aliyun.com/pypi/simple/ PyYAML wheel

  git clone --depth=1 https://github.com/KitwareMedical/trame-slicer.git
  cd ./trame-slicer/

  python -m venv "${TRAME_VENV}"
  source "${TRAME_VENV}"/bin/activate

  python --version --version
  python -m pip --version
  python -m pip install --upgrade pip
  pip install --index-url=https://mirrors.aliyun.com/pypi/simple/ --editable=./
  wget https://github.com/KitwareMedical/trame-slicer/releases/download/v0.0.1/vtk_mrml-9.4.0-cp310-cp310-manylinux_2_35_x86_64.whl
  pip install vtk_mrml-9.4.0-cp310-cp310-manylinux_2_35_x86_64.whl --find-links=./
}

function build_trame() {
  cd /workspace/

  chown --recursive trame-user:trame-user /deploy/
  gosu trame-user cp --recursive ./setup/ /deploy/

  /opt/trame/entrypoint.sh build
}

set_apt-mirrors
install_apt-dependencies
get_trame-slicer
build_trame
