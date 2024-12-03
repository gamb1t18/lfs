#!/bin/bash
export LFS=/mnt/lfs

########### Basic System Software #######################

cd /sources

########## man pages #######################################
tar -xf man-pages-6.9.1.tar.xz
cd man-pages-6.9.1

rm -v man3/crypt* ##removes two man pages for password hashing function

make prefix=/usr install

cd ..
rm -rf man-pages-6.9.1

################# iana etc #################################

tar -xzf iana-etc-20240806.tar.gz
cd iana-etc-20240806

cp services protocols /etc

cd ..
rm -rf iana-etc-20240806

################## glibc ####################################

tar -xf glibc-2.40.tar.xz
cd glibc-2.40

patch -Np1 -i ../glibc-2.40-fhs-1.patch ### for runtime data

mkdir -v build
cd build

echo "rootsbindir=/usr/sbin" > configparms

../configure --prefix=/usr \
--disable-werror \
--enable-kernel=4.19 \
--enable-stack-protector=strong \
--disable-nscd \
libc_cv_slibdir=/usr/lib

make
make check  ### some tests are likely to fail

touch /etc/ld.so.conf
sed '/test-installation/s@$(PERL)@echo not running@' -i ../Makefile ##skips an outdated sanity check
make install
sed '/RTLDLIST=/s@/usr@@g' -i /usr/bin/ldd ## fixes a path to ldd
 ## install locales
make localedata/install-locales
localedef -i C -f UTF-8 C.UTF-8
localedef -i ja_JP -f SHIFT_JIS ja_JP.SJIS 2> /dev/null || true

### configuring glibc
cat > /etc/nsswitch.conf << "EOF"
# Begin /etc/nsswitch.conf
passwd: files
group: files
shadow: files
hosts: files dns
networks: files
protocols: files
services: files
ethers: files
rpc: files
# End /etc/nsswitch.conf
EOF

tar -xf ../../tzdata2024a.tar.gz
ZONEINFO=/usr/share/zoneinfo
mkdir -pv $ZONEINFO/{posix,right}
for tz in etcetera southamerica northamerica europe africa antarctica
 \
asia australasia backward; do
zic -L /dev/null -d $ZONEINFO ${tz}
zic -L /dev/null -d $ZONEINFO/posix ${tz}
zic -L leapseconds -d $ZONEINFO/right ${tz}
done
cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO
zic -d $ZONEINFO -p America/New_York
unset ZONEINFO

tzselect #time zone select
2 #2 for Americas
49 #49 for U.S.
5 #timezone selection
1 # confirmation of timezone
##below link is unique to parameters from last three lines
ln -sfv /usr/share/zoneinfo/America/Indiana/Indianapolis/etc/localtime

cat > /etc/ld.so.conf << "EOF"
# Begin /etc/ld.so.conf
/usr/local/lib
/opt/lib
EOF

cat >> /etc/ld.so.conf << "EOF"
# Add an include directory
include /etc/ld.so.conf.d/*.conf
EOF
mkdir -pv /etc/ld.so.conf.d

cd ../..
rm -rf glibc-2.40
