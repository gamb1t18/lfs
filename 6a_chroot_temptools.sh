#!/bin/bash
export LFS=/mnt/lfs

##### Enter Chroot and Additional Temp Tool ###########
#### MUST BE DONE AS ROOT #####################

if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root. Please login as the root user."
    exit 1
fi

chown --from lfs -R root:root $LFS/{usr,lib,var,etc,bin,sbin,tools}
case $(uname -m) in
x86_64) chown --from lfs -R root:root $LFS/lib64 ;;
esac

mkdir -pv $LFS/{dev,proc,sys,run}

#### mount virtual file system #################

mount -v --bind /dev $LFS/dev ## for host system without devtmpfs support

mount -vt devpts devpts -o gid=5,mode=0620 $LFS/dev/pts
mount -vt proc proc $LFS/proc
mount -vt sysfs sysfs $LFS/sys
mount -vt tmpfs tmpfs $LFS/run

if [ -h $LFS/devshm ]; then
install -v -d -m 1777 $LFS$(realpath /dev/shm)
else
mount -vt tmpfs -o nosuid,nodev tmpfs $LFS/dev/shm
fi

##### enter chroot ################################

chroot "$LFS" /usr/bin/env -i \
HOME=/root \
TERM="$TERM" \
PS1='(lfs chroot) \u:\w\$ ' \
PATH=/usr/bin:/usr/sbin \
MAKEFLAGS="-j$(nproc)" \
TESTSUITEFLAGS="-j$(nproc)" \
/bin/bash --login

exit 0
