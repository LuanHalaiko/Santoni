#!/bin/bash
#
# Redmi 4x kernel compilation script
# Copyright (C) 2018 Luan Halaiko and Ashishm94 (tecnotailsplays@gmail.com)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

#colors
black='\033[0;30m'
red='\033[0;31m'
green='\033[0;32m'
brown='\033[0;33m'
blue='\033[0;34m'
purple='\033[1;35m'
cyan='\033[0;36m'
nc='\033[0m'

#directories
KERNEL_DIR=$PWD
KERN_IMG=$KERNEL_DIR/arch/arm64/boot/Image.gz-dtb
LCD_KO=$KERNEL_DIR/drivers/video/backlight/lcd.ko
RDBG_KO=$KERNEL_DIR/drivers/char/rdbg.ko
EV_KO=$KERNEL_DIR/drivers/input/evbug.ko
SPI_KO=$KERNEL_DIR/drivers/spi/spidev.ko
WIL_KO=$KERNEL_DIR/drivers/net/wireless/ath/wil6210/wil6210.ko
MMCT_KO=$KERNEL_DIR/drivers/mmc/card/mmc_test.ko
UFST_KO=$KERNEL_DIR/drivers/scsi/ufs/ufs_test.ko
BACKL_KO=$KERNEL_DIR/drivers/video/backlight/backlight.ko
ANSICP_KO=$KERNEL_DIR/crypto/ansi_cprng.ko
GENERIC_KO=$KERNEL_DIR/drivers/video/backlight/generic_bl.ko
TESTIO_KO=$KERNEL_DIR/block/test-iosched.ko
BRNET_KO=$KERNEL_DIR/net/bridge/br_netfilter.ko
MMCB_KO=$KERNEL_DIR/drivers/mmc/card/mmc_block_test.ko
WLAN_KO=$KERNEL_DIR/drivers/staging/prima/wlan.ko
ZIP_DIR=$KERNEL_DIR/miui_repack
CONFIG_DIR=$KERNEL_DIR/arch/arm64/configs

#export
export CROSS_COMPILE="$HOME/kernel/linaro/bin/aarch64-linux-gnu-"
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER="LuanHalaiko"
export KBUILD_BUILD_HOST="CrossBuilder"
export KBUILD_LOUP_CFLAGS=

#misc
CONFIG=santoni_defconfig
THREAD="-j$(grep -c ^processor /proc/cpuinfo)"

#ASCII art
echo -e "$red############################# WELCOME TO #############################"
echo -e " _____                                  _    _                        _  "
echo -e "(____ \                                | |  / )                      | | "
echo -e " _   \ \ ____ ____  ____  ___  ____    | | / / ____  ____ ____   ____| | "
echo -e "| |   | / ___) _  |/ _  |/ _ \|  _ \   | |< < / _  )/ ___)  _ \ / _  ) | "
echo -e "| |__/ / |  ( ( | ( ( | | |_| | | | |  | | \ ( (/ /| |   | | | ( (/ /| | "
echo -e "|_____/|_|   \_||_|\_|| |\___/|_| |_|  |_|  \_)____)_|   |_| |_|\____)_| "
echo -e "                  (_____|                                                "
echo -e "\n############################### BUILDER ###############################$nc"

#main script
while true; do
echo -e "\n$green[1]Build MIUI"
echo -e "[2]Regenerate defconfig"
echo -e "[3]Source cleanup"
echo -e "[4]Create flashable zip"
echo -e "[5]Quit$nc"
echo -ne "\n$brown(i)Please enter a choice[1-5]:$nc "

read choice

if [ "$choice" == "1" ]; then
  BUILD_START=$(date +"%s")
  DATE=`date`
  echo -e "\n$cyan#######################################################################$nc"
  echo -e "$brown(i)Build started at $DATE$nc"
  make $CONFIG $THREAD &>/dev/null
  make $THREAD &>Buildlog.txt & pid=$!
  spin[0]="$blue-"
  spin[1]="\\"
  spin[2]="|"
  spin[3]="/$nc"

  echo -ne "$blue[Please wait...] ${spin[0]}$nc"
  while kill -0 $pid &>/dev/null
  do
    for i in "${spin[@]}"
    do
          echo -ne "\b$i"
          sleep 0.1
    done
  done
  if ! [ -a $KERN_IMG ]; then
    echo -e "\n$red(!)Kernel compilation failed, See buildlog to fix errors $nc"
    echo -e "$red#######################################################################$nc"
    exit 1
  fi
  $DTBTOOL -2 -o $KERNEL_DIR/arch/arm/boot/dt.img -s 2048 -p $KERNEL_DIR/scripts/dtc/ $KERNEL_DIR/arch/arm/boot/dts/ &>/dev/null &>/dev/null
if [ "$cpu" == "b" ]; then
patch -p1 -R < 0001-nuke-cpu-oc.patch &>/dev/null
fi
  BUILD_END=$(date +"%s")
  DIFF=$(($BUILD_END - $BUILD_START))
  echo -e "\n$brown(i)Image-dtb compiled successfully.$nc"
  echo -e "$cyan#######################################################################$nc"
  echo -e "$purple(i)Total time elapsed: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$nc"
  echo -e "$cyan#######################################################################$nc"
fi

if [ "$choice" == "2" ]; then
  echo -e "\n$cyan#######################################################################$nc"
  make $CONFIG
  cp .config arch/arm64/configs/$CONFIG
  echo -e "$purple(i)Defconfig generated.$nc"
  echo -e "$cyan#######################################################################$nc"
fi

if [ "$choice" == "3" ]; then
  echo -e "\n$cyan#######################################################################$nc"
  rm -f $DT_IMG
  make clean &>/dev/null
  make mrproper &>/dev/null
  echo -e "$purple(i)Kernel source cleaned up.$nc"
  echo -e "$cyan#######################################################################$nc"
fi


if [ "$choice" == "4" ]; then
  echo -e "\n$cyan#######################################################################$nc"
  cd $ZIP_DIR
  make clean &>/dev/null
  cp $KERN_IMG $MIUI_ZIP_DIR/boot/zImage
  cp $LCD_KO $MIUI_ZIP_DIR/system/lib/modules
  cp $RDBG_KO $MIUI_ZIP_DIR/system/lib/modules
  cp $EV_KO $MIUI_ZIP_DIR/system/lib/modules
  cp $SPI_KO $MIUI_ZIP_DIR/system/lib/modules
  cp $WIL_KO $MIUI_ZIP_DIR/system/lib/modules
  cp $MMCT_KO $MIUI_ZIP_DIR/system/lib/modules
  cp $UFST_KO $MIUI_ZIP_DIR/system/lib/modules
  cp $BACKL_KO $MIUI_ZIP_DIR/system/lib/modules
  cp $ANSICP_KO $MIUI_ZIP_DIR/system/lib/modules
  cp $GENERIC_KO $MIUI_ZIP_DIR/system/lib/modules
  cp $TESTIO_KO $MIUI_ZIP_DIR/system/lib/modules
  cp $BRNET_KO $MIUI_ZIP_DIR/system/lib/modules
  cp $MMCB_KO $MIUI_ZIP_DIR/system/lib/modules
  cp $WLAN_KO $MIUI_ZIP_DIR/system/lib/modules/pronto/pronto_wlan.ko
  make &>/dev/null
  make sign &>/dev/null
  cd ..
  echo -e "$purple(i)Miui flashable zip generated under $ZIP_DIR.$nc"
  echo -e "$cyan#######################################################################$nc"
fi


if [ "$choice" == "5" ]; then
 exit 1
fi
done
