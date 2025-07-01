#!/usr/bin/env bash

# Exit immediately if a simple command exits with a non-zero status.
set -o errexit

python3.10 --version
python3.10 -m pip --version

apt update
apt install --yes vim git wget

cd /workspace/

wget https://www.python.org/ftp/python/3.10.18/Python-3.10.18.tar.xz
tar -xf ./Python-3.10.18.tar.xz
cd ./Python-3.10.18/

apt-get update
apt-get build-dep --yes python3
apt-get install --yes \
    build-essential gdb lcov pkg-config \
    libbz2-dev libffi-dev libgdbm-dev libgdbm-compat-dev liblzma-dev \
    libncurses5-dev libreadline6-dev libsqlite3-dev libssl-dev \
    lzma lzma-dev tk-dev uuid-dev zlib1g-dev libmpdec-dev libzstd-dev

mkdir ./MyPython/
./configure --prefix="${PWD}/MyPython/" --enable-shared --enable-optimizations --with-lto
make -s -j "$(nproc)"
make altinstall

export LD_LIBRARY_PATH="${PWD}:${LD_LIBRARY_PATH}"
./python --version
./python -m pip --version
