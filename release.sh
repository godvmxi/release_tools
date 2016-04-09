#!/bin/bash

R_PATH=qsdk_`date +"%y%m%d"`
ABS_PATH=`pwd`/${R_PATH}
DIRS="buildroot system bootloader kernel products tools"
FILES=Makefile

echo -e "\npreparing"
rm -rf ${ABS_PATH}*
mkdir ${ABS_PATH}

echo
for i in ${DIRS}; do
	echo "exporting $i"
	mkdir -p ${ABS_PATH}/$i
	cd $i
	git archive qsdk | tar x -C ${ABS_PATH}/$i
	git log -1 > ${ABS_PATH}/$i/GIT_VERSION
	cd - > /dev/null 2>&1
done

echo -e "\ninstalling extra files"
cp ${FILES} ${ABS_PATH} -pdrvf

echo -e "\ncreating package"
DOTS=$((`du ${R_PATH} -s | cut -f1`/100))
echo -en "           ]\r["
tar czf ${ABS_PATH}.tgz ${R_PATH} --checkpoint=${DOTS} --checkpoint-action=dot
rm -rf ${R_PATH}

echo -e "] done\n"

