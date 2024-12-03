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

############ Zlib-1.3.1 ##################################################
tar -xzf zlib-1.3.1.tar.gz
cd zlib-1.3.1

./configure --prefix=/usr
make
make check
make install

rm -fv /usr/lib/libz.a
cd ..
rm -rf zlib-1.3.1

####################### Bzip2-1.0.8 #####################################

tar -xf bzip2-1.0.8.tar.gz
cd bzip2-1.0.8

patch -Np1 -i ../bzip2-1.0.8-install_docs-1.patch
sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile
sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile
make -f Makefile-libbz2_so
make clean
make
make PREFIX=/usr install
cp -av libbz2.so.* /usr/lib
ln -sv libbz2.so.1.0.8 /usr/lib/libbz2.so
cp -v bzip2-shared /usr/bin/bzip2

for i in /usr/bin/{bzcat,bunzip2}; do
ln -sfv bzip2 $i
done
rm -fv /usr/lib/libbz2.a
cd ..
rm -rf bzip2-1.0.8

################################## xz-5.6.2 #############################

tar -xf xz-5.6.2.tar.xz
cd xz-5.6.2

./configure --prefix=/usr \
--disable-static \
--docdir=/usr/share/doc/xz-5.6.2

make
make check
make install

cd ..
rm -rf xz-5.6.2

########################### lz4-1.10.0 #######################################

tar -xf lz4-1.10.0.tar.gz
cd lz4-1.10.0

make BUILD_STATIC=no PREFIX=/usr
make -j1 check
make BUILD_STATIC=no PREFIX=/usr install

cd ..
rm -rf lz4-1.10.0

############################### zstd-1.5.6 ##################################

tar -xzf zstd-1.5.6.tar.gz
cd zstd-1.5.6

make prefix=/usr
make check
make prefix=/usr install
rm -v /usr/lib/libzstd.a

cd ..
rm -rf zstd-1.5.6

####################### file-5.45 ####################################

tar file-5.45.tar.xz
cd file-5.45

./configure --prefix=/usr
make
make check
make install

cd ..
rm -rf file-5.45
################### readline-8.2.13 #########################################
tar -xzf readline-8.2.13.tar.gz
cd readline-8.2.13

sed -i '/MV.*old/d' Makefile.in
sed -i '/{OLDSUFF}/c:' support/shlib-install
sed -i 's/-Wl,-rpath,[^ ]*//' support/shobj-conf

./configure --prefix=/usr \
--disable-static \
--with-curses \
--docdir=/usr/share/doc/readline-8.2.13

make SHLIB_LIBS="-lncursesw"
make SHLIB_LIBS="-lncursesw" install
install -v -m644 doc/*.{ps,pdf,html,dvi} /usr/share/doc/readline-8.2.13

cd ..
rm -rf readline-8.2.13
################################# m4-1.4.19 ###############################
tar -xf m4-1.4.19.tar.xz
cd m4-1.4.19

./configure --prefix=/usr
make
make check
make install

cd ..
rm -rf m4-1.4.19
########################## bc-6.7.6 ############################
tar -xf bc-6.7.6.tar.xz
cd bc-6.7.6

CC=gcc ./configure --prefix=/usr -G -O3 -r
make
make test
make install

cd ..
rm -rf bc-6.7.6
########################### flex-2.6.4 #############################
tar -xzf flex-2.6.4.tar.gz
cd flex-2.6.4

./configure --prefix=/usr \
--docdir=/usr/share/doc/flex-2.6.4 \
--disable-static

make
make check
make install

ln -sv flex /usr/bin/lex
ln -sv flex.1 /usr/share/man/man1/lex.1

cd ..
rm -rf flex-2.4.6
############################ tcl-8.6.14 ########################
tar -xzf tcl8.6.14-src.tar.gz
cd tcl8.6.14-src

SRCDIR=$(pwd)
cd unix
./configure --prefix=/usr \
--mandir=/usr/share/man \
--disable-rpath

make

sed -e "s|$SRCDIR/unix|/usr/lib|" \
-e "s|$SRCDIR|/usr/include|" \
-i tclConfig.sh
sed -e "s|$SRCDIR/unix/pkgs/tdbc1.1.7|/usr/lib/tdbc1.1.7|" \
-e "s|$SRCDIR/pkgs/tdbc1.1.7/generic|/usr/include|" \
-e "s|$SRCDIR/pkgs/tdbc1.1.7/library|/usr/lib/tcl8.6|" \
-e "s|$SRCDIR/pkgs/tdbc1.1.7|/usr/include|" \
-i pkgs/tdbc1.1.7/tdbcConfig.sh
sed -e "s|$SRCDIR/unix/pkgs/itcl4.2.4|/usr/lib/itcl4.2.4|" \
-e "s|$SRCDIR/pkgs/itcl4.2.4/generic|/usr/include|" \
-e "s|$SRCDIR/pkgs/itcl4.2.4|/usr/include|" \
-i pkgs/itcl4.2.4/itclConfig.sh
unset SRCDIR

make test
make install
chmod -v u+w /usr/lib/libtcl8.6.so
make install-private-headers
ln -sfv tclsh8.6 /usr/bin/tclsh
mv /usr/share/man/man3/{Thread,Tcl_Thread}.3

cd ..
tar -xf ../tcl8.6.14-html.tar.gz --strip-components=1
mkdir -v -p /usr/share/doc/tcl-8.6.14
cp -v -r ./html/* /usr/share/doc/tcl-8.6.14

cd ..
rm -rf tcl8.6.14-src
###################### expect-5.45.4 ########################
tar -xzf expect5.45.4.tar.gz
cd expect5.45.4

python3 -c 'from pty import spawn; spawn(["echo", "ok"])'
patch -Np1 -i ../expect-5.45.4-gcc14-1.patch

./configure --prefix=/usr \
--with-tcl=/usr/lib \
--enable-shared \
--disable-rpath \
--mandir=/usr/share/man \
--with-tclinclude=/usr/include

make
make test
make install
ln -svf expect5.45.4/libexpect5.45.4.so /usr/lib
cd ..
rm -rf expect5.45.4
######################## dejaGNU-1.6.3 #########################
tar -xzf dejagnu-1.6.3.tar.gz
cd dejagnu-1.6.3

mkdir -v build
cd build

../configure --prefix=/usr
makeinfo --html --no-split -o doc/dejagnu.html ../doc/dejagnu.texi
makeinfo --plaintext -o doc/dejagnu.txt ../doc/dejagnu.texi

make check
make install

install -v -dm755 /usr/share/doc/dejagnu-1.6.3
install -v -m644 doc/dejagnu.{html,txt} /usr/share/doc/dejagnu-1.6.3

cd ..
rm -rf dejagnu-1.6.3
#################### pkgconf-2.3.0 ################################
tar -xf pkgconf-2.3.0.tar.xz
cd pkgconf-2.3.0

./configure --prefix=/usr \
--disable-static \
--docdir=/usr/share/doc/pkgconf-2.3.0

make
make install

ln -sv pkgconf /usr/bin/pkg-config
ln -sv pkgconf.1 /usr/share/man/man1/pkg-config.1

cd..
rm -rf pkgconf-2.3.0
################### binutils-2.43.1 ######################
tar -xf binutils-2.43.1.tar.xz
cd binutils-2.43.1
../configure --prefix=/usr \
--sysconfdir=/etc \
--enable-gold \
--enable-ld=default \
--enable-plugins \
--enable-shared \
--disable-werror \
--enable-64-bit-bfd \
--enable-new-dtags \
--with-system-zlib \
--enable-default-hash-style=gnu

make tooldir=/usr
make -k check
make tooldir=/usr
make tooldir=/usr install
rm -fv /usr/lib/lib{bfd,ctf,ctf-nobfd,gprofng,opcodes,sframe}.a

cd ..
rm -rf binutils-2.43.1
##################### gmp-6.3.0 ############################
tar gmp-6.3.0.tar.xz
cd gmp-6.3.0

./configure --prefix=/usr \
--enable-cxx \
--disable-static \
--docdir=/usr/share/doc/gmp-6.3.0

make
make html

make check 2>&1 | tee gmp-check-log
awk '/# PASS:/{total+=$3} ; END{print total}' gmp-check-log
echo "At least 199 tests should have passed"
echo "Hit enter to continue"
read -r
make install
make install-html

cd ..
rm -rf gmp-6.3.0
####################### mpfr-4.2.1 #################
tar -xf mpfr-4.2.1.tar.xz
cd mpfr-4.2.1

./configure --prefix=/usr \
--disable-static \
--enable-thread-safe \
--docdir=/usr/share/doc/mpfr-4.2.1

make
make html
make check
make install
make install-html
cd..
rm -rf mpfr-4.2.1
############################ mpc-1.3.1 ##################
tar mpc-1.3.1.tar.xz
cd mpc-1.3.1
./configure --prefix=/usr \
--disable-static \
--docdir=/usr/share/doc/mpc-1.3.1

make
make html
make check
make install
make install-html
cd ..
rm -rf mpc-1.3.1
################# attr-2.5.2 #########################
tar -xzf attr-2.5.2.tar.gz
cd attr-2.5.2

./configure --prefix=/usr \
--disable-static \
--sysconfdir=/etc \
--docdir=/usr/share/doc/attr-2.5.2

make
make check
make install
cd ..
rm -rf attr-2.5.2
#################### acl-2.3.2 ############################
tar -xf acl-2.3.2.tar.xz
cd acl-2.3.2

./configure --prefix=/usr \
--disable-static \
--docdir=/usr/share/doc/acl-2.3.2

make
make install
cd ..
rm -rf acl-2.3.2
##################### libcap-2.70 ########################
tar -xf libcap-2.70.tar.xz
cd libcap-2.70

sed -i '/install -m.*STA/d' libcap/Makefile
make prefix=/usr lib=lib
make test
make prefix=/usr lib=lib install
cd..
rm -rf licap-2.70
############################libxcrypt-4.4.36 ##################
tar -xf  libxcrypt-4.4.36.tar.xz 
cd  libxcrypt-4.4.36

./configure --prefix=/usr \
--enable-hashes=strong,glibc \
--enable-obsolete-api=no \
--disable-static \
--disable-failure-tokens

make
make check
make install
cd ..
rm -rf libxcrypt-4.4.36
####################### shadow-4.16.0 ############################
tar shadow-4.16.0.tar.xz
cd shadow-4.16.0

sed -i 's/groups$(EXEEXT) //' src/Makefile.in
find man -name Makefile.in -exec sed -i 's/groups\.1 / /' {} \;
find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \;
find man -name Makefile.in -exec sed -i 's/passwd\.5 / /' {} \;

touch /usr/bin/passwd
./configure --sysconfdir=/etc \
--disable-static \
--with-{b,yes}crypt \
--without-libbsd \
--with-group-name-max-length=32

make

make exec_prefix=/usr install
make -C man install-man
#### 8.28.2
