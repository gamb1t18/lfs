#!/bin/bash

cd /sources
###### lfs bootscripts 20240825 ################################
tar -xf  lfs-bootscripts-20240825.tar.xz
cd  lfs-bootscripts-20240825
make install
cd ..
mf -rf  lfs-bootscripts-20240825
###############next line creates initial udev rules for naming scheme
bash /usr/lib/udev/init-net-rules.sh 

## run this ### ### code and copy NAME########### COPY NAME ######### COPY NAME ###########
echo "change the value of IFACE to the NAME of the output"
cat /etc/udev/rules.d/70-persistent-net.rules
echo "hit enter to continue"
read -r

###this creates a sample file for the eth0 device with a static IP address
### change IFACE to output of NAME from previous command
cd /etc/sysconfig/
cat > ifconfig.eth0 << "EOF"
ONBOOT=yes
IFACE=eth0
SERVICE=ipv4-static
IP=192.168.1.2
GATEWAY=192.168.1.1
PREFIX=24
BROADCAST=192.168.1.255
EOF

cat > /etc/resolv.conf << "EOF"
# Begin /etc/resolv.conf
domain Muppetelphia
nameserver 192.168.1.1
#nameserver <IP address of your secondary nameserver>
# End /etc/resolv.conf
EOF

echo "FozzieLinux-0.1" > /etc/hostname


cat > /etc/hosts << "EOF"
# Begin /etc/hosts
127.0.0.1 localhost.localdomain localhost
127.0.1.1 <FQDN> FozzieLinux-0.1
192.168.1.1 <FQDN> FozzieLinux-0.1
# End /etc/hosts
EOF

### configure sysvinit
cat > /etc/inittab << "EOF"
# Begin /etc/inittab
id:3:initdefault:
si::sysinit:/etc/rc.d/init.d/rc S
l0:0:wait:/etc/rc.d/init.d/rc 0
l1:S1:wait:/etc/rc.d/init.d/rc 1
l2:2:wait:/etc/rc.d/init.d/rc 2
l3:3:wait:/etc/rc.d/init.d/rc 3
l4:4:wait:/etc/rc.d/init.d/rc 4
l5:5:wait:/etc/rc.d/init.d/rc 5
l6:6:wait:/etc/rc.d/init.d/rc 6
ca:12345:ctrlaltdel:/sbin/shutdown -t1 -a -r now
su:S06:once:/sbin/sulogin
s1:1:respawn:/sbin/sulogin
1:2345:respawn:/sbin/agetty --noclear tty1 9600
2:2345:respawn:/sbin/agetty tty2 9600
3:2345:respawn:/sbin/agetty tty3 9600
4:2345:respawn:/sbin/agetty tty4 9600
5:2345:respawn:/sbin/agetty tty5 9600
6:2345:respawn:/sbin/agetty tty6 9600
# End /etc/inittab
EOF

cat > /etc/sysconfig/clock << "EOF"
# Begin /etc/sysconfig/clock
UTC=1
# Set this to any options you might need to give to hwclock,
# such as machine hardware clock type for Alphas.
CLOCKPARAMS=
# End /etc/sysconfig/clock
EOF

cat > /etc/sysconfig/console << "EOF"
# Begin /etc/sysconfig/console
UNICODE="1"
FONT="Lat2-Terminus16"
# End /etc/sysconfig/console
EOF

SYSKLOGD_PARMS=
LC_ALL=en_US.utf8 locale charmap




