#!/usr/bin/env bash

# Exit immediately if a simple command exits with a non-zero status.
set -o errexit

if [[ -n "${1}" ]]; then
  if [[ "${1}" =~ ^3(\.[0-9]+){2}$ ]]; then
    PYTHON_VERSION="${1}"
  else
    echo "ERROR: Input argument PYTHON_VERSION is invalid."
    exit 1
  fi
else
  echo "ERROR: Input argument PYTHON_VERSION is missing."
  exit 1
fi

function set_apt-mirrors() {
  cp /workspace/runtime/sources.aliyun.list /etc/apt/sources.list
}

function install_apt-dependencies() {
  apt update
  apt install --yes wget git
  apt clean
}

function build_my-shared-python() {
  cd /workspace/runtime/

  echo "PATH=${PATH}"
  echo "LD_LIBRARY_PATH=${LD_LIBRARY_PATH}"

  python --version --version
  python -m pip --version

  # wget "https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tar.xz"
  wget "https://mirrors.aliyun.com/python-release/source/Python-${PYTHON_VERSION}.tar.xz"

  tar --extract --file="./Python-${PYTHON_VERSION}.tar.xz" --directory="./"
  cd "./Python-${PYTHON_VERSION}/"

  apt update
  apt build-dep --yes python3
  apt install --yes \
    build-essential gdb lcov pkg-config \
    libbz2-dev libffi-dev libgdbm-dev libgdbm-compat-dev liblzma-dev \
    libncurses5-dev libreadline6-dev libsqlite3-dev libssl-dev \
    lzma lzma-dev tk-dev uuid-dev zlib1g-dev libmpdec-dev libzstd-dev

  mkdir ./MyPython/
  ./configure --prefix="${PWD}/MyPython/" --enable-optimizations --with-lto --enable-shared
  make --silent --jobs="$(nproc)"
  make altinstall

  local XY=${PYTHON_VERSION%.*}
  mv "/usr/bin/python3"     "/usr/bin/python3-src"     || echo "SKIP."
  mv "/usr/bin/python${XY}" "/usr/bin/python${XY}-src" || echo "SKIP."
  update-alternatives --install "/usr/bin/python3"     "python3"     "${PWD}/MyPython/bin/python${XY}" 2
  update-alternatives --install "/usr/bin/python${XY}" "python${XY}" "${PWD}/MyPython/bin/python${XY}" 2
}

set_apt-mirrors
install_apt-dependencies
build_my-shared-python
