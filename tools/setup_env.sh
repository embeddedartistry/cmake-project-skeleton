#!/bin/bash

TOOLCHAIN_INSTALL_DIR=${TOOLCHAIN_INSTALL_DIR:-/usr/local/toolchains}
TOOL_INSTALL_DIR=${TOOL_INSTALL_DIR:-/usr/local/tools}

# For OS X, we need .bash_profile to invoke `.bashrc`.
# Append to file in case it already exists
if [ "$(uname)" == "Darwin" ]; then
cat << ENDOFBLOCK >> $HOME/.bash_profile
if [ -f \$HOME/.bashrc ]; then
	source \$HOME/.bashrc
fi
ENDOFBLOCK
fi

PATHMOD="$TOOLCHAIN_INSTALL_DIR/gcc-arm-none-eabi/bin:$TOOL_INSTALL_DIR/pottery/src"
if [ "$(uname)" == "Darwin" ]; then
	PATHMOD="$PATHMOD:/usr/local/opt/llvm/bin"
else
	PATHMOD="$PATHMOD:$TOOL_INSTALL_DIR:adr-tools/src"
fi


cat << ENDOFBLOCK >> $HOME/.bashrc
################
# Path Updates #
################

export PATH="$PATHMOD:\$PATH"
# set PATH so it includes user's private bin if it exists
if [ -d "\$HOME/bin" ] ; then
    PATH="\$HOME/bin:\$PATH"
fi
ENDOFBLOCK

cat << ENDOFBLOCK >> $HOME/.bashrc
#########################
# Aliases and Functions #
#########################
function deploy_skeleton()
{
	INITIAL_DIR=\$(pwd)
	cd /tmp
	wget https://gist.githubusercontent.com/phillipjohnston/bb95f19d156007f99be4c10c1efdf694/raw/f2f141e31fca0a12eb391e8251efe2ce1f9e68bd/download_and_deploy.sh
	bash download_and_deploy.sh \$@
	rm download_and_deploy.sh
	cd \$INITIAL_DIR
}
alias init_skeleton='deploy_skeleton -a -p `pwd`'
function init_repo()
{
	URL=\$1
	shift
	git clone \$URL
	cd \$(basename "\$URL" .git)
	deploy_skeleton -a -p \${@} `pwd`
}

# Skeleton Update Aliases
alias sm_update_build="cd build; git checkout master; git pull; cd ../"
alias sm_update_commit_build="cd build; git checkout master; git pull; cd ../; git add build; git commit -m 'Update build submodule to master'"
ENDOFBLOCK
