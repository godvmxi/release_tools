#!/bin/bash

# your IMAGE path
image_path=output/images
sd_dir=${1}
sd_name=${sd_dir##*/}
check_dir=/sys/block/${sd_name}/removable

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

if [ ! -f "$check_dir" ];then
	echo -e "Error: dir $check_dir not exit"
	exit 1
fi

value=$(cat ${check_dir})

if [ z"$value" != z"1" ];then
	echo -e "Error: not burn card insert, please insert burn card and try again"
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

