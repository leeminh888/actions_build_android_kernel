#!/bin/bash
KERNEL_DEFCONFIG=picasso_user_defconfig
set -euo pipefail

echo "deb http://archive.ubuntu.com/ubuntu eoan main" | sudo tee /etc/apt/sources.list
sudo apt-get update
sudo apt-get -y --no-install-recommends install bison flex libc6 libstdc++6 ccache libfl-dev

export USE_CCACHE=1
export CCACHE_EXEC=/usr/bin/ccache
##export CCACHE_COMPRESS=1

ccache -M 4G
##ccache --show-stats
mkdir -p $GITHUB_WORKSPACE/TC
cd $GITHUB_WORKSPACE/TC
git clone --depth=1 https://github.com/MiCode/Xiaomi_Kernel_OpenSource.git -b picasso-q-oss 
wget 'https://github.com/kdrag0n/proton-clang-build/releases/download/20200117/proton_clang-11.0.0-20200117.tar.zst'
tar -I zstd -xf proton_clang-11.0.0-20200117.tar.zst
echo "unarchived!"

cd $GITHUB_WORKSPACE/TC/android_kernel_xiaomi_sm7250
make $KERNEL_DEFCONFIG O=out
make -j$(nproc --all) O=out \
                      ARCH=arm64 \
                      CLANG_TRIPLE=aarch64-linux-gnu- \
                      DTC_EXT=dtc \
                      CROSS_COMPILE=$GITHUB_WORKSPACE/TC/bin/aarch64-linux-gnu- \
                      CC=clang \
