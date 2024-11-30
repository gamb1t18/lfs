#!/bin/bash
###################### must be run at lfs #########################
if [ "$EUID" -eq 0 ]; then
	echo "This script must NOT be run as root. Please run it as user lfs"
	exit 1
fi

cat > ~/.bash_profile << "EOF"
exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash
EOF

cat > ~/.bashrc << "EOF"
set +h
umask 022
LFS=/mnt/lfs
LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu
PATH=/usr/bin
if [ ! -L /bin ]; then PATH=/bin:$PATH; fi
PATH=$LFS/tools/bin:$PATH
CONFIG_SITE=$LFS/usr/share/config.site
export LFS LC_ALL LFS_TGT PATH CONFIG_SITE
EOF

cat >> ~/.bashrc << "EOF"
export MAKEFLAGS=-j12
EOF

source ~/.bash_profile ##### This command opens a new shell with new environment


echo "Profile update. Please log in as root and run the next script"

exit 0
