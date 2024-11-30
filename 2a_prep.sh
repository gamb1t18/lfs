#!/bin/bash

## Beginning of process, first step ######
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root. Please log out run as the root user."
    exit 1
fi

export LFS=/mnt/lfs

mkdir -pv $LFS
mkdir -pv $LFS/sources #dir for downloading tarballs
mount -v -t ext4 /dev/nvme0n1p4 $LFS #mountpoint for new linux OS
chmod -v a+wt $LFS/sources # enables write and sticky mode
mkdir -pv $LFS/tools # dir for compilers
mkdir -pv $LFS/scripts # for installation scripts
copy -r /home/gentoo/complete $LFS/scripts

case $(uname -m) in
	x86_64) mkdir -pv $LFS/lib64 ;;
esac

#################################### DOWNLOADING PACKAGES to $LFS/source
source 2b_packages.sh # downloads packages and MD5SUMs

chown root:root $LFS/sources/*  #### 

#############444################# CREATING Linux Filesystem#########

mkdir -pv $LFS/{etc,var} $LFS/usr/{bin,lib,sbin}
for i in bin lib sbin; do
ln -sv usr/$i $LFS/$i
done
case $(uname -m) in
x86_64) mkdir -pv $LFS/lib64 ;;
esac

mkdir -pv $LFS/tools

groupadd lfs
useradd -s /bin/bash -g lfs -m -k /dev/null lfs
echo "lets create a password for the lfs account to start"
passwd lfs

chown -v lfs $LFS/{usr{,/*},lib,var,etc,bin,sbin,tools,sources,scripts}
chmod -R u+w $LFS
case $(uname -m) in
x86_64) chown -v lfs $LFS/lib64 ;;
esac

usermod -aG wheel lfs ## Adds lfs to sudo in gentoo

echo "Please log out as root and log in as user lfs"

exit 0
