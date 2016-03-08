#!/bin/bash

test -d tools || (echo "Wrong path `pwd`"; exit 0)

image_add="\
	output/product/items.itm \
	"

initrd_add= \

install_add() {
if [ -n $1 ]; then
	for i in $1; do
		echo "install $i to $2"
		cp -rf $i $2
	done
fi
}

install_add "${image_add}" output/images
install_add "${initrd_add}" output/initrd

