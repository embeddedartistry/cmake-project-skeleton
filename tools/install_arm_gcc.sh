#!/bin/bash
#
# You can override the installation path for toolchains by defining TOOLCHAIN_INSTALL_DIR
# If the toolchain directory do not require sudo permissions, disable the use
# of sudo by defining TOOLCHAIN_DISABLE_SUDO=1

TOOLCHAIN_INSTALL_DIR=${TOOLCHAIN_INSTALL_DIR:-/usr/local/toolchains}
TOOLCHAIN_DISABLE_SUDO=${TOOLCHAIN_DISABLE_SUDO:-0}

TOOLCHAIN_SUDO=sudo
if [ $TOOLCHAIN_DISABLE_SUDO == 1 ]; then

	TOOLCHAIN_SUDO=
fi

OSX_ARM_URL="https://developer.arm.com/-/media/Files/downloads/gnu-rm/9-2019q4/gcc-arm-none-eabi-9-2019-q4-major-mac.tar.bz2"
LINUX_ARM_URL="https://developer.arm.com/-/media/Files/downloads/gnu-rm/9-2019q4/gcc-arm-none-eabi-9-2019-q4-major-aarch64-linux.tar.bz2"

if [ "$(uname)" == "Darwin" ]; then
	ARM_URL=$OSX_ARM_URL
	ARM_DIR=$(basename "$ARM_URL" -mac.tar.bz2)
else
	ARM_URL=$LINUX_ARM_URL
	ARM_DIR=$(basename "$ARM_URL" -aarch64-linux.tar.bz2)
fi

ARM_ARCHIVE=$(basename "$ARM_URL")

###################################
# Download and install dependency #
###################################

cd /tmp
wget $ARM_URL
${TOOLCHAIN_SUDO} mkdir -p ${TOOLCHAIN_INSTALL_DIR}
# Move current toolchain if it exists
if [ -d "${TOOLCHAIN_INSTALL_DIR}/gcc-arm-none-eabi" ]; then
	${TOOLCHAIN_SUDO} rm -rf ${TOOLCHAIN_INSTALL_DIR}/gcc-arm-none-eabi-bak
	${TOOLCHAIN_SUDO} mv ${TOOLCHAIN_INSTALL_DIR}/gcc-arm-none-eabi ${TOOLCHAIN_INSTALL_DIR}/gcc-arm-none-eabi-bak
fi
${TOOLCHAIN_SUDO} tar xf ${ARM_ARCHIVE} --directory ${TOOLCHAIN_INSTALL_DIR}
${TOOLCHAIN_SUDO} mv ${TOOLCHAIN_INSTALL_DIR}/${ARM_DIR} ${TOOLCHAIN_INSTALL_DIR}/gcc-arm-none-eabi
rm ${ARM_ARCHIVE}
