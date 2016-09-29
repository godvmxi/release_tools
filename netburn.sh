#!/bin/bash

# your IMAGE path
upgrade_tool=output/build/qlibupgrade-1.0.0/upgrade
image_path=output/images
local_addr=`ip addr | grep inet | grep eth | cut -f 6 -d ' ' | cut -f 1 -d '/'`
local_port=8080

if ! test -f ${upgrade_tool}; then
	echo "Cannot find upgrade tool, make sure **qlibupgrade** is compiled!"
	exit
fi

if test -z "`whereis python 2>/dev/null`"; then
	echo "Python is not installed!"
	exit
fi

echo " #!/bin/sh

for i in \`ps | sed '/PID/d' | sed '/sh/d' | cut -f 1 -d 'r'\`; do
	echo \"killing \$i\"
	kill -9 \$i > /dev/null 2>&1
done 
umount /config
sleep 2
clear
rm -f /tmp/upgrade
rm -f /tmp/burn.ius
wget http://${local_addr}:${local_port}/upgrade -P /tmp
wget http://${local_addr}:${local_port}/burn.ius -P /tmp
chmod 777 /tmp/upgrade
/tmp/upgrade /tmp/burn.ius
" > ${image_path}/update

cp -f ${upgrade_tool} ${image_path}
echo -e "\nPaste the commands below to device prompt to update:\n"
echo -e "  curl http://${local_addr}:${local_port}/update | sh\n"
echo -e "After updating, Ctrl-C to exit..."

cd ${image_path}
python -m SimpleHTTPServer ${local_port}

