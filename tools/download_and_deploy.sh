#!/bin/bash
# This script forwards all arguments to the deploy_skeleton.sh script
# The directory supplied to the script *must* be an absolute path!

cd /tmp
git clone git@github.com:embeddedartistry/cmake-project-skeleton.git --recursive --depth 1
cd project-skeleton
bash tools/deploy_skeleton.sh $@
cd ../
rm -rf project-skeleton
