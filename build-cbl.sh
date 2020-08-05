#!/bin/bash
set -euo pipefail

echo "deb http://archive.ubuntu.com/ubuntu eoan main" | sudo tee /etc/apt/sources.list
sudo apt-get update
sudo apt-get -y --no-install-recommends install bison flex libc6 libstdc++6 ccache libfl-dev

mkdir -p $GITHUB_WORKSPACE/TC
cd $GITHUB_WORKSPACE/TC
wget 'https://github.com/kdrag0n/proton-clang-build/releases/download/20200117/proton_clang-11.0.0-20200117.tar.zst'
tar -I zstd -xf proton_clang-11.0.0-20200117.tar.zst
mv proton_clang-11.0.0-20200117/* ./
git clone --depth=1 https://github.com/MiCode/Xiaomi_Kernel_OpenSource.git -b picasso-p-oss
echo "unarchived!"


cd $GITHUB_WORKSPACE/kernel
args="-j$(nproc --all) \
    O=out \
    ARCH=arm64 \
    CLANG_TRIPLE=aarch64-linux-gnu- \
    DTC_EXT=dtc \
    CROSS_COMPILE=$GITHUB_WORKSPACE/TC/bin/aarch64-linux-gnu- \
    CC=$GITHUB_WORKSPACE/TC/bin/clang"

echo "Make defconfig"
make ${args} picasso_user_defconfig
echo "Make defconfig done, start Make"
make ${args}
