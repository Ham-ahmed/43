#!/bin/bash

## setup command=wget -q https://raw.githubusercontent.com/levi-45/Manager/main/installer.sh -O - | /bin/sh -O - | /bin/sh
## Only This 2 lines to edit with new version ######
version='10.1-r39'
changelog='Fix Dreambox issue'
##
TMPPATH=/tmp/Manager-main
FILEPATH=/tmp/main.tar.gz

if [ ! -d /usr/lib64 ]; then
	PLUGINPATH=/usr/lib/enigma2/python/Plugins/Extensions/Manager
else
	PLUGINPATH=/usr/lib64/enigma2/python/Plugins/Extensions/Manager
fi

## Remove tmp directory
[ -r $TMPPATH ] && rm -f $TMPPATH > /dev/null 2>&1

## Remove tmp directory
[ -r $FILEPATH ] && rm -f $FILEPATH > /dev/null 2>&1

## Remove old plugin directory
[ -r $PLUGINPATH ] && rm -rf $PLUGINPATH

## check depends packges
if [ -f /var/lib/dpkg/status ]; then
   STATUS=/var/lib/dpkg/status
   OSTYPE=DreamOs
else
   STATUS=/var/lib/opkg/status
   OSTYPE=Dream
fi
echo ""

if [ -f /usr/bin/wget ]; then
    echo "wget exist"
else
	if [ $OSTYPE = "DreamOs" ]; then
		echo "dreamos"
		apt-get update && apt-get install wget
	else
		opkg update && opkg install wget
	fi
fi
if python --version 2>&1 | grep -q '^Python 3\.'; then
	echo "You have Python3 image"
	PYTHON=PY3
	Packagesix=python3-six
	Packagerequests=python3-requests
else
	echo "You have Python2 image"
	PYTHON=PY2
	Packagerequests=python-requests
fi

if [ $PYTHON = "PY3" ]; then
	if grep -qs "Package: $Packagesix" cat $STATUS ; then
		echo ""
	else
		opkg update && opkg --force-reinstall --force-overwrite install python3-six
	fi
fi
echo ""
if grep -qs "Package: $Packagerequests" cat $STATUS ; then
	echo ""
else
	echo "Need to install $Packagerequests"
	echo ""
	if [ $OSTYPE = "DreamOs" ]; then
		apt-get update && apt-get install python-requests -y
	elif [ $PYTHON = "PY3" ]; then
		opkg update && opkg --force-reinstall --force-overwrite install python3-requests
	elif [ $PYTHON = "PY2" ]; then
		opkg update && opkg --force-reinstall --force-overwrite install python-requests
	fi
fi
echo ""


## Download and install plugin
## check depends packges
mkdir -p $TMPPATH
cd $TMPPATH
set -e
if [ $OSTYPE = "DreamOs" ]; then
   echo "# Your image is OE2.5/2.6 #"
   echo ""
else
   echo "# Your image is OE2.0 #"
   echo ""
fi

sleep 2
wget --no-check-certificate 'https://github.com/levi-45/Manager/archive/refs/heads/main.tar.gz'
tar -xzf main.tar.gz
cp -r 'Manager-main/usr' '/'
## cp -r 'Manager-main/etc' '/'
set +e
cd
sleep 2

## Check if plugin installed correctly
if [ ! -d $PLUGINPATH ]; then
	echo "Some thing wrong .. Plugin not installed"
	exit 1
fi

rm -rf $TMPPATH > /dev/null 2>&1
sync
echo ""
echo ""
echo "#########################################################"
echo "#        	Manager INSTALLED SUCCESSFULLY      	      #"
echo "#                Moded  by Levi45                       #"
echo "#                                                       #"
echo "#            https://satellite-forum.com                #"
echo "#########################################################"
echo "#           your Device will RESTART Now                #"
echo "#########################################################"
sleep 5

killall -9 enigma2
exit 0
