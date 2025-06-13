#!/bin/bash

# Settings
# Android Version
export ANDROID_VER="14"
# Kernel Version
export KERNEL_VER="6.1"
# Security Patch or lts
export SEC_PATCH="2025-05"
# KERNEL_SUFFIX="" meaning just delete dirty suffix
# or using custom suffix to replace it
export KERNEL_SUFFIX="ab13410921"
# Kernel build Time
export BUILD_TIME="2025-06-12 00:12:14 UTC"

echo
echo -e "\e[32mKernel Information\e[0m"
echo Android Version：$ANDROID_VER
echo Kernel Version：$KERNEL_VER
echo Security Patch：$SEC_PATCH
if [[ "$KERNEL_SUFFIX" == "" ]]; then
  echo Delete the dirty suffix
else
  echo Custom suffix：$KERNEL_SUFFIX
fi
echo Build Time：$BUILD_TIME
echo

echo -e "\e[33mCheck the settings before starting\e[0m"
echo -e "\e[33mPress Ctrl+C to exit during execution\e[0m"
echo

read -n 1 -s -p "Press any key to continue"
echo

# Select KPM feature
while true; do
  read -p "KPM Feature (y=Enable, n=Disable): " kpm
  if [[ "$kpm" == "y" || "$kpm" == "n" ]]; then
    export KERNEL_KPM="$kpm"
    break
  else
    echo -e "\e[31m[Error]\e[33m Please select：y or n\e[0m"
  fi
done

# Download Toolkit
echo -e "\e[32mInstall Toolkit\e[0m"
sudo apt update 
sudo apt upgrade -y
sudo apt-get install -y curl git python3

# Git for GKI
git config --global user.name "user"
git config --global user.email "user@gmail.com"

# Download Repo
echo -e "\e[32mInstall repo\e[0m"
curl https://storage.googleapis.com/git-repo-downloads/repo > $HOME/PixelGKI/repo
chmod a+x $HOME/PixelGKI/repo
sudo mv $HOME/PixelGKI/repo /usr/local/bin/repo

# Sync Generic Kernel Image Source Code
echo -e "\e[32mSync GKI source code\e[0m"
mkdir Buildkernel
cd Buildkernel
repo init -u https://android.googlesource.com/kernel/manifest -b common-android$ANDROID_VER-$KERNEL_VER-$SEC_PATCH --depth=1
repo sync

# Setup SukiSU-Ultra
echo -e "\e[32mSetup SukiSU-Ultra\e[0m"
curl -LSs "https://raw.githubusercontent.com/SukiSU-Ultra/SukiSU-Ultra/main/kernel/setup.sh" | bash -s susfs-main

# Setup susfs & manual hooks
echo -e "\e[32mSetup susfs & manual hooks\e[0m"
cd $HOME/PixelGKI/Buildkernel
git clone https://gitlab.com/simonpunk/susfs4ksu.git -b gki-android$ANDROID_VER-$KERNEL_VER
git clone https://github.com/SukiSU-Ultra/SukiSU_patch.git
cp susfs4ksu/kernel_patches/50_add_susfs_in_gki-android$ANDROID_VER-$KERNEL_VER.patch ./common/
cp susfs4ksu/kernel_patches/fs/* ./common/fs/
cp susfs4ksu/kernel_patches/include/linux/* ./common/include/linux/
cd common
patch -p1 < 50_add_susfs_in_gki-android$ANDROID_VER-$KERNEL_VER.patch || true
cp ../SukiSU_patch/hooks/syscall_hooks.patch ./
patch -p1 -F 3 < syscall_hooks.patch

# Add these configuration to kernel
cd $HOME/PixelGKI/Buildkernel
CONFIGS=(
  "CONFIG_KSU=y"
  "CONFIG_KSU_SUSFS_SUS_SU=n"
  "CONFIG_KSU_MANUAL_HOOK=y"
  "CONFIG_KSU_SUSFS=y"
  "CONFIG_KSU_SUSFS_HAS_MAGIC_MOUNT=y"
  "CONFIG_KSU_SUSFS_SUS_PATH=y"
  "CONFIG_KSU_SUSFS_SUS_MOUNT=y"
  "CONFIG_KSU_SUSFS_AUTO_ADD_SUS_KSU_DEFAULT_MOUNT=y"
  "CONFIG_KSU_SUSFS_AUTO_ADD_SUS_BIND_MOUNT=y"
  "CONFIG_KSU_SUSFS_SUS_KSTAT=y"
  "CONFIG_KSU_SUSFS_SUS_OVERLAYFS=n"
  "CONFIG_KSU_SUSFS_TRY_UMOUNT=y"
  "CONFIG_KSU_SUSFS_AUTO_ADD_TRY_UMOUNT_FOR_BIND_MOUNT=y"
  "CONFIG_KSU_SUSFS_SPOOF_UNAME=y"
  "CONFIG_KSU_SUSFS_ENABLE_LOG=y"
  "CONFIG_KSU_SUSFS_HIDE_KSU_SUSFS_SYMBOLS=y"
  "CONFIG_KSU_SUSFS_SPOOF_CMDLINE_OR_BOOTCONFIG=y"
  "CONFIG_KSU_SUSFS_OPEN_REDIRECT=y"
)
for CONFIG in "${CONFIGS[@]}"; do
  echo "$CONFIG" >> common/arch/arm64/configs/gki_defconfig
done
echo -e "\e[33m[Done]\e[0m" Added susfs configuration to kernel

# Add KPM configuration
if [ "$KERNEL_KPM" = "y" ]; then
  cd $HOME/PixelGKI/Buildkernel  
  echo "CONFIG_KPM=y" >> common/arch/arm64/configs/gki_defconfig
  echo -e "\e[33m[Done]\e[0m" Added KPM configuration to kernel
else
  echo -e "\e[33m[Done]\e[0m" Disable KPM feature
fi

# Setup kernel suffix
cd $HOME/PixelGKI/Buildkernel || exit
sudo sed -i 's/check_defconfig//' ./common/build.config.gki
if [[ "$KERNEL_SUFFIX" == "" ]]; then
  sed -i '$i res=$(echo "$res" | sed '\''s/-dirty//g'\'')' common/scripts/setlocalversion
  echo -e "\e[33m[Done]\e[0m" Delete the dirty suffix
else
  sed -i '$i res=$(echo "$res" | sed '\''s/-dirty//g'\'')' common/scripts/setlocalversion
  sed -i '$s|echo "\$res"|echo "\$res-ab13050921"|' ./common/scripts/setlocalversion
  sudo sed -i "s/ab13050921/$KERNEL_SUFFIX/g" ./common/scripts/setlocalversion
  echo -e "\e[33m[Done]\e[0m" Setup custom suffix
fi

# Setup kernel build time
export SOURCE_DATE_EPOCH=$(date -d "$BUILD_TIME" +%s)
echo -e "\e[33m[Done]\e[0m" Setup kernel build time

# Build kernel
cd $HOME/PixelGKI/Buildkernel || exit
echo -e "\e[32mBuilding kernel\e[0m"
sed -i '/^[[:space:]]*"protected_exports_list"[[:space:]]*:[[:space:]]*"android\/abi_gki_protected_exports_aarch64",$/d' ./common/BUILD.bazel
rm -rf ./common/android/abi_gki_protected_exports_*
tools/bazel run --config=fast --config=stamp --lto=thin //common:kernel_aarch64_dist -- --destdir=dist

# KPM patch
if [ "$KERNEL_KPM" = "y" ]; then
  echo -e "\e[32mKPM patch\e[0m"
  cd dist
  curl -LSs "https://raw.githubusercontent.com/ShirkNeko/SukiSU_patch/refs/heads/main/kpm/patch_linux" -o patch
  chmod 777 patch
  ./patch
  rm -rf Image
  mv oImage kernel
  echo -e "\e[33m[Done]\e[0m" KPM feature is enabled
else
  mv dist/Image dist/kernel
fi

echo -e "\e[32mINFO:\e[0m" Compilation successful
echo -e "\e[32mINFO:\e[0m" The kernel is in PixelGKI/Buildkernel/dist
echo -e "\e[32mINFO:\e[0m" Use magiskboot repack to boot.img
