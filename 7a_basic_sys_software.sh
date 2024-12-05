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
for tz in etcetera southamerica northamerica europe africa antarctica \
asia australasia backward; do
zic -L /dev/null -d $ZONEINFO ${tz}
zic -L /dev/null -d $ZONEINFO/posix ${tz}
zic -L leapseconds -d $ZONEINFO/right ${tz}
done
cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO
zic -d $ZONEINFO -p America/New_York
unset ZONEINFO

tzselect #time zone select
#2 #2 for Americas
#49 #49 for U.S.
#5 #timezone selection
#1 # confirmation of timezone
##below link is unique to parameters from last three lines
ln -sfv /usr/share/zoneinfo/America/Indiana/Indianapolis /etc/localtime

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

tar -xzf file-5.45.tar.gz
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
tar -xzf tcl8.6.14-src.tar.gz
cd ..
rm -rf flex-2.6.4
############################ tcl-8.6.14 ########################
tar -xzf tcl8.6.14-src.tar.gz
cd tcl8.6.14

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

cd /sources
rm -rf tcl8.6.14
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

cd ..
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
make tooldir=/usr install
rm -fv /usr/lib/lib{bfd,ctf,ctf-nobfd,gprofng,opcodes,sframe}.a

cd ..
rm -rf binutils-2.43.1
##################### gmp-6.3.0 ############################
tar -xf gmp-6.3.0.tar.xz
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
cd ..
rm -rf mpfr-4.2.1
############################ mpc-1.3.1 ##################
tar -xzf mpc-1.3.1.tar.gz
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
cd ..
rm -rf libcap-2.70
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
tar -xf shadow-4.16.0.tar.xz
cd shadow-4.16.0

sed -i 's/groups$(EXEEXT) //' src/Makefile.in
find man -name Makefile.in -exec sed -i 's/groups\.1 / /' {} \;
find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \;
find man -name Makefile.in -exec sed -i 's/passwd\.5 / /' {} \;

sed -e 's:#ENCRYPT_METHOD DES:ENCRYPT_METHOD YESCRYPT:' \
-e 's:/var/spool/mail:/var/mail:' \
-e '/PATH=/{s@/sbin:@@;s@/bin:@@}' \
-i etc/login.defs

touch /usr/bin/passwd
./configure --sysconfdir=/etc \
--disable-static \
--with-{b,yes}crypt \
--without-libbsd \
--with-group-name-max-length=32

make
make exec_prefix=/usr install
make -C man install-man
pwconv
grpconv
mkdir -p /etc/default
useradd -D --gid 999
sed -i '/MAIL/s/yes/no/' /etc/default/useradd
echo "Set password for root"
passwd root
cd ..
rm -rf shadow-4.16.0
#################### gcc-14.2.0 #####################
tar -xf gcc-14.2.0.tar.gz
cd gcc-14.2.0

case $(uname -m) in
x86_64)
sed -e '/m64=/s/lib64/lib/' \
-i.orig gcc/config/i386/t-linux64
;;
esac

mkdir -v build
cd build

../configure --prefix=/usr \
LD=ld \
--enable-languages=c,c++ \
--enable-default-pie \
--enable-default-ssp \
--enable-host-pie \
--disable-multilib \
--disable-bootstrap \
--disable-fixincludes \
--with-system-zlib

make
ulimit -s -H unlimited

sed -e '/cpython/d' -i ../gcc/testsuite/gcc.dg/plugin/plugin.exp
sed -e 's/no-pic /&-no-pie /' -i ../gcc/testsuite/gcc.target/i386/pr113689-1.c
sed -e 's/300000/(1|300000)/' -i ../libgomp/testsuite/libgomp.c-c++-common/pr109062.c
sed -e 's/{ target nonpic } //' \
-e '/GOTPCREL/d' -i ../gcc/testsuite/gcc.target/i386/fentryname3.c

chown -R tester .
su tester -c "PATH=$PATH make -k check"
../contrib/test_summary
make install
chown -v -R root:root \
/usr/lib/gcc/$(gcc -dumpmachine)/14.2.0/include{,-fixed}
ln -svr /usr/bin/cpp /usr/lib
ln -sv gcc.1 /usr/share/man/man1/cc.1
ln -sfv ../../libexec/gcc/$(gcc -dumpmachine)/14.2.0/liblto_plugin.so \
/usr/lib/bfd-plugins/

### toolchain complete, sanity check ###############
echo "Sanity check"
echo 'int main(){}' > dummy.c
cc dummy.c -v -Wl,--verbose &> dummy.log
readelf -l a.out | grep ': /lib'
echo "output should read \"Requesting program interpreter: /lib64/ld-linux-x86-64.so.2\" "
echo "hit enter to contiue"
read -r
### checks for correct start files
grep -E -o '/usr/lib.*/S?crt[1in].*succeeded' dummy.log
echo "This output should read something like \"/usr/lib/gcc/x86_64-pc-linux-gnu/14.2.0/../../../../lib/Scrt1.o succeeded \" "
echo "Hit enter to continue"
read -r
###checks tha compiler looks for correct header files
grep -B4 '^ /usr/include' dummy.log
echo "This out put should read \"\#include <...> search starts here: \" "
echo "/usr/lib/gcc/x86_64-pc-linux-gnu/14.2.0/include"
echo "/usr/local/include"
echo "/usr/lib/gcc/x86_64-pc-linux-gnu/14.2.0/include-fixed"
echo "/usr/include"
echo "hit enter to contnue"
read -r
###checks linker uses correct search paths
grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g'
echo "This output should read as follows"
echo "SEARCH_DIR(\"/usr/x86_64-pc-linux-gnu/lib64\")"
echo "SEARCH_DIR(\"/usr/local/lib64\")"
echo "SEARCH_DIR(\"/lib64\")"
echo "SEARCH_DIR(\"/usr/lib64\")"
echo "SEARCH_DIR(\"/usr/x86_64-pc-linux-gnu/lib\")"
echo "SEARCH_DIR(\"/usr/local/lib\")"
echo "SEARCH_DIR(\"/lib\")"
echo "SEARCH_DIR(\"/usr/lib\");"
echo "Hit enter to continue"
read -r
#####checks for correct libc
grep "/lib.*/libc.so.6 " dummy.log
echo "This output should read as follows"
echo "attempt to open /usr/lib/libc.so.6 succeeded"
echo "Hit enter to continue"
read -r
####checks GCC is user correct dynamic linker
grep found dummy.log
echo "Output should read as follows"
echo "found ld-linux-x86-64.so.2 at /usr/lib/ld-linux-x86-64.so.2"
echo "Hit enter to continue"
read -r

rm -v dummy.c a.out dummy.log
mkdir -pv /usr/share/gdb/auto-load/usr/lib
mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib
cd ../..
rm -rf gcc-14.2.0
################# ncurses-6.5 ######################
tar -xzf ncurses-6.5.tar.gz
cd ncurses-6.5

./configure --prefix=/usr \
--mandir=/usr/share/man \
--with-shared \
--without-debug \
--without-normal \
--with-cxx-shared \
--enable-pc-files \
--with-pkg-config-libdir=/usr/lib/pkgconfig

make
make DESTDIR=$PWD/dest install
install -vm755 dest/usr/lib/libncursesw.so.6.5 /usr/lib
rm -v dest/usr/lib/libncursesw.so.6.5
sed -e 's/^#if.*XOPEN.*$/#if 1/' \
-i dest/usr/include/curses.h
cp -av dest/* /

for lib in ncurses form panel menu; do
ln -sfv lib${lib}w.so /usr/lib/lib${lib}.so
ln -sfv ${lib}w.pc
 /usr/lib/pkgconfig/${lib}.pc
done

ln -sfv libncursesw.so /usr/lib/libcurses.so
cp -v -R doc -T /usr/share/doc/ncurses-6.5

cd ..
rm -rf ncurses-6.5
echo "Finished ncurses starting sed, hit enter to continue"
read -r
################### sed-4.9 ###################
tar -xf sed-4.9.tar.xz
cd sed-4.9

./configure --prefix=/usr
make
make html

chown -R tester .
su tester -c "PATH=$PATH make check"
make install
install -d -m755 /usr/share/doc/sed-4.9
install -m644 doc/sed.html /usr/share/doc/sed-4.9

cd ..
rm -rf sed-4.9
############## psmisc-23.7 ##############
tar -xf psmisc-23.7.tar.xz
cd   psmisc-23.7

./configure --prefix=/usr
make
make check
make install
cd ..
rm -rf psmisc-23.7
#################### gettext-0.22.5####################
tar -xf gettext-0.22.5.tar.xz
cd gettext-0.22.5

./configure --prefix=/usr \
--disable-static \
--docdir=/usr/share/doc/gettext-0.22.5

make
make check
make install
chmod -v 0755 /usr/lib/preloadable_libintl.so
cd ..
rm -rf gettext-0.22.5
#################### bison-3.8.2 #################
tar -xf bison-3.8.2.tar.xz
cd bison-3.8.2

./configure --prefix=/usr --docdir=/usr/share/doc/bison-3.8.2
make
make check
make install
cd ..
rm -rf bison-3.8.2
################ grep-3.11 ####################
tar -xf grep-3.11.tar.xz
cd grep-3.11

sed -i "s/echo/#echo/" src/egrep.sh
./configure --prefix=/usr
make
make check
make install
cd ..
rm -rf grep-3.11
########### bash-5.2.32 ###########
echo "about to install bash, hit enter"
read -r
tar -xzf bash-5.2.32.tar.gz
cd bash-5.2.32

./configure --prefix=/usr \
--without-bash-malloc \
--with-installed-readline \
bash_cv_strtold_broken=no \
--docdir=/usr/share/doc/bash-5.2.32

make
echo "just performed MAKE, hit enter"
read -r
chown -R tester .

su -s /usr/bin/expect tester << "EOF"
set timeout -1
spawn make tests
expect eof
lassign [wait] _ _ _ value
exit $value
EOF

make install
exec /usr/bin/bash --login
