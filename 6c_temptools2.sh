#!/bin/bash

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
