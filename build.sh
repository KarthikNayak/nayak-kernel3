#!/bin/bash

# Written by antdking <anthonydking@gmail.com>
# credits to Rashed for the base of zip making
# credits to the internet for filling in else where

echo "this is an open source script, feel free to use and share it"

daytime=$(date +%d"-"%m"-"%Y"_"%H"-"%M)

location=.
vendor=lge

if [ -z $target ]; then
read -p "What is the Version No? " version
echo "choose your target device"
echo "1) p350"
echo "2) p500"
echo "3) p505"
echo "4) p506"
echo "5) p509"
read -p "1/2/3/4/5: " choice
case "$choice" in
1 ) export target=p350 ; export defconfig=cyanogenmod_p350_defconfig;;
2 ) export target=p500 ; export defconfig=cyanogenmod_p500_defconfig;;
3 ) export target=p505 ; export defconfig=cyanogenmod_p505_p506_defconfig;;
4 ) export target=p506 ; export defconfig=cyanogenmod_p505_p506_defconfig;;
5 ) export target=p509 ; export defconfig=cyanogenmod_p509_defconfig;;
* ) echo "invalid choice"; sleep 2 ; ./build.sh;;
esac
fi # [ -z $target ]

cd $location
export ARCH=arm
echo "Choose ToolChain"
echo "1) arm-eabi-4.4.3"
echo "2) arm-eabi-linaro-4.6.2"
echo "3) arm-linux-androideabi-4.7"
read -p "1/2/3:" Toolc
case "$Toolc" in
1 ) export CROSS_COMPILE=~/android/toolchains/arm-eabi-4.4.3/bin/arm-eabi-;;
2 ) export CROSS_COMPILE=~/android/toolchains/arm-eabi-linaro-4.6.2/bin/arm-eabi-;;
3 ) export CROSS_COMPILE=~/android/toolchains/arm-linux-androideabi-4.7/bin/arm-linux-androideabi-;;
* ) echo "wrong choice using arm-linux by default"; export CROSS_COMPILE=~/android/toolchain/arm-linux-androideabi-4.7/bin/arm-linux-androideabi-;;
esac
if [ -z "$clean" ]; then
read -p "do make clean mrproper?(y/n)" clean
fi # [ -z "$clean" ]
case "$clean" in
y|Y ) echo "cleaning..."; make clean mrproper;;
n|N ) echo "continuing...";;
* ) echo "invalid option"; sleep 2 ; ./build.sh;;
esac

echo "now building the kernel"

make $defconfig
make menuconfig
make -j `cat /proc/cpuinfo | grep "^processor" | wc -l` "$@"

## the zip creation
if [ -f arch/arm/boot/zImage ]; then

rm -f zip-creator/kernel/zImage
rm -rf zip-creator/system/

# changed antdking "clean up mkdir commands" 04/02/13
mkdir -p zip-creator/system/lib/modules

cp arch/arm/boot/zImage zip-creator/kernel
# changed antdking "now copy all created modules" 04/02/13
# modules
# (if you get issues with copying wireless drivers then it's your own fault for not cleaning)

find . -name *.ko | xargs cp -a --target-directory=zip-creator/system/lib/modules/

zipfile="Nayak-Kernel-$target-v$version.zip"
cd zip-creator
rm -f *.zip
zip -r $zipfile * -x *kernel/.gitignore*

echo "zip saved to zip-creator/$zipfile"
mv $zipfile ~/android/Kernel/
echo "Moved the file to Kernel"
else # [ -f arch/arm/boot/zImage ]
echo "the build failed so a zip won't be created"
fi # [ -f arch/arm/boot/zImage ]
