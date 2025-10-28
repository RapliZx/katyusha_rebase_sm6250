#!/bin/sh
# Compile script for Compiling kernel
# Copyright (c) RapliVx Aka Rafi Aditya

# Setup
PHONE="Miatoll"
DEFCONFIG=vendor/xiaomi/miatoll_defconfig
COMPILERDIR="$(pwd)/../aosp-clang"
CLANG="AOSP Clang"
CODENAME="[OneVoice]"
ZIPNAME="Kurumi-Karnal-$CODENAME-$PHONE-$(date '+%Y%m%d-%H%M').zip"
CAPTION="Kurumi Kernel $PHONE Compile Complete, Have A Brick Day Nihahahah"
BOT_TOKEN="-"
CHAT_ID="-"
MESSAGE="• Build For $PHONE Started •"
MESSAGE_ERROR="• Error Build For $PHONE Aborted •"
kernel="out/arch/arm64/boot/Image.gz"
dtb="out/arch/arm64/boot/dtb.img"
dtbo="out/arch/arm64/boot/dtbo.img"
export KBUILD_BUILD_USER=Rapli
export KBUILD_BUILD_HOST=NyarchLinux

# Header
cyan="\033[96m"
green="\033[92m"
red="\033[91m"
blue="\033[94m"
yellow="\033[93m"

echo -e "$cyan===========================\033[0m"
echo -e "$cyan= START COMPILING KERNEL  =\033[0m"
echo -e "$cyan===========================\033[0m"

echo -e "$blue...KSABAR...\033[0m"

echo -e -ne "$green== (10%)\r"
sleep 0.7
echo -e -ne "$green=====                     (33%)\r"
sleep 0.7
echo -e -ne "$green=============             (66%)\r"
sleep 0.7
echo -e -ne "$green=======================   (100%)\r"
echo -ne "\n"

echo -e -n "$yellow\033[104mPRESS ENTER TO CONTINUE\033[0m"
read P
echo  $P

# Clone WeebX Clang
function clang() {
if [ -d $COMPILERDIR ] ; then
echo -e " "
echo -e "\n$green[!] Lets's Build UwU...\033[0m \n"
else
echo -e " "
echo -e "\n$red[!] AOSP-clang Dir Not Found!!!\033[0m \n"
sleep 2
echo -e "$green[+] Wait.. Cloning AOSP-clang...\033[0m \n"
sleep 2
wget https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/heads/main/clang-r547379.tar.gz -O "aosp-clang.tar.gz"
    rm -rf $COMPILERDIR 
    mkdir $COMPILERDIR 
    tar -xvf aosp-clang.tar.gz -C $COMPILERDIR
    rm -rf aosp-clang.tar.gz
sleep 1
echo
echo -e "\n$green[!] Lets's Build UwU...\033[0m \n"
sleep 1
fi
}

# URL API Telegram untuk mengirim pesan
URL="https://api.telegram.org/bot$BOT_TOKEN/sendMessage"

# Data yang akan dikirimkan
DATA="chat_id=$CHAT_ID&text=$MESSAGE"

# Kirim permintaan POST ke API Telegram
curl -s -X POST "$URL" -d "$DATA"

function clean() {
    echo -e "\n"
    echo -e "$red[!] CLEANING UP \\033[0m"
    echo -e "\n"
    rm -rf log.txt
    rm -rf out
    make mrproper
}

# Make Defconfig

function build_kernel() {
    export PATH="$COMPILERDIR/bin:$PATH"
    make -j$(nproc --all) O=out ARCH=arm64 ${DEFCONFIG}
    if [ $? -ne 0 ]
then
    echo -e "\n"
    echo -e "$red [!] BUILD FAILED \033[0m"
    echo -e "\n"
else
    echo -e "\n"
    echo -e "$green==================================\033[0m"
    echo -e "$green= [!] START BUILD ${DEFCONFIG}\033[0m"
    echo -e "$green==================================\033[0m"
    echo -e "\n"
fi

# Speed up build process
MAKE="./makeparallel"

# Build Start Here

   make -j$(nproc --all) \
    O=out \
    ARCH=arm64 \
    LLVM=1 \
    LLVM_IAS=1 \
    AR=llvm-ar \
    NM=llvm-nm \
    LD=ld.lld \
    OBJCOPY=llvm-objcopy \
    OBJDUMP=llvm-objdump \
    STRIP=llvm-strip \
    CC=clang \
    CROSS_COMPILE=aarch64-linux-gnu- \
    CROSS_COMPILE_ARM32=arm-linux-gnueabi- 2>&1 | tee log.txt
    
    # Zipping

    if [ -f out/arch/arm64/boot/Image ] ; then
            echo -e "$green=============================================\033[0m"
            echo -e "$green= [+] Zipping up ...\033[0m"
            echo -e "$green=============================================\033[0m"
    if [ -d "$AK3_DIR" ]; then
            cp -r $AK3_DIR AnyKernel3
        elif ! git clone -q https://github.com/RapliVx/AnyKernel3.git -b miatoll; then
                echo -e "\nAnyKernel3 repo not found locally and couldn't clone from GitHub! Aborting..."
        fi
            cp $kernel $dtb $dtbo AnyKernel3
            cd AnyKernel3
            git checkout miatoll &> /dev/null
            zip -r9 "../$ZIPNAME" * -x .git README.md *placeholder
            cd ..
            rm -rf AnyKernel3
    fi


    if [ -e "$ZIPNAME" ] ; then
    echo -e "$green===========================\033[0m"
    echo -e "$green=  SUCCESS COMPILE KERNEL \033[0m"
    echo -e "$green=  Device     : $PHONE \033[0m"
    echo -e "$green=  Defconfig  : $DEFCONFIG \033[0m"
    echo -e "$green=  Toolchain  : $CLANG \033[0m"
    echo -e "$green=  Codename   : $CODENAME \033[0m"
    echo -e "$green=  Zipname    : $ZIPNAME \033[0m"
    echo -e "$green=  Completed in $((SECONDS / 60)) minute(s) and $((SECONDS % 60)) second(s) \033[0m "
    echo -e "$green=  Have A Brick Day Nihahahah \033[0m"
    echo -e "$green===========================\033[0m"
    else
    echo -e "$red [!] FIX YOUR KERNEL SOURCE BRUH !?\033[0m"
    send_log
    fi

    if [ -e "$ZIPNAME" ] ; then 
    echo -e "$green=============================================\033[0m"
    echo -e "$green= [+] Uploading ...\033[0m"
    echo -e "$green=============================================\033[0m"

    URL="https://api.telegram.org/bot$BOT_TOKEN/sendDocument"

    curl -s -X POST "$URL" -F document=@"$ZIPNAME" -F caption="$CAPTION" -F chat_id="$CHAT_ID"

    fi

}

# Fungsi untuk mengirim pesan dengan file
function send_log() {
    # File yang ingin dikirim
    FILE="log.txt"

    # URL untuk mengirim file dengan caption
    URL="https://api.telegram.org/bot$BOT_TOKEN/sendDocument"

    # Perintah curl untuk mengirim file
    curl -F "chat_id=$CHAT_ID" -F "document=@${FILE}" -F "caption=${MESSAGE_ERROR}" $URL

}

# execute
clang
clean
build_kernel
