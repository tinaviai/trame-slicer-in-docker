#!/usr/bin/env bash

# Exit immediately if a simple command exits with a non-zero status.
set -o errexit

cd /workspace/

git clone --depth=1 https://github.com/KitwareMedical/trame-slicer.git
cd ./trame-slicer/

python -m venv ./.venv/
source ./.venv/bin/activate

pip install \
    --index-url  https://pypi.tuna.tsinghua.edu.cn/simple/ \
    --editable   ./

wget https://github.com/KitwareMedical/trame-slicer/releases/download/v0.0.1/vtk_mrml-9.4.0-cp310-cp310-manylinux_2_35_x86_64.whl
pip install vtk_mrml-9.4.0-cp310-cp310-manylinux_2_35_x86_64.whl --find-links ./
