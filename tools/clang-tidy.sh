#!/bin/bash

# Argument 1 is the path to the directory containing the compile_commands.json file
BUILD_OUTPUT_FOLDER=${1:-buildresults}

find arch src test include -iname *.c -o -iname *.cpp \
	| xargs clang-tidy -p $BUILD_OUTPUT_FOLDER
