#!/bin/bash
# 执行脚本,将文件移入到LKP-tests中

cp -f  compatibility-testing compatibility-testing.conf env_inspectation.sh env_OSVersion.sh env_preparation.sh  $LKP_PATH/tests/
cp -f compatibility-testing.yaml  $LKP_PATH/jobs/
echo "compatibility-testing::" >>  $LKP_PATH/distro/adaptation-pkg/openeuler

chmod 777 $LKP_PATH/tests/compatibility-testing

