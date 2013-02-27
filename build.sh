#!/bin/bash

# Written by antdking <anthonydking@gmail.com>
# credits to Rashed for the base of zip making
# credits to the internet for filling in else where

echo "this is an open source script, feel free to use and share it"

daytime=$(date +%d"-"%m"-"%Y"_"%H"-"%M)

location=.
vendor=lge

if [ -z $target ]; then
echo "choose your target device"
echo "1) p350"
echo "2) p500"
echo "3) p505"
echo "4) p506"
echo "5) p509"
read -p "1/2/3/4/5: " choice
case "$choice" in
1 ) export target=p350 ; export defconfig=cyanogenmod_p350_defconfig;;
2 ) export target=p500 ; export defconfig=nk1_defconfig;;
3 ) export target=p505 ; export defconfig=nk2_defconfig;;
4 ) export target=p506 ; export defconfig=nk2_defconfig;;
5 ) export target=p509 ; export defconfig=nk1_defconfig;;
* ) echo "invalid choice"; sleep 2 ; ./build.sh;;
esac
fi # [ -z $target ]

cd $location
export ARCH=arm
export CROSS_COMPILE=/development/android/toolchains/arm-eabi-linaro-4.6.2/bin/arm-eabi-
if [ -z "$clean" ]; then
read -p "do make clean mrproper?(y/n)" clean
fi # [ -z "$clean" ]
case "$clean" in
y|Y ) echo "cleaning..."; make clean mrproper;;
n|N ) echo "continuing...";;
* ) echo "invalid option"; sleep 2 ; build.sh;;
esac

echo "now building the kernel"

make $defconfig
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

zipfile="lge-3.0.x-$target-$daytime.zip"
cd zip-creator
rm -f *.zip
zip -r $zipfile * -x *kernel/.gitignore*

echo "zip saved to zip-creator/$zipfile"

else # [ -f arch/arm/boot/zImage ]
echo "the build failed so a zip won't be created"
fi # [ -f arch/arm/boot/zImage ]

