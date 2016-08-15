#!/bin/bash

# your IMAGE path
image_path=output/images

set -x
# check args
if [ z"$#" != z"1" ]
then
    echo -e "Usage :\n\t$0 [absolute BLOCKDEV] "
	echo
    echo -e "example $0 /dev/sdb"
    exit 1
fi

if [ ! -b "$1" ]; then
	echo "Error: node $1 is not a block device"
	exit 1
fi

umount ${1}1  > /dev/null  2>&1

echo "install ius..."
sudo dd if=${image_path}/burn.ius of=$1 bs=1M seek=16
sudo sync
echo -e "done\n"

# partition disk
echo "part disk..."
sudo umount $1* > /dev/null 2>&1
sudo fdisk $1 << EOF > /dev/null 2>&1
d
1
d
2
d
3
d
4
n
p
1
262144

w
EOF
echo -e "done\n"

# format disk
echo "format disk..."
sudo mkdosfs -F 32 ${1}1
sudo sync
echo -e "done\n"

