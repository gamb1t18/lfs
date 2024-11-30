#!/bin/bash
export LFS=/mnt/lfs
######### to be done as lfs ##########################
if [ "$EUID" -eq 0 ]; then
    echo "This script must NOT be run as root. Please run it as a regular user."
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

rm -rf /binutils-2.43.1

echo "Binutils compiled, hit enter to continue"
read -r

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
rm -rf gcc-14.2.0
rm -rf gmp-6.3.0
rm -rf mpfr-4.2.1
rm -rf mpc-1.3.1

echo "Finished compiling GCC. Hit Enter to continue"
read -r

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
echo "finished Linux API headers. Hit enter to continue"
read -r

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

rm -rf glib-2.40

echo "Finished compiling GCC. Hit enter to continue"
read -r


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
rm -rf gcc14.2.0

