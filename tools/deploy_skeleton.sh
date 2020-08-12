#!/bin/bash

USE_GIT=1
USE_SUBMODULES=1
USE_ADR=0
USE_POTTERY=0
COPY_LICENSE=0
REPLACE_NAME=
CORE_FILES="docs src test tools .clang-format .clang-tidy BuildOptions.cmake CMakeLists.txt Makefile Packaging.cmake README.md"
GIT_FILES=".gitattributes .github .gitignore"
SUBMODULE_DIRS=("cmake")
SUBMODULE_URLS=("https://github.com/embeddedartistry/cmake-buildsystem.git")

# Detect sed -i command b/c OS X uses BSD sed
if [ "$(uname)" == "Darwin" ]; then
	SED="sed -i ''"
else
	SED="sed -i"
fi

# Parse optional arguments
while getopts aplghsr: opt; do
  case $opt in
  	a) USE_ADR=1
	;;
	p) USE_POTTERY=1
	;;
	l) COPY_LICENSE=1
	;;
	g) USE_GIT=0
	   USE_SUBMODULES=0
	;;
	s) USE_SUBMODULES=0
	;;
	r) REPLACE_NAME="$OPTARG"
	;;
	h) # Help
		echo "Usage: deploy_skeleton.sh [optional ags] dest_dir"
		echo "Optional args:"
		echo "	-a: initialize destination to use adr-tools"
		echo "	-p: initialize destination to use pottery"
		echo "	-l: copy the license file"
		echo "	-g: Assume non-git environment. Installs submodule files directly."
		echo "	-s: Don't use submodules, and copy files directly"
		echo "	-r <name>: Replace template project/app name values with specified name"
		exit 0
	;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

# Shift off the getopts args, leaving us with positional args
shift $((OPTIND -1))

# First positional argument is the destination folder that skeleton files will be installed to
DEST_DIR=$1
STARTING_DIR=$PWD

# Check to see if we're in tools/ or the project-skeleton root
CHECK_DIR=cmake
if [ ! -d "$CHECK_DIR" ]; then
	cd ..
	if [ ! -d "$CHECK_DIR" ]; then
		echo "This script must be run from the project skeleton root or the tools/ directory."
		exit 1
	fi
fi

# Adjust the destination directory for relative paths in case we changed directories
# This method still supports absolute directory paths for the destination
if [ ! -d "$DEST_DIR" ]; then
	if [ -d "$STARTING_DIR/$DEST_DIR" ]; then
		DEST_DIR=$STARTING_DIR/$DEST_DIR
	else
		echo "Destination directory cannot be found. Does it exist?"
		exit 1
	fi
fi

# Copy core skeleton files to the destination
cp -r $CORE_FILES $DEST_DIR

# Delete the deploy skeleton script from the destination
rm $DEST_DIR/tools/deploy_skeleton.sh $DEST_DIR/tools/download_and_deploy.sh

# Copy git files to the destination
if [ $USE_GIT == 1 ]; then
	cp -r $GIT_FILES $DEST_DIR
fi

# Manually copy submodule files
if [ $USE_SUBMODULES == 0 ]; then
	git submodule update --init --recursive
	cp -r ${SUBMODULE_DIRS[@]} $DEST_DIR
fi

if [ $COPY_LICENSE == 1 ]; then
	cp LICENSE $DEST_DIR
fi

## The following operations all take place in the destination directory
cd $DEST_DIR

# Initialize Submodules
if [ $USE_SUBMODULES == 1 ]; then
	cd $DEST_DIR
	for index in ${!SUBMODULE_URLS[@]}; do
		git submodule add ${SUBMODULE_URLS[$index]} ${SUBMODULE_DIRS[$index]}
	done
	git commit -m "Add submodules from project skeleton."
else
	find ${SUBMODULE_DIRS[@]} -name ".git*" -exec rm -rf {} \;
fi

# Commit Files
if [ $USE_GIT == 1 ]; then
	git add --all
	git commit -m "Initial commit of project skeleton files."
fi

# Replace placeholder names
if [[ ! -z $REPLACE_NAME ]]; then
	# Convert spaces to underscores before replacing names
	REPLACE_NAME=${REPLACE_NAME// /_}
	eval $SED "s/MYPROJECT/$REPLACE_NAME/g" "CMakeLists.txt"
	eval $SED "s/MYPROJECT/$REPLACE_NAME/g" "test/CMakeLists.txt"
	# Convert to all upper case for variable name
	# We use awk beacuse it properly handles UTF-8/multibyte input
	REPLACE_NAME=$(echo "$REPLACE_NAME" | awk '{print toupper($0)}')
	eval $SED "s/PROJECTVARNAME/$REPLACE_NAME/g" "CMakeLists.txt"
	eval $SED "s/PROJECTVARNAME/$REPLACE_NAME/g" "test/CMakeLists.txt"
	eval $SED "s/PROJECTVARNAME/$REPLACE_NAME/g" "BuildOptions.cmake"
	if [ $USE_GIT == 1 ]; then
		git commit -am "Replace placeholder values in build files with $REPLACE_NAME."
	fi
fi

# Initialize adr-tools
if [ $USE_ADR == 1 ]; then
	adr init docs/
	if [ $USE_GIT == 1 ]; then
		git add --all
		git commit -m "Initialize adr-tools."
	fi
fi

# Initialize pottery
if [ $USE_POTTERY == 1 ]; then
	pottery init
	pottery note "Initial creation of project repository"
	if [ $USE_GIT == 1 ]; then
		git add --all
		git commit -m "Initialize pottery and document repository creation."
	fi
fi

# Push all changes to the server
if [ $USE_GIT == 1 ]; then
	git push || echo "WARNING: git push failed: check repository."
fi

if [[ $COPY_LICENSE == 0 && ! -f "LICENSE" || ! -f "LICENSE.md" ]]; then
	echo "NOTE: Your project does not have a LICENSE or LICENSE.md file in the project root."
fi

if [[ -z $REPLACE_NAME ]]; then
	echo "NOTE: Replace the placeholder project name values in CMakeLists.txt and test/CMakeLists.txt (MYPROJECT)"
	echo "NOTE: Replace the placeholder project variable values in CMakeLists.txt, test/CMakeLists.txt, and BuildOptions.cmake (PROJECTVARNAME)"
fi
