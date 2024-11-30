#!/bin/bash
#### do not perform this in chroot environment
export LFS=/mnt/lfs


echo "This cannot be done in the chroot environment"

if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root. Please login as the root user."
    exit 1
fi


#### ENTER SAFE GUARD FOR CHROOT

### Unmount virtual file system
mountpoint -q $LFS/dev/shm && umount $LFS/dev/shm
umount $LFS/dev/pts
umount $LFS/{sys,proc,run,dev}

cd $LFS
tar -cJpf $HOME/lfs-temp-tools.tar.xz .

echo "Back up of lfs-temp-tools.tar.xz has been created"

exit 0

