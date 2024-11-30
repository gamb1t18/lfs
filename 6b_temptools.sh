#!/bin/bash

##### Making directory in the new file system #########

mkdir -pv /{boot,home,mnt,opt,srv}
mkdir -pv /etc/{opt,sysconfig}
mkdir -pv /lib/firmware
mkdir -pv /media/{floppy,cdrom}
mkdir -pv /usr/{,local/}{include,src}
mkdir -pv /usr/lib/locale
mkdir -pv /usr/local/{bin,lib,sbin}
mkdir -pv /usr/{,local/}share/{color,dict,doc,info,locale,man}
mkdir -pv /usr/{,local/}share/{misc,terminfo,zoneinfo}
mkdir -pv /usr/{,local/}share/man/man{1..8}
mkdir -pv /var/{cache,local,log,mail,opt,spool}
mkdir -pv /var/lib/{color,misc,locate}

ln -sfv /run /var/run
ln -sfv /run/lock /var/lock

install -dv -m 0750 /root
install -dv -m 1777 /tmp /var/tmp

ln -sv /proc/self/mounts /etc/mtab

##for test suites and Perl config files ###

cat > /etc/hosts << EOF
127.0.0.1 localhost $(hostname)
::1 localhost
EOF

#### creating root entries in /etc/psswd #######

cat > /etc/passwd << "EOF"
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/dev/null:/usr/bin/false
daemon:x:6:6:Daemon User:/dev/null:/usr/bin/false
messagebus:x:18:18:D-Bus Message Daemon User:/run/dbus:/usr/bin/false
uuidd:x:80:80:UUID Generation Daemon User:/dev/null:/usr/bin/false
nobody:x:65534:65534:Unprivileged User:/dev/null:/usr/bin/false
EOF

cat > /etc/group << "EOF"
root:x:0:
bin:x:1:daemon
sys:x:2:
kmem:x:3:
tape:x:4:
tty:x:5:
daemon:x:6:
floppy:x:7:
disk:x:8:
lp:x:9:
dialout:x:10:
audio:x:11:
video:x:12:
utmp:x:13:
cdrom:x:15:
adm:x:16:
messagebus:x:18:
input:x:24:
mail:x:34:
kvm:x:61:
uuidd:x:80:
wheel:x:97:
users:x:999:
nogroup:x:65534:
EOF

localedef -i C -f UTF-8 C.UTF-8

#### creating a regular user for later use ######

echo "tester:x:101:101::/home/tester:/bin/bash" >> /etc/passwd
echo "tester:x:101:" >> /etc/group
install -o tester -d /home/tester

##### create new shell with new username ######
exec /usr/bin/bash --login

touch /var/log/{btmp,lastlog.faillog,wtmp}
chgrp -v utmp /var/log/lastlog
chmod -v 664 /var/log/lastlog
chmod -v 600 /var/log/btmp

cd /sources
######### getting packages ##################
########### gettext ######################

tar -xf gettext-0.22.5.tar.xz
cd gettext-0.22.5

./configure --disable-shared

make

cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} /usr/bin

cd ..
rm -rf gettext-0.22.5

############# bison ###############################

tar -xf bison-3.8.2.tar.xz
cd bison-3.8.2

./configure --prefix=/usr \
--docdir=/usr/share/doc/bison-3.8.2

make
make install

cd ..
rm -rf bison-3.8.2

############ perl #######################################

tar -xf perl-5.40.0.tar.xz
cd perl-5.40.0

sh Configure -des \
-D prefix=/usr \
-D vendorprefix=/usr \
-D useshrplib \
-D privlib=/usr/lib/perl5/5.40/core_perl \
-D archlib=/usr/lib/perl5/5.40/core_perl \
-D sitelib=/usr/lib/perl5/5.40/site_perl \
-D sitearch=/usr/lib/perl5/5.40/site_perl \
-D vendorlib=/usr/lib/perl5/5.40/vendor_perl \
-D vendorarch=/usr/lib/perl5/5.40/vendor_perl

make
make install

cd..
rm -rf perl-5.40.0

###################### python ##############################
### may get  Pything requires a OpenSSL 1.1.1. or new message, ignore it ####
tar -xf Python-3.12.5.tar.xz
cd Python-3.12.5

./configure --prefix=/usr \
--enable-shared \
--without-ensurepip

make 
make install

cd ..
rm -rf Python-3.12.5

################# texinfo ##################################

tar -xf texinfo-7.1.tar.xz
cd texinfo-7.1

./configure --prefix=/usr
 
 make
 make install
 
 cd ..
 rm -rf texinfo-7.1
 
 ################ util-linux ################################

tar -xf util-linux-2.40.0.tar.xz
cd util-linux-2.40.0

mkdir -pv /var/lib/hwclock

./configure --libdir=/usr/lib \
--runstatedir=/run \
--disable-chfn-chsh \
--disable-login \
--disable-nologin \
--disable-su \
--disable-setpriv \
--disable-runuser \
--disable-pylibmount \
--disable-static \
--disable-liblastlog2 \
--without-python \
ADJTIME_PATH=/var/lib/hwclock/adjtime \
--docdir=/usr/share/doc/util-linux-2.40.2

make
make install

cd ..
rm -rf util-linux-2.40.0

############### cleaning up ###############################

rm -rf /usr/share/{info,man,doc}/* ### rm documentation files
find /usr/{lib,libexec} -name \*.la -delete ### .la files not needed (only for libtbl)

# essential program and libraries should be created
# it is safe to delete /tools
rm -rf /tools

### script 7b is optional and makes a back up
### sctipt 7b must be performd outside chroot
echo "You can run script 7b, to make a backup at this point"
echo "If you do so, log out and log in as root"
echo "Otherwise, let's build this new linux, run script 8"

exit 0
