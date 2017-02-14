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

