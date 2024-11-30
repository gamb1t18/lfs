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

