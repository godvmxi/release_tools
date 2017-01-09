#!/bin/bash

curd=`pwd`

if [ -z $1 ]; then
	echo -e "\nplease choose a product from list below:\n"
	for i in `ls products/`; do
		if [ -d "products/$i" ]; then
			echo "  $i"
		fi
	done
	printf "\nyour choice: "
	read prod
else
	prod=$1
fi

if test -d products/$prod; then
	mkdir -p output/images
	rm -f output/product
	ln -s $curd/products/$prod output/product
	make qsdk_defconfig
	echo -e "\nproduct successfully set to $prod\n"
else
	echo $prod is not a valid product
fi

#####create authorized_id.h file to build Felix.ko.
echo -e "\ncreate authorized_id head file:"
if [ -f output/product/AUTHORIZED_IDS ]; then
        echo -en "const char * authorized_ids[] = {" >> authorized_id_tmp.h
        for chip in `cat output/product/AUTHORIZED_IDS`; do
                if [ $chip ]; then
                        echo "argume:$chip"
                        echo -en "\"${chip}\"," >> authorized_id_tmp.h
                fi
        done
        echo -en "};\n" >> authorized_id_tmp.h
        cat authorized_id_tmp.h | sed 's/,};/};/' > system/hlibispv2505/DDKSource/CI/felix/felix_lib/kernel/include/ci_internal/authorized_id.h
        rm authorized_id_tmp.h
        echo "done"
else
        echo -en "const char * authorized_ids[] = {\"q3420p\",\"q3420f\",\"c20\",\"c23\"};\n" > system/hlibispv2505/DDKSource/CI/felix/felix_lib/kernel/include/ci_internal/authorized_id.h
fi
