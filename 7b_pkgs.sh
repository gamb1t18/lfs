#!/bin/bash
cd ..
rm -rf bash-5.2.32

################## libtools-2.4.7 #############################
tar -xf libtools-2.4.7.tar.xz
cd libtools-2.4.7

./configure --prefix=/usr
make
make -k check
make install
rm -fv /usr/lib/libltdl.a
cd ..
rm -rf libtools-2.4.7
################ gdbm-1.2.4 ######################################
tar -xf gdbm-1.2.4-tar.xz
cd gdbm-1.2.4

./configure --prefix=/usr \
--disable-static \
--enable-libgdbm-compat

make
make check
make install

cd ..
rm -rf gdbm-1.2.4
################# gperf-3.1 ######################
tar -xf gperf-3.1.tar.xz
cd gperf-3.1

./configure --prefix=/usr --docdir=/usr/share/doc/gperf-3.1
make
make -j1 check
make install
cd ..
rm -rf gperf-3.1
################ expat-2.6.2 ###################
tar -xf expat-2.6.2.tar.xz
cd expat-2.6.2

./configure --prefix=/usr \
--disable-static \
--docdir=/usr/share/doc/expat-2.6.2

make
make check
make install
install -v -m644 doc/*.{html,css} /usr/share/doc/expat-2.6.2
cd ..
rm -rf expat-2.6.2
######################## inetutils-2.5 ########
tar -xf inetutils-2.5.tar.xz
cd inetutils-2.5

sed -i 's/def HAVE_TERMCAP_TGETENT/ 1/' telnet/telnet.c
./configure --prefix=/usr \
--bindir=/usr/bin \
--localstatedir=/var \
--disable-logger \
--disable-whois \
--disable-rcp \
--disable-rexec \
--disable-rlogin \
--disable-rsh \
--disable-servers

make
make check
make install
mv -v /usr/{,s}bin/ifconfig
cd ..
rm -rf inetutils-2.5
################### less-661 ##################
tar -xzf less-661.tar.gz
cd less-661

./configure --prefix=/usr --sysconfdir=/etc
make
make check
make install
cd ..
rm -rf less-661
################## perl-5.40.0 ####################
tar -xf perl-5.40.0.tar.xz
cd perl-5.40.0

export BUILD_ZLIB=False
export BUILD_BZIP2=0

sh Configure -des \
-D prefix=/usr \
-D vendorprefix=/usr \
-D privlib=/usr/lib/perl5/5.40/core_perl \
-D archlib=/usr/lib/perl5/5.40/core_perl \
-D sitelib=/usr/lib/perl5/5.40/site_perl \
-D sitearch=/usr/lib/perl5/5.40/site_perl \
-D vendorlib=/usr/lib/perl5/5.40/vendor_perl \
-D vendorarch=/usr/lib/perl5/5.40/vendor_perl \
-D man1dir=/usr/share/man/man1 \
-D man3dir=/usr/share/man/man3 \
-D pager="/usr/bin/less -isR" \
-D useshrplib \
-D usethreads

make
TEST_JOBS=$(nproc) make test_harness
make install
unset BUILD_ZLIB BUILD_BZIP2
cd ..
rm -rf perl-5.40.0
################## xml parser-2.47 ########
tar -xf XML-Parser-2.47.tar.gz
cd XML-Parser-2.47

perl Makefile.PL
make
make test
make install
cd ..
rm -rf XML-Parser-2.47
#################intitool-0.51.0 ##################
tar -xzf intltool-0.51.0.tar.gz
cd intltool-0.51.0

sed -i 's:\\\${:\\\$\\{:' intltool-update.in
./configure --prefix=/usr
make
make check
make install
install -v -Dm644 doc/I18N-HOWTO /usr/share/doc/intltool-0.51.0/I18N-HOWTO
cd ..
rm -rf intltool-0.51.0
################# autoconf-2.72 ##################
tar -xf autoconf-2.72.tar.xz
cd autoconf-2.72

./configure --prefix=/usr
make
make check
make install
cd ..
rm -rf autoconf-2.72
################# automake 1.17 ######################
tar -xf automake-1.17.tar.xz 
cd automake-1.17

./configure --prefix=/usr --docdir=/usr/share/doc/automake-1.17
make
make -j$(($(nproc)>4?$(nproc):4)) check
make install
cd ..
rm -rf automake-1.17
#################### openssl-33.3.1 ########################
tar -xzf openssl-3.3.1.tar.gz
cd openssl-3.3.1

./config --prefix=/usr \
--openssldir=/etc/ssl \
--libdir=lib \
shared \
zlib-dynamic

make
HARNESS_JOBS=$(nproc) make test
sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile
make MANSUFFIX=ssl install
mv -v /usr/share/doc/openssl /usr/share/doc/openssl-3.3.1
cp -vfr doc/* /usr/share/doc/openssl-3.3.1
cd ..
rm -rf openssl-3.3.1
################### kmod-33 ######################################
tar -xf kmod-33.tar.xz
cd kmod-33

./configure --prefix=/usr \
--sysconfdir=/etc \
--with-openssl \
--with-xz \
--with-zstd \
--with-zlib \
--disable-manpages

make
make install
for target in depmod insmod modinfo modprobe rmmod; do
ln -sfv ../bin/kmod /usr/sbin/$target
rm -fv /usr/bin/$target
done

cd ..
rm -rf kmod-33
################ libelf from elfutils-0.191 ##############
tar -xjf elfutils-0.191.tar.bz2 
cd elfutils-0.191

./configure --prefix=/usr \
--disable-debuginfod \
--enable-libdebuginfod=dummy

make
make check

make -C libelf install
install -vm644 config/libelf.pc /usr/lib/pkgconfig
rm /usr/lib/libelf.a

cd ..
rm -rf elfutils-0.191
################### libffi-3.4.6 #########################
tar -xf   libffi-3.4.6.tar.gz 
cd   libffi-3.4.6

./configure --prefix=/usr \
--disable-static \
--with-gcc-arch=native

make
make check
make install
cd ..
rm -rf libffi-3.4.6
############### python 3.12.5 ###########################
tar -xf Python-3.12.5.tar.xz
cd Python-3.12.5

./configure --prefix=/usr \
--enable-shared \
--with-system-expat \
--enable-optimizations

make
make test TESTOPTS="--timeout 120"
make install

cat > /etc/pip.conf << EOF
[global]
root-user-action = ignore
disable-pip-version-check = true
EOF

install -v -dm755 /usr/share/doc/python-3.12.5/html
tar --no-same-owner \
-xvf ../python-3.12.5-docs-html.tar.bz2
cp -R --no-preserve=mode python-3.12.5-docs-html/* \
/usr/share/doc/python-3.12.5/html

cd ..
rm -rf Python-3.12.5
########### flit-core-3.9.0 ######################
tar -xzf flit_core-3.9.0.tar.gz 
cd flit_core-3.9.0

pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
pip3 install --no-index --no-user --find-links dist flit_core

cd ..
rm -rf flit_core-3.9.0
################### wheel - 0.44.0 ###################
tar -xzf wheel-0.44.0.tar.gz
cd wheel-0.44.0

pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
pip3 install --no-index --find-links=dist wheel

cd ..
rm -rf wheel-0.44.0
################## setuptools-72.2.0 ##########################
tar -xzf setuptools-72.2.0.tar.gz
cd setuptools-72.2.0

pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
pip3 install --no-index --find-links dist setuptools

cd ..
rm -rf setuptools-72.2.0
###################### ninja-1.12.1 #############################
tar -xzf  ninja-1.12.1.tar.gz
cd  ninja-1.12.1
export NINJAJOBS=4

sed -i '/int Guess/a \
int j = 0;\
char* jobs = getenv( "NINJAJOBS" );\
if ( jobs != NULL ) j = atoi( jobs );\
if ( j > 0 ) return j;\
' src/ninja.cc

python3 configure.py --bootstrap
install -vm755 ninja /usr/bin/
install -vDm644 misc/bash-completion /usr/share/bash-completion/completions/ninja
install -vDm644 misc/zsh-completion /usr/share/zsh/site-functions/_ninja

cd ..
rm -rf ninja-1.12.1
####################### meson-1.5.1 ####################################
tar -xzf meson-1.5.1.tar.gz
cd meson-1.5.1

pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
pip3 install --no-index --find-links dist meson
install -vDm644 data/shell-completions/bash/meson /usr/share/bash-completion/completions/meson
install -vDm644 data/shell-completions/zsh/_meson /usr/share/zsh/site-functions/_meson

cd ..
rm -rf meson-1.5.1
################## coreutils-9.5 #########################
tar -xf coreutils-9.5.tar.xz  
cd coreutils-9.5  

patch -Np1 -i ../coreutils-9.5-i18n-2.patch

autoreconf -fiv
FORCE_UNSAFE_CONFIGURE=1 ./configure \
--prefix=/usr \
--enable-no-install-program=kill,uptime

make
make NON_ROOT_USERNAME=tester check-root
groupadd -g 102 dummy -U tester
chown -R tester .
su tester -c "PATH=$PATH make -k RUN_EXPENSIVE_TESTS=yes check" \
< /dev/null
groupdel dummy
make install
mv -v /usr/bin/chroot /usr/sbin
mv -v /usr/share/man/man1/chroot.1 /usr/share/man/man8/chroot.8
sed -i 's/"1"/"8"/' /usr/share/man/man8/chroot.8

cd ..
rm -rf coreutils-9.5
######### return to acl to install following coreutils install, due to dependencies ####
tar -xf acl-2.3.2.tar.xz
cd acl-2.3.2

./configure --prefix=/usr \
--disable-static \
--docdir=/usr/share/doc/acl-2.3.2

make
echo "about to run make check for tests, hit enter to continue"
read -r

make check
echo "tests run, check results, hit enter to continue"
read -r
make install
cd ..
rm -rf acl-2.3.2
###################### check -0.15.2##################
tar -xzf check-0.15.2.tar.gz
cd check-0.15.2

./configure --prefix=/usr --disable-static
make
make check
make docdir=/usr/share/doc/check-0.15.2 install

cd ..
rm -rf check-0.15.2
######################### diffutils-3.10 ######################
tar -xf diffutils-3.10.tar.xz
cd diffutils-3.10

./configure --prefix=/usr
make
make check
make install
cd ..
rm -rf diffutils-3.10
######################## gawk-5.3.0 ########################
tar -xf gawk-5.3.0.tar.xz
cd gawk-5.3.0

sed -i 's/extras//' Makefile.in
./configure --prefix=/usr
make
chown -R tester .
su tester -c "PATH=$PATH make check"
rm -f /usr/bin/gawk-5.3.0
make install
ln -sv gawk.1 /usr/share/man/man1/awk.1
mkdir -pv /usr/share/doc/gawk-5.3.0
cp -v doc/{awkforai.txt,*.{eps,pdf,jpg}} /usr/share/doc/gawk-5.3.0

cd ..
rm -rf gawk-5.3.0
######################## findutils-4.10.0 ##################
tar -xf findutils-4.10.0.tar.xz  
cd findutils-4.10.0

./configure --prefix=/usr --localstatedir=/var/lib/locate
make
chown -R tester .
su tester -c "PATH=$PATH make check"
make install

cd ..
rm -rf findutils-4.10.0
################### groff-1.23.0 #######################
tar -xzf groff-1.23.0.tar.gz
cd groff-1.23.0

PAGE=<paper_size> ./configure --prefix=/usr
make
make check
make install
cd ..
rm -rf groff-1.23.0
################# grub-2.12 FOR UEFI ######################################
#### start with dependencies
mkdir blfs
cd blfs

####freetype ######
wget https://downloads.sourceforge.net/freetype/freetype-2.13.3.tar.xz
wget https://downloads.sourceforge.net/freetype/freetype-doc-2.13.3.tar.xz
 
echo "checking md5sum"
md5sum *
echo "hit enter if md5sum is good"
read -r

tar -xf freetype-2.13.3.tar.xz
cd freetype-2.13.3
tar -xf ../freetype-doc-2.13.3.tar.xz --strip-components=2 -C docs
sed -ri "s:.*(AUX_MODULES.*valid):\1:" modules.cfg &&
sed -r "s:.*(#.*SUBPIXEL_RENDERING) .*:\1:" \
    -i include/freetype/config/ftoption.h  &&

./configure --prefix=/usr --enable-freetype-config --disable-static &&
make
make install
cp -v -R docs -T /usr/share/doc/freetype-2.13.3 &&
rm -v /usr/share/doc/freetype-2.13.3/freetype-config.1
cd ..
rm -rf freetype-2.13.3
############## popt for efi bootlader #################
wget http://ftp.rpm.org/popt/releases/popt-1.x/popt-1.19.tar.gz
md5sum popt-19.tar.gz
tar -xzf popt-1.19.tar.gz
cd popt-1.19

./configure --prefix=/usr --disable-static &&

make
make check
make install
cd ..
rm -rf popt-1.19
###################mandoc-1.14.6 ################################
wget https://mandoc.bsd.lv/snapshots/mandoc-1.14.6.tar.gz
md5sum mandoc-1.14.6.tar.gz
echo "Hit enter if md5sum is good: f0adf24e8fdef5f3e332191f653e422a"
read -r
tar -xzf mandoc-1.14.6.tar.gz
cd mandoc-1.14.6

./configure &&

make mandoc
make regress
echo "check test, hit enter to continue"
read -r

install -vm755 mandoc   /usr/bin &&
install -vm644 mandoc.1 /usr/share/man/man1
cd..
rm -rf mandoc-1.14.6
################ efivar-39 ##############
wget https://github.com/rhboot/efivar/archive/39/efivar-39.tar.gz
md5sum efivar-39.tar.gz
echo "Hit enter if md5sum is good : a8fc3e79336cd6e738ab44f9bc96a5aa "
read -r

tar -xzf efivar-39.tar.gz
cd efivar-39
make
make install LIBDIR=/usr/lib
cd ..
rm -rf efivar-39

######### efibootmgr-18 #################
wget https://github.com/rhboot/efibootmgr/archive/18/efibootmgr-18.tar.gz
md5sum efibootmgr-18.tar.gz
echo "hit enter if md5sum is good: e170147da25e1d5f72721ffc46fe4e06"
read -r
tar -xzf efibootmgr-18.tar.gz
cd efibootmgr-18

make EFIDIR=LFS EFI_LOADER=grubx64.efi
mkdir /boot/efi
mount /dev/nvme0n1p2 /boot
mount /dev/nvme0n1p1 /boot/efi
make install EFIDIR=LFS
cd ..
rm -rf efibootmgr-18
#################### grub 2.12 ########################
wget https://unifoundry.com/pub/unifont/unifont-15.1.05/font-builds/unifont-15.1.05.pcf.gz
md5sum *
echo "md5sum check: da47e9c7a2cec3b68a0fad5d2a341dcc"
echo "hit enter of 5d5sum is good: 60c564b1bdc39d8e43b3aab4bc0fb140"
read -r
tar -xf ../grub-2.12.tar.xz
cd grub-2.12
mkdir -pv /usr/share/fonts/unifont &&
gunzip -c ../unifont-15.1.05.pcf.gz > /usr/share/fonts/unifont/unifont.pcf
echo depends bli part_gpt > grub-core/extra_deps.lst
./configure --prefix=/usr        \
            --sysconfdir=/etc    \
            --disable-efiemu     \
            --enable-grub-mkfont \
            --with-platform=efi  \
            --target=x86_64      \
            --disable-werror     &&
unset TARGET_CC &&
make
make install &&
mv -v /etc/bash_completion.d/grub /usr/share/bash-completion/completions
cd ..
rm -rf grub-2.12





