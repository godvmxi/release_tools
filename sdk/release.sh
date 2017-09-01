#!/bin/bash
WORKSPACE=`pwd`
TOOLCHAIN_PREFIX=`basename output/host/usr/arm-*`
P_REL=qsdk_sdk_`date +"%y%m%d"`
P_REL_ABS=`pwd`/${P_REL}
rel_init_rel_dir(){
    echo -e "--> init release dir "${P_REL_ABS}
    rm -rf ${P_REL_ABS}
    mkdir -p  ${P_REL_ABS}/kernel
    mkdir -p  ${P_REL_ABS}/uboot
    mkdir -p  ${P_REL_ABS}/busybox
    mkdir -p  ${P_REL_ABS}/products
    mkdir -p  ${P_REL_ABS}/toolchain
    mkdir -p  ${P_REL_ABS}/packages
    mkdir -p  ${P_REL_ABS}/private
    mkdir -p  ${P_REL_ABS}/tools
    mkdir -p  ${P_REL_ABS}/tools/host/bin
    mkdir -p  ${P_REL_ABS}/tools/host/sbin
    mkdir -p  ${P_REL_ABS}/tools/host/lib
    mkdir -p  ${P_REL_ABS}/tools/host/share
    mkdir -p  ${P_REL_ABS}/qsdk
    mkdir -p  ${P_REL_ABS}/qsdk/ramdisk
    tree ${P_REL_ABS}

}
format(){
   echo -e "format output"
}
rel_host_toolchain(){
    echo -e "-->release host toolchain"
    cd ${WORKSPACE}
    TOPDIR=${WORKSPACE}
    toolchain_dir=`cat .config |grep "BR2_TOOLCHAIN_EXTERNAL_PATH" |awk -F '/' '{print $4}' | awk -F '"' '{print $1}'`
    echo -e "\tverison ->"${toolchain_dir}
    cp -rf buildroot/prebuilts/${toolchain_dir}/*  ${P_REL_ABS}/toolchain
    TOOLCHAIN_PREFIX=`basename output/host/usr/arm-*`

}
rel_host_extra(){
    echo -e "-->release host extra"
    cd ${WORKSPACE}
    cp -rf ${WORKSPACE}/buildroot/support/scripts/mkusers  ${P_REL_ABS}/toolchain/bin/
    cp -rf ${WORKSPACE}/buildroot/fs/ext2/genext2fs.sh  ${P_REL_ABS}/toolchain/bin/
    cp -rf ${WORKSPACE}/output/host/usr/bin/mkimage   ${P_REL_ABS}/toolchain/bin/
    return
    echo -e "\t -->check bin"
    for i in `ls output/host/usr/bin/`
    do 
       if [[ ! -e ${P_REL_ABS}/toolchain/bin/${i} ]];then
            echo -e "\t\twill be add -->  "${i}
            cp  output/host/usr/bin/${i}  ${P_REL_ABS}/tools/host/bin
       fi
    done
    echo -e "\t -->check sbin"
    for i in `ls output/host/usr/sbin/`
    do 
       if [[ ! -e ${P_REL_ABS}/toolchain/sbin/${i} ]];then
            echo -e "\t\twill be add -->  "${i}
            cp -rf  output/host/usr/sbin/${i}  ${P_REL_ABS}/tools/host/sbin
       fi
    done
    echo -e "\t -->check lib"
    for i in `ls output/host/usr/lib/`
    do 
       if [[ ! -e ${P_REL_ABS}/toolchain/lib/${i} || ! -d ${P_REL_ABS}/toolchain/lib/${i} ]];then
            echo -e "\t\twill be add -->  "${i}
            cp -rf  output/host/usr/lib/${i}  ${P_REL_ABS}/tools/host/lib/
       fi
    done
    echo -e "\t -->check share"
    for i in `ls output/host/usr/share/`
    do 
       if [[ ! -e ${P_REL_ABS}/toolchain/share/${i} || ! -d ${P_REL_ABS}/toolchain/share/${i} ]];then
            echo -e "\t\twill be add -->  "${i}
            cp -rf output/host/usr/share/${i}  ${P_REL_ABS}/tools/host/share
       fi
    done


}
rel_qsdk_files(){
    echo -e "-->release qsdk files"
    cd ${WORKSPACE}
    cp -rf output/system/*  ${P_REL_ABS}/qsdk/
    cp -rf output/staging/*  ${P_REL_ABS}/qsdk/
    cd ${P_REL_ABS}/qsdk
    cp -rf usr/local/lib/*  usr/lib/
    cp -rf usr/local/include/*  usr/include/
    rm -rf usr/local
    find usr/lib/pkgconfig  -name "*.pc" | xargs  -i  sed -i "s/\/local//g"  {}
    rel_clean_busybox_files ${P_REL_ABS}/qsdk/
}
rel_repo_source(){
    echo -e "-->release source "$1
    mkdir -p ${WORKSPACE}/$1
    cd ${WORKSPACE}/$1
    mkdir -p ${P_REL_ABS}/$1
    git archive HEAD | tar -x -C ${P_REL_ABS}/$1
    git log -1  > ${P_REL_ABS}/$1/GIT_VERSION
}
rel_bootloader_fix(){
    cd ${WORKSPACE}/
    board_cpu=`cat output/images/items.itm |grep board.cpu | awk '{print $2}'`
    cd ${P_REL_ABS}
    echo ${board_cpu}  > bootloader/board_cpu
    mv bootloader/${board_cpu}  bootloader/uboot0
    rm -rf bootloader/apollo*
    rm -rf uboot
    mv bootloader uboot
}


rel_tools(){
    echo -e "-->release tools"
}
rel_busybox(){
    echo -e "-->release busybox"
    cd ${WORKSPACE}
    ver=`cat .config |grep BUSYBOX_VERSION= |awk -F '"' '{print $2'}`
    echo -e "\t\t busybox version -> "${ver}
    tar xf buildroot/download/busybox-${ver}.tar.bz2 -C  ${P_REL_ABS}
    rm -rf ${P_REL_ABS}/busybox
    mv ${P_REL_ABS}/busybox-${ver}  ${P_REL_ABS}/busybox
    echo ${ver}  > ${P_REL_ABS}/busybox/version
}
rel_busybox_extra(){
    echo -e "-->release busybox extra"
}
rel_tools_extra(){
    echo -e "-->release tools extra"
}
rel_custom_packages(){
    echo -e "-->release custom package"
    cd ${WORKSPACE}
    echo -e "\trelease wifi debug package"
    cp -rf system/qlibwifi   ${P_REL_ABS}/packages/
    echo -e "\trelease catmsensor package"
    cp -rf system/hlibcamsensor   ${P_REL_ABS}/packages/

}
rel_product_fix(){
    echo -e "-->release product fix"
    cd ${WORKSPACE}
    echo -e "\tremove unrelevant products:"
    for i in `ls output/product -l`
    do 
        PRODUCT=`basename $i 2>/dev/null`
    done
    cd ${P_REL_ABS}/products
    for i in `ls`; do
	    if [ "$i" != "${PRODUCT}" ] && [ "$i" != "GIT_VERSION" ]; then
		    rm $i -rf
            echo -e  "\t\t$i removed"
	    fi
    done
    echo -e "\n\tfix module install script"
    #ls  ${P_REL_ABS}/qsdk/etc/init.d/  | xargs -i ${WORKSPACE}/tools/sdk/kofix   ${P_REL_ABS}/qsdk/etc/init.d/{}
    scripts_list=`grep "modprobe"  -R  ${P_REL_ABS}/products |awk -F ':' '{print $1}'`
    for i in ${scripts_list} 
    do
        if [[ -e $i ]] ;then
            ${WORKSPACE}/tools/sdk/kofix  $i  |xargs -i echo -e "\t\t"{}
        fi
    done
    scripts_list=`grep "modprobe"  -R  ${P_REL_ABS}/qsdk/etc/init.d/ |awk -F ':' '{print $1}'`
    for i in ${scripts_list} 
    do
        if [[ -e $i ]] ;then
            ${WORKSPACE}/tools/sdk/kofix  $i  |xargs -i echo -e "\t\t"{}
        fi
    done

}

rel_clean_busybox_files(){
    echo -e "\t clean busybox rootfs files ->"$1
    cd $1
    old_path=`pwd`
    cd ${old_path}/bin
    #rm -rf busybox
    for i in `ls` 
    do 
        if [[ "busybox" == `readlink $i` ]]; then
            #echo "delete ->"$i
            rm $i
        fi
    done
    cd ${old_path}/sbin
    #rm -rf busybox
    for i in `ls` 
    do 
        if [[ "../bin/busybox" == `readlink $i` ]]; then
            #echo "delete ->"$i
            rm $i
        fi
    done
    cd ${old_path}/usr/bin
    #rm -rf busybox
    for i in `ls` 
    do 
        if [[ "../../bin/busybox" == `readlink $i` ]]; then
            #echo "delete ->"$i
            rm $i
        fi
    done
    cd ${old_path}/usr/sbin
    #rm -rf busybox
    for i in `ls` 
    do 
        if [[ "../../bin/busybox" == `readlink $i` ]]; then
            #echo "delete ->"$i
            rm $i
        fi
    done
    rm -rf ${old_path}/bin/busybox
    rm -rf ${old_path}/linuxrc
}
rel_ramdisk(){
    echo -e "-->release ramdisk"
    cd ${WORKSPACE}
    cp  -rf  output/root/*    ${P_REL_ABS}/qsdk/ramdisk
    rel_clean_busybox_files  ${P_REL_ABS}/qsdk/ramdisk
}
rel_private_modules(){
    echo -e "-->release private modules"
    cd ${WORKSPACE}
    find output/system  -name "*.ko"  | xargs -i cp -rf {}  ${P_REL_ABS}/private/
}
rel_sdk(){
    echo -e "-->release sdk "
    rel_init_rel_dir
    rel_ramdisk
    #exit 0
    rel_qsdk_files
    rel_host_toolchain
    rel_host_extra
    rel_repo_source tools
    rel_repo_source bootloader
    rel_repo_source kernel
    rel_bootloader_fix
    rel_busybox
    rel_busybox_extra
    rel_custom_packages
    rel_repo_source products
    rel_product_fix
    rel_private_modules
    rel_ramdisk
    echo -e "\n\nSDK relese over"
    echo -e "\t"${P_REL_ABS}
}
rel_sdk 



