#!/bin/bash

USE_GIT=1
USE_SUBMODULES=1
CORE_FILES="docs src test tools .clang-format .clang-tidy BuildOptions.cmake CMakeLists.txt Makefile Packaging.cmake README.md"
GIT_FILES=".gitattributes .github .gitignore"
SUBMODULE_DIRS="cmake"

# Parse optional arguments
while getopts gsh opt; do
  case $opt in
	g) USE_GIT=0
	   USE_SUBMODULES=0
	;;
	s) USE_SUBMODULES=0
	;;
	h) # Help
		echo "Usage: deploy_skeleton.sh [optio nal ags] dest_dir"
		echo "Optional args:"
		echo "	-g: Assume non-git environment and install submodule files directly."
		echo "	-s: Don't use SUBMODULE_DIRS, and copy files directly"
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

# Copy git files to the destination
cp -r $GIT_FILES $DEST_DIR

if [ $USE_SUBMODULES == 0 ]; then
	git submodule update --init
	cp -r $SUBMODULE_DIRS $DEST_DIR
fi

# Delete the deploy skeleton script from the destination
rm $DEST_DIR/tools/deploy_skeleton.sh
