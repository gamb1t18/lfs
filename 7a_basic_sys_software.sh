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



cd ../..
rm -rf glibc-2.40
