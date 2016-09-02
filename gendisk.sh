#!/bin/bash

# your IMAGE path
cfg_path=output/product
image_path=output/images
out_path=output/gendisk
iuw=output/host/usr/bin/iuw

set +x
# check args
if [ z"$#" != z"1" ]
then
    echo -e "Usage :\n\t$0 [absolute BLOCKDEV] "
	echo
    echo -e "example $0 /dev/sdb"
    exit 1
fi

umount ${1}*  > /dev/null  2>&1

# gen environment
mkdir -p ${out_path}/system
if grep 3c000200 ${cfg_path}/burn.ixl; then
	echo "i run 0x3c000200 0x3c000000  ../images/uboot0.isi" > ${out_path}/debug.ixl
else
	echo "i run 0x08000200 0x08000000  ../images/uboot0.isi" > ${out_path}/debug.ixl
fi
echo "i 0x31
r flash 1   ../images/items.itm
r flash 3   ../images/uImage
#i flash 2  ../images/ramdisk0.img *
u 0x32" >> ${out_path}/debug.ixl

${iuw} mkius ${out_path}/debug.ixl -o ${out_path}/a.ius
if [ $? -gt 0 ]
then
	exit 1
fi

echo -e "\ninstall ius..."
sudo dd if=${out_path}/a.ius of=$1 bs=1M seek=16
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
4488888
n
p
2
4500000
4622222
w
EOF
echo -e "done\n"

# format disk
echo "format disk..."
sudo mkdosfs -F 32 ${1}1
sudo mke2fs -t ext4 -Fq ${1}2 > /dev/null
echo -e "done\n"

echo "install system..."
sudo mount ${1}2 ${out_path}/system
sudo tar xf ${image_path}/rootfs.tar -C ${out_path}

echo "install debugging tools..."
sudo cp -pdrf tools/debug-ol/* ${out_path}/system/
sudo mkdir -p ${out_path}/system/var/empty
sudo chown root:root ${out_path}/system/var/empty
sudo chmod 755 ${out_path}/system/var/empty

echo "finishing..."
# clear environment
sudo umount ${out_path}/system
sudo rm -rf ${out_path}/*
echo -e "done\n"

