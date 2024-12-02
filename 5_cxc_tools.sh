#!/bin/bash
export LFS=/mnt/lfs

##################### must be done as lfs ###########33
if [ "$EUID" -eq 0 ]; then
    echo "This script must NOT be run as root. Please run it as user lfs."
    exit 1
fi


cd $LFS/sources

##### M4 #############################################

tar -xf m4-1.4.19.tar.xz
cd m4-1.4.19
 
./configure --prefix=/usr \
--host=$LFS_TGT \
--build=$(build-aux/config.guess)
 
make
make DESTDIR=$LFS install
 
cd ..
 
rm -rf m4-1.4.19

########## ncurses #####################################

tar -xzf ncurses-6.5.tar.gz
cd ncurses-6.5

sed -i s/mawk// configure

#builds tic program

mkdir build
pushd build
../configure
make -C include
make -C progs tic
popd

./configure --prefix=/usr \
--host=$LFS_TGT \
--build=$(./config.guess) \
--mandir=/usr/share/man \
--with-manpage-format=normal \
--with-shared \
--without-normal \
--with-cxx-shared \
--without-debug \
--without-ada \
--disable-stripping

make

make DESTDIR=$LFS TIC_PATH=$(pwd)/build/progs/tic install
ln -sv libncursesw.so $LFS/usr/lib/libncurses.so
sed -e 's/^#if.*XOPEN.*$/#if 1/' \
-i $LFS/usr/include/curses.h

cd ..

rm -rf ncurses-6.5

##### bash   ###########################################

tar -xzf bash-5.2.32.tar.gz
cd bash-5.2.32

./configure --prefix=/usr \
--build=$(sh support/config.guess) \
--host=$LFS_TGT \
--without-bash-malloc \
bash_cv_strtold_broken=no

make

make DESTDIR=$LFS install

ln -sv bash $LFS/bin/sh
 
cd ..
 
rm -rf bash-5.2.32

###### coreutils #############################

tar -xf coreutils-9.5.tar.xz
cd coreutils-9.5

./configure --prefix=/usr \
--host=$LFS_TGT \
--build=$(build-aux/config.guess) \
--enable-install-program=hostname \
--enable-no-install-program=kill,uptime

make
make DESTDIR=$LFS install

mv -v $LFS/usr/bin/chroot $LFS/usr/sbin
mkdir -pv $LFS/usr/share/man/man8
mv -v $LFS/usr/share/man/man1/chroot.1 $LFS/usr/share/man/man8/chroot.8
sed -i 's/"1"/"8"/' $LFS/usr/share/man/man8/chroot.8

cd ..
rm -rf coreutils-9.5

####### diffutils ##################################

tar -xf diffutils-3.10.tar.xz
cd diffutils-3.10

./configure --prefix=/usr \
--host=$LFS_TGT \
--build=$(./build-aux/config.guess)

make

make DESTDIR=$LFS install

cd ..
rm -rf diffutils-3.10

############ file #########################################

tar -xzf file-5.45.tar.gz
cd file-5.45

mkdir build
pushd build
../configure --disable-bzlib \
--disable-libseccomp \
--disable-xzlib \
--disable-zlib
make
popd

./configure --prefix=/usr --host=$LFS_TGT --build=$(./config.guess)

make FILE_COMPILE=$(pwd)/build/src/file
make DESTDIR=$LFS install

rm -v $LFS/usr/lib/libmagic.la

cd ..
rm -rf file-5.45

########## findutils #######################################

tar -xf findutils-4.10.0.tar.xz
cd findutils-4.10.0

./configure --prefix=/usr \
--localstatedir=/var/lib/locate \
--host=$LFS_TGT \
--build=$(build-aux/config.guess)

make
make DESTDIR=$LFS install

cd ..

rm -rf findutils-4.10.0

########## gawk ###########################################

tar -xf gawk-5.3.0.tar.xz
cd gawk-5.3.0

sed -i 's/extras//' Makefile.in

./configure --prefix=/usr \
--host=$LFS_TGT \
--build=$(build-aux/config.guess)

make
make DESTDIR=$LFS install

cd ..
rm -rf gawk-5.3.0

############### grep ##################################

tar -xf grep-3.11.tar.xz
cd grep-3.11

./configure --prefix=/usr \
--host=$LFS_TGT \
--build=$(./build-aux/config.guess)

make 
make DESTDIR=$LFS install

cd ..
rm -rf grep-3.11

############### gzip #########################################

tar -xf gzip-1.13.tar.xz
cd gzip-1.13

./configure --prefix=/usr --host=$LFS_TGT

make
make DESTDIR=$LFS install

cd ..
rm -rf gzip-1.13

################### make #####################################

tar -xzf make-4.4.1.tar.gz
cd make-4.4.1

./configure --prefix=/usr \
--without-guile \
--host=$LFS_TGT \
--build=$(build-aux/config.guess)

make
make DESTDIR=$LFS install

cd ..
rm -rf make-4.4.1

################# patch #######################################

tar -xf patch-2.7.6.tar.xz
cd patch-2.7.6

./configure --prefix=/usr \
--host=$LFS_TGT \
--build=$(build-aux/config.guess)

make
make DESTDIR=$LFS install

cd ..
rm -rf patch-2.7.6

################ sed #############################################

tar -xf sed-4.9.tar.xz
cd sed-4.9

./configure --prefix=/usr \
--host=$LFS_TGT \
--build=$(./build-aux/config.guess)

make
make DESTDIR=$LFS install

cd ..
rm -rf sed-4.9

###################### tar ####################################

tar -xf tar-1.35.tar.xz
cd tar-1.35

./configure --prefix=/usr \
--host=$LFS_TGT \
--build=$(build-aux/config.guess)

make
make DESTDIR=$LFS install

cd ..
rm -rf tar-1.35

###################### xz ##################################

tar -xf xz-5.6.2.tar.xz
cd xz-5.6.2

./configure --prefix=/usr \
--host=$LFS_TGT \
--build=$(build-aux/config.guess) \
--disable-static \
--docdir=/usr/share/doc/xz-5.6.2

make
make DESTDIR=$LFS install

rm -v $LFS/usr/lib/liblzma.la

cd ..
rm -rf xz-5.6.2

################################################################
#### binutils ## 2nd PASS  #####################################

tar -xf binutils-2.43.1.tar.xz
cd binutils-2.43.1

sed '6009s/$add_dr//' -i ltmain.sh

mkdir -v build
cd build

../configure \
--prefix=/usr \
--build=$(../config.guess) \
--host=$LFS_TGT \
--disable-nls \
--enable-shared \
--enable-gprofng=no \
--disable-werror \
--enable-64-bit-bfd \
--enable-new-dtags \
--enable-default-hash-style=gnu

make
make DESTDIR=$LFS install

rm -v $LFS/usr/lib/lib{bfd,ctf,ctf-nobfd,opcodes,sframe}.{a.la}

cd ../..

rm -rf binutils-2.43.1

#####################  GCC  ##   2nd PASS   ######################

tar -xf gcc-14.2.0.tar.xz
cd gcc-14.2.0
tar -xf ../mpfr-4.2.1.tar.xz
mv -v mpfr-4.2.1 mpfr
tar -xf ../gmp-6.3.0.tar.xz
mv -v gmp-6.3.0 gmp
tar -xf ../mpc-1.3.1.tar.gz
mv -v mpc-1.3.1 mpc

case $(uname -m) in
x86_64)
sed -e '/m64=/s/lib64/lib/' \
-i.orig gcc/config/i386/t-linux64
;;
esac

sed '/thread_header =/s/@.*@/gthr-posix.h/' \
-i libgcc/Makefile.in libstdc++-v3/include/Makefile.in

mkdir build
cd build

../configure \
--build=$(../config.guess) \
--host=$LFS_TGT \
--target=$LFS_TGT \
LDFLAGS_FOR_TARGET=-L$PWD/$LFS_TGT/libgcc \
--prefix=/usr \
--with-build-sysroot=$LFS \
--enable-default-pie \
--enable-default-ssp \
--disable-nls \
--disable-multilib \
--disable-libatomic \
--disable-libgomp \
--disable-libquadmath \
--disable-libsanitizer \
--disable-libssp \
--disable-libvtv \
--enable-languages=c,c++

make
make DESTDIR=$LFS install

ln -sv gcc $LFS/usr/bin/cc

cd ../..
rm -rf gcc-14.2.0

exit 0
