#!/bin/bash

curd=`pwd`

if [ -z $1 ]; then
	echo "please choose a product from list below:"
	ls products/
	printf "\nyour choice: "
	read prod
else
	prod=$1
fi

if test -d products/$prod; then
	mkdir -p output/images
	rm -f output/product
	ln -s $curd/products/$prod output/product
	echo "product successfully set to $prod"
else
	echo $prod is not a valid product
fi

