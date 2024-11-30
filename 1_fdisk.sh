# automation of fdisk for partitioning and filesystem ext4
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root. Please log out run as the root user."
    exit 1
fi

LFS_DISK="$1" # $1 means the first argument passed

#for the folloing: g selects GUID
#n is for new partition, the next two spaces select default partition number and start location
#+512 is for space allocation, t is for type, 1 is code for efi. The same pattern follows.
#The last partition  has a space for allocation, the default value to end of disk. p prints
#partitions and w writes them do the disk
fdisk "$LFS_DISK" << EOF
g
n


+512M
t
1
n


+256M
n


+2G
t
3
19
n



p
w
EOF

mkfs.vfat -F32 /dev/"${LFS_DISK}p1"
mkfs -v -t ext4 /dev/"${LFS_DISK}p2"
mkfs -v-t ext4 /dev/"${LFS_DISK}p4"
mkswap /dev/"${LFS_DISK}p3"
/sbin/swapon -v /dev/nvme0n1p3

exit 0