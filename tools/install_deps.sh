#!/bin/bash

STARTING_DIR=$PWD
UPDATE=0
PIP_UPDATE=
BREW_COMMAND="install"
APT_COMMAND="install"
UPDATE_ENV=0
TOOLCHAIN_INSTALL_DIR=${TOOLCHAIN_INSTALL_DIR:-/usr/local/toolchains}
TOOL_INSTALL_DIR=${TOOL_INSTALL_DIR:-/usr/local/tools}
TOOLCHAIN_DISABLE_SUDO=${TOOLCHAIN_DISABLE_SUDO:-0}
TOOL_DISABLE_SUDO=${TOOL_DISABLE_SUDO:-0}
TOOLS_SUDO=sudo

if [ $TOOL_DISABLE_SUDO == 1 ]; then
	TOOLS_SUDO=
fi

# Packages to Install
BREW_PACKAGES=("python3" "ninja" "wget" "gcc@7" "gcc@8" "gcc@9" "llvm" "adr-tools" "cmocka" "pkg-config")
BREW_PACKAGES+=("vale" "doxygen" "cppcheck" "clang-format" "gcovr" "lcov" "sloccount" "cmake")
APT_PACKAGES=("python3" "python3-pip" "ninja-build" "wget" "build-essential" "clang" "lld" "llvm")
APT_PACKAGES+=("clang-tools" "libcmocka0" "libcmocka-dev" "pkg-config" "sloccount" "curl")
APT_PACKAGES+=("doxygen" "cppcheck" "gcovr" "lcov" "clang-format" "clang-tidy" "clang-tools")
APT_PACKAGES+=("gcc-7" "g++-7" "gcc-8" "g++-8" "gcc-9" "g++-9")
PIP3_PACKAGES=("lizard")

while getopts "euh" opt; do
  case $opt in
  	e) UPDATE_ENV=1
	;;
	u)	UPDATE=1
		PIP_UPDATE="--upgrade"
		BREW_COMMAND="upgrade"
		APT_COMMAND="upgrade"
	;;
	h) # Help
		echo "Usage: install_deps.sh [optional ags]"
		echo "Optional args:"
		echo "	-u: Run an update instead of install"
		echo "  -e: Include environment setup during install process (.bashrc + .bash_profile)"
		exit 0
	;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

if [ "$(uname)" == "Darwin" ]; then
	# OS X case
	ARM_URL=$OSX_ARM_URL
	ARM_DIR=$(basename "$ARM_URL" -mac.tar.bz2)

	if [ $UPDATE == 1 ]; then
		# update homebrew
		brew update
	else
		#install brew if unavailable
		if [ -z "$(command -v brew)" ]; then
			/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
		fi

		brew tap homebrew/cask-versions
	fi

	brew ${BREW_COMMAND} ${BREW_PACKAGES[@]}
	pip3 install ${PIP3_PACKAGES[@]} ${PIP_UPDATE}
else
	# WSL/Linux Case
	ARM_URL=$LINUX_ARM_URL
	ARM_DIR=$(basename "$ARM_URL" -aarch64-linux.tar.bz2)

	sudo apt-get update
	sudo apt ${APT_COMMAND} -y ${APT_PACKAGES[@]}
	sudo -H pip3 install ${PIP3_PACKAGES[@]} ${PIP_UPDATE}

	cd /tmp
	wget https://install.goreleaser.com/github.com/ValeLint/vale.sh
	sudo sh vale.sh -b /usr/local/bin
	rm vale.sh

	# Install adr-tools
	if [ $UPDATE == 1 ]; then
		cd /usr/local/tools/adr-tools
		${TOOLS_SUDO} git pull
	else
		${TOOLS_SUDO} mkdir -p /usr/local/tools
		cd /usr/local/tools
		${TOOLS_SUDO} git clone https://github.com/npryce/adr-tools.git --recursive
	fi
fi

###########################
# Common Dependency Steps #
###########################

# Install gcc-arm-none-eabi
if [ $UPDATE == 0 ]; then
	# Assume that the two scripts are contained in the same directory
	cd $STARTING_DIR
	source $(dirname $0)/install_arm_gcc.sh
fi

if [ $UPDATE == 1 ]; then
	# Update Pottery
	cd ${TOOL_INSTALL_DIR}/pottery
	${TOOLS_SUDO} git pull
else
	${TOOLS_SUDO} mkdir -p ${TOOL_INSTALL_DIR}/tools
	cd /usr/local/tools
	${TOOLS_SUDO} git clone https://github.com/npryce/pottery.git --recursive
fi

#############################
# Configure the Environment #
#############################

if [ $UPDATE == 0 ]; then
	if [ $UPDATE_ENV == 1 ]; then
		# Assume that the two scripts are contained in the same directory
		cd $STARTING_DIR
		source $(dirname $0)/setup_env.sh
	else
		echo "You may need to manually modify your PATH to reference the programs in $TOOLCHAIN_INSTALL_DIR and $TOOL_INSTALL_DIR"
	fi
fi
