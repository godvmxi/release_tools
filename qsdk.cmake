#!/bin/bash
source tools/qsdk.env
help(){
    echo -e "usage :  must run in qsdk root dir"
    echo -e "\t app target_rootfs config source_dir [install_dir] [other define]"
    echo -e "\t app target_rootfs make"
    echo -e "\t app target_rootfs install"
    echo -e "\t app target_rootfs clean"
}

cmake_config(){
    echo -e "-->config cmake"
    if [[ ! -f $1 ]];then
        echo -e "config file is not exist"
        exit 1
    fi
    cp $1 ${WORKSPACE}/cmake/.config
}
cmake_menuconfig(){
    echo -e "-->menuconfig cmake"
    make  ARCH=arm  CROSS_COMPILE="${CROSS_COMPILE}"   -C ${WORKSPACE}/cmake  menuconfig
}
cmake_make(){
    echo -e "-->make cmake"
    PATH=${HOST_BIN_DIR}:$PATH make -j6 ARCH=arm  CROSS_COMPILE="${CROSS_COMPILE}"  -C ${WORKSPACE}/cmake
}
cmake_install(){
    echo -e "-->install cmake"
    cp -fv ${WORKSPACE}/cmake/arch/arm/boot/*mage   ${OUTPUT_DIR}/images/
    find ${WORKSPACE}/cmake/ -name "*.ko"  |xargs -i cp -fv {} ${OUTPUT_DIR}/system/lib/modules/
}
cmake_clean(){
    echo -e "-->clean cmake"
    make ARCH=arm  CROSS_COMPILE="${CROSS_COMPILE}"  -C ${WORKSPACE}/cmake clean
}
cmake_distclean(){
    echo -e "-->clean cmake"
    make ARCH=arm  CROSS_COMPILE="${CROSS_COMPILE}"  CONFIG_PREFIX="${target_rootfs}"   -C ${WORKSPACE}/cmake  distclean
    make ARCH=arm  CROSS_COMPILE="${CROSS_COMPILE}"  CONFIG_PREFIX="${target_rootfs}"   -C ${WORKSPACE}/cmake  mrproper
}
if [[ ! -d tools ]];then
    help
    exit 1
fi
target_rootfs=`pwd`/$1
old_pwd=`pwd`
case $2 in
    config )
        echo -e "\nentry source dir"
        cd $1
        echo -e "\tclean old build"
        rm -rf build
        echo -e "\tcreate temp build dir"
        mkdir -p build
        cd build
        echo -e "\tcongigure and create makefile"
        cmake $3  $4 $5 $6 $7 ..
        ls
        pwd
        cd $old_pwd
        ;;
    make )
        cd $1/build
        echo -e "\nmake target"
        make
        cd $old_pwd
        ;;
    install )
        echo -e "\ninstall target"
        cd $1/build
        make install
        cd $old_pwd
        ;;
    clean )
        echo -e "\nclean temp build"
        cd $1/build
        rm -rf build
        cd $old_pwd
        ;;
    distclean )
        cmake_distclean
        ;;
    * )
        help
        ;;
esac
