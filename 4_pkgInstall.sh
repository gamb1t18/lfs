#!/bin/bash
export LFS=/mnt/lfs
######### to be done as lfs ##########################
if [ "$EUID" -eq 0 ]; then
    echo "This script must NOT be run as root. Please run it as user lfs."
    exit 1
fi
####### Begin package installations########

cd $LFS/sources

#### Binutils-2.43.1 ### Pass 1 ######################

echo "Compiling Binutils"
sleep 1

tar -xvf binutils-2.43.1.tar.xz
cd binutils-2.43.1

mkdir -v build
cd build

../configure --prefix=$LFS/tools \
--with-sysroot=$LFS \
--target=$LFS_TGT \
--disable-nls \
--enable-gprofng=no \
--disable-werror \
--enable-new-dtags \
--enable-default-hash-style=gnu

make
make install
cd ../..

rm -rf binutils-2.43.1 || echo "Failed to remove binutils-2.43.1"
echo "Binutils compiled"

###### GCC-14.2.0 ####    PASS 1    ###################
###requires GMP, MPFR, and MPC##################
echo "Compiling GCC now"
sleep 1

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

mkdir -v build
cd build

../configure \
--target=$LFS_TGT \
--prefix=$LFS/tools \
--with-glibc-version=2.40 \
--with-sysroot=$LFS \
--with-newlib \
--without-headers \
--enable-default-pie \
--enable-default-ssp \
--disable-nls \
--disable-shared \
--disable-multilib \
--disable-threads \
--disable-libatomic \
--disable-libgomp \
--disable-libquadmath \
--disable-libssp \
--disable-libvtv \
--disable-libstdcxx \
--enable-languages=c,c++

make
make install

cd ..
cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
`dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/include/limits.h

cd ..
rm -rf gcc-14.2.0 || echo "Failed to remove gcc-14.2.0"
rm -rf gmp-6.3.0
rm -rf mpfr-4.2.1
rm -rf mpc-1.3.1

echo "Finished compiling GCC"

######## Linux-6.10.5 API Headers ###########
echo "Compiling Linux Headers"
sleep 1

tar -xvf linux-6.10.5.tar.xz
cd linux-6.10.5

make mrproper

make headers
find usr/include -type f ! -name '*.h' -delete
cp -rv usr/include $LFS/usr

cd ..
rm -rf linux-6.10.5
echo "finished Linux API headers"

######## Glibc-2.40 ###################

echo "Compiling Glibc"
sleep 1

tar -xf glibc-2.40.tar.xz
cd glibc-2.40

case $(uname -m) in
i?86) ln -sfv ld-linux.so.2 $LFS/lib/ld-lsb.so.3
;;
x86_64) ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64
ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64/ld-lsb-x86-64.so.3
;;
esac

patch -Np1 -i ../glibc-2.40-fhs-1.patch

mkdir -v build
cd build

echo "rootsbindir=/usr/sbin" > configparms

../configure \
--prefix=/usr \
--host=$LFS_TGT \
--build=$(../scripts/config.guess) \
--enable-kernel=4.19 \
--with-headers=$LFS/usr/include \
--disable-nscd \
libc_cv_slibdir=/usr/lib

make -j1

make -j1 DESTDIR=$LFS install
sed '/RTLDLIST=/s@/usr@@g' -i $LFS/usr/bin/ldd


cd ../..

rm -rf glibc-2.40 || echo "Failed to remove glibc-2.40"

echo "Finished compiling GCC"


############ System Check / Sanity Check ######
### This is a check of the basic functions of compiling and linking ####

echo "Running a sanity check, testing basic functions of the new toolchaing"
cd $LFS/sources


echo 'int main (){}' | $LFS_TGT-gcc -xc -

readelf -l a.out | grep ld-linux


echo "Output should read /lib64/ld-linux-x86-64.so.2 or just ld-linux.so.2 for 32 bit machines"
echo "press enter to continue"
read -r
rm -v a.out

############## libstdc++ from GCC-14.2.0 #############

echo "Compiling libcstd++"
sleep 2

tar -xf gcc-14.2.0.tar.xz
cd gcc-14.2.0


mkdir -v build
cd build

../libstdc++-v3/configure \
--host=$LFS_TGT \
--build=$(../config.guess) \
--prefix=/usr \
--disable-multilib \
--disable-nls \
--disable-libstdcxx-pch \
--with-gxx-include-dir=/tools/$LFS_TGT/include/c++/14.2.0

make
make DESTDIR=$LFS install

rm -v $LFS/usr/lib/lib{stdc++{,exp,fs},supc++}.la

cd ../..
rm -rf gcc-14.2.0 || echo "Failed to remove gcc-14.2.0"

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



