#!/bin/bash

if [ -z "$LFS" ]; then
	export LFS=/mnt/lfs
fi

echo "Downloading Package list"
wget https://raw.githubusercontent.com/gamb1t18/lfs/refs/heads/main/wget-list-sysv --directory-prefix=$LFS/sources
wget https://www.linuxfromscratch.org/lfs/view/stable/md5sums --directory-prefix=$LFS/sources

echo "Downloading packages"
wget --input-file=$LFS/sources/wget-list-sysv --continue --directory-prefix=$LFS/sources


echo "MD5SUM check"
pushd $LFS/sources
md5sum -c md5sums
if [ $? -eq 0 ]; then
	echo "MD5SUM check good"
else
	echo "MD5SUM failed"
	exit 1
fi
popd

wget https://downloads.sourceforge.net/freetype/freetype-2.13.3.tar.xz --directory-prefix=$LFS/sources
wget https://downloads.sourceforge.net/freetype/freetype-doc-2.13.3.tar.xz --directory-prefix=$LFS/sources
wget http://ftp.rpm.org/popt/releases/popt-1.x/popt-1.19.tar.gz --directory-prefix=$LFS/sources
wget https://mandoc.bsd.lv/snapshots/mandoc-1.14.6.tar.gz --directory-prefix=$LFS/sources
wget https://github.com/rhboot/efivar/archive/39/efivar-39.tar.gz --directory-prefix=$LFS/sources
wget https://github.com/rhboot/efibootmgr/archive/18/efibootmgr-18.tar.gz --directory-prefix=$LFS/sources
wget https://unifoundry.com/pub/unifont/unifont-15.1.05/font-builds/unifont-15.1.05.pcf.gz --directory-prefix=$LFS/sources
