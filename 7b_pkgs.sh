#!/bin/bash
cd /sources
rm -rf bash-5.2.32

################## libtool-2.4.7 #############################
tar -xf libtool-2.4.7.tar.xz
cd libtool-2.4.7

./configure --prefix=/usr
make
make -k check
make install
rm -fv /usr/lib/libltdl.a
cd /sources
rm -rf libtool-2.4.7
################ gdbm-1.24 ######################################
tar -xzf gdbm-1.24.tar.gz
cd gdbm-1.24

./configure --prefix=/usr \
--disable-static \
--enable-libgdbm-compat

make
make check
make install

cd /sources
rm -rf gdbm-1.24
################# gperf-3.1 ######################
tar -xzf gperf-3.1.tar.gz
cd gperf-3.1

./configure --prefix=/usr --docdir=/usr/share/doc/gperf-3.1
make
make -j1 check
make install
cd /sources
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
cd /sources
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
cd /sources
rm -rf inetutils-2.5
################### less-661 ##################
tar -xzf less-661.tar.gz
cd less-661

./configure --prefix=/usr --sysconfdir=/etc
make
make check
make install
cd /sources
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
cd /sources
rm -rf perl-5.40.0
################## xml parser-2.47 ########
tar -xzf XML-Parser-2.47.tar.gz
cd XML-Parser-2.47

perl Makefile.PL
make
make test
make install
cd /sources
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
cd /sources
rm -rf intltool-0.51.0
################# autoconf-2.72 ##################
tar -xf autoconf-2.72.tar.xz
cd autoconf-2.72

./configure --prefix=/usr
make
make check
make install
cd /sources
rm -rf autoconf-2.72
################# automake 1.17 ######################
tar -xf automake-1.17.tar.xz 
cd automake-1.17

./configure --prefix=/usr --docdir=/usr/share/doc/automake-1.17
make
make -j$(($(nproc)>4?$(nproc):4)) check
make install
cd /sources
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
cd /sources
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

cd /sources
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

cd /sources
rm -rf elfutils-0.191
################### libffi-3.4.6 #########################
tar -xzf   libffi-3.4.6.tar.gz 
cd   libffi-3.4.6

./configure --prefix=/usr \
--disable-static \
--with-gcc-arch=native

make
make check
make install
cd /sources
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

cd /sources
rm -rf Python-3.12.5
########### flit-core-3.9.0 ######################
tar -xzf flit_core-3.9.0.tar.gz 
cd flit_core-3.9.0

pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
pip3 install --no-index --no-user --find-links dist flit_core

cd /sources
rm -rf flit_core-3.9.0
################### wheel - 0.44.0 ###################
tar -xzf wheel-0.44.0.tar.gz
cd wheel-0.44.0

pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
pip3 install --no-index --find-links=dist wheel

cd /sources
rm -rf wheel-0.44.0
################## setuptools-72.2.0 ##########################
tar -xzf setuptools-72.2.0.tar.gz
cd setuptools-72.2.0

pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
pip3 install --no-index --find-links dist setuptools

cd /sources
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

cd /sources
rm -rf ninja-1.12.1
####################### meson-1.5.1 ####################################
tar -xzf meson-1.5.1.tar.gz
cd meson-1.5.1

pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
pip3 install --no-index --find-links dist meson
install -vDm644 data/shell-completions/bash/meson /usr/share/bash-completion/completions/meson
install -vDm644 data/shell-completions/zsh/_meson /usr/share/zsh/site-functions/_meson

cd /sources
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

cd /sources
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
cd /sources
rm -rf acl-2.3.2
###################### check -0.15.2##################
tar -xzf check-0.15.2.tar.gz
cd check-0.15.2

./configure --prefix=/usr --disable-static
make
make check
make docdir=/usr/share/doc/check-0.15.2 install

cd /sources
rm -rf check-0.15.2
######################### diffutils-3.10 ######################
tar -xf diffutils-3.10.tar.xz
cd diffutils-3.10

./configure --prefix=/usr
make
make check
make install
cd /sources
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

cd /sources
rm -rf gawk-5.3.0
######################## findutils-4.10.0 ##################
tar -xf findutils-4.10.0.tar.xz  
cd findutils-4.10.0

./configure --prefix=/usr --localstatedir=/var/lib/locate
make
chown -R tester .
su tester -c "PATH=$PATH make check"
make install

cd /sources
rm -rf findutils-4.10.0
################### groff-1.23.0 #######################
tar -xzf groff-1.23.0.tar.gz
cd groff-1.23.0

PAGE=letter ./configure --prefix=/usr
make
make check
make install
cd /sources
rm -rf groff-1.23.0
################# grub-2.12 FOR UEFI ######################################
#### start with dependencies
#mkdir blfs   ###### may be unnecessary to create this directory
#cd blfs   ###### may be unnecessary to create this directory

####freetype ######

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
cd /sources
rm -rf freetype-2.13.3
############## popt for efi bootlader #################
tar -xzf popt-1.19.tar.gz
cd popt-1.19

./configure --prefix=/usr --disable-static &&

make
make check
make install
cd /sources
rm -rf popt-1.19
###################mandoc-1.14.6 ################################
tar -xzf mandoc-1.14.6.tar.gz
cd mandoc-1.14.6

./configure &&

make mandoc
make regress
echo "check test, hit enter to continue"
read -r

install -vm755 mandoc   /usr/bin &&
install -vm644 mandoc.1 /usr/share/man/man1
cd /sources
rm -rf mandoc-1.14.6
################ efivar-39 ##############
tar -xzf efivar-39.tar.gz
cd efivar-39
make
make install LIBDIR=/usr/lib
cd /sources
rm -rf efivar-39
######### efibootmgr-18 #############################################
tar -xzf efibootmgr-18.tar.gz
cd efibootmgr-18

make EFIDIR=LFS EFI_LOADER=grubx64.efi
mkdir /boot
mkdir /boot/efi/EFI
mount /dev/nvme0n1p2 /boot
mount /dev/nvme0n1p1 /boot/efi/EFI
make install EFIDIR=LFS
cd /sources
rm -rf efibootmgr-18
#################### grub 2.12 ########################
tar -xf grub-2.12.tar.xz  ### was ../grub-2.12.tar.xz
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
cd /sources
rm -rf grub-2.12
############### end of Grub for UEFI ####
################## gzip 1.13 ######################
tar -xf gzip-1.13.tar.xz 
cd gzip-1.13

./configure --prefix=/usr

make
make check
make install
cd /sources
rm -rf gzip-1.13
#################################iproute2-6.10.0######################
tar -xf iproute2-6.10.0.tar.xz
cd iproute2-6.10.0

sed -i /ARPD/d Makefile
rm -fv man/man8/arpd.8
make NETNS_RUN_DIR=/run/netns
make SBINDIR=/usr/sbin install
mkdir -pv /usr/share/doc/iproute2-6.10.0
cp -v COPYING README* /usr/share/doc/iproute2-6.10.0
cd ..
rm -rf iproute2-6.10.0
######################kbd 2.6.4 ###############################
tar -xf kbd-2.6.4.tar.xz
cd kbd-2.6.4

patch -Np1 -i ../kbd-2.6.4-backspace-1.patch
sed -i '/RESIZECONS_PROGS=/s/yes/no/' configure
sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in

./configure --prefix=/usr --disable-vlock

make
make check
make install
cp -R -v docs/doc -T /usr/share/doc/kbd-2.6.4
cd ..
rm -rf kbd-2.6.4
##########libpipeline-1.5.7#################################
tar -xzf libpipeline-1.5.7.tar.gz
cd libpipeline-1.5.7

./configure --prefix=/usr
make
make check
make install
cd /sources
rm -rf libpipeline-1.5.7
############ make 4.4.1 ##############################
tar -xzf make-4.4.1.tar.gz
cd make-4.4.1

./configure --prefix=/usr
make
chown -R tester .
su tester -c "PATH=$PATH make check"
make install
cd /sources
rm -rf make-4.4.1
##############patch-2.7.6 ##########################################
tar -xf patch-2.7.6.tar.xz
cd patch-2.7.6
./configure --prefix=/usr
make
make check
make install
cd /sources
rm -rf patch-2.7.6
################# tar 1.35 ##########################################
tar -xf tar-1.35.tar.xz
cd tar-1.35

FORCE_UNSAFE_CONFIGURE=1 \
./configure --prefix=/usr

make
make check
make install
make -C doc install-html docdir=/usr/share/doc/tar-1.35
cd /sources
rm -rf tar-1.35
#####################texinfo 7.1#########################
tar -xf texinfo-7.1.tar.xz
cd texinfo-7.1

./configure --prefix=/usr

make
make check
make install
make TEXMF=/usr/share/texmf install-tex
cd /sources
rm -rf texinfo-7.1
################# vim ########################################
tar -xzf vim-9.1.0660.tar.gz
cd vim-9.1.0660

echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h
./configure --prefix=/usr

make
chown -R tester .
su tester -c "TERM=xterm-256color LANG=en_US.UTF-8 make -j1 test" \
&> vim-test.log
make install

ln -sv vim /usr/bin/vi
for L in /usr/share/man/{,*/}man1/vim.1; do
ln -sv vim.1 $(dirname $L)/vi.1
done

ln -sv ../vim/vim91/doc /usr/share/doc/vim-9.1.0660

cat > /etc/vimrc << "EOF"
" Begin /etc/vimrc
" Ensure defaults are set before customizing settings, not after
source $VIMRUNTIME/defaults.vim
let skip_defaults_vim=1

set nocompatible
set backspace=2
set mouse=
syntax on
if (&term == "xterm") || (&term == "putty")
set background=dark
endif

" End /etc/vimrc
EOF

vim -c ':options'
cd /sources
rm -rf vim-9.1.0660
######### markupsafe-2.1.5 ########################
tar -xzf MarkupSafe-2.1.5.tar.gz
cd MarkupSafe-2.1.5

pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
pip3 install --no-index --no-user --find-links dist Markupsafe

cd /sources
rm -rf MarkupSafe-2.1.5
####################jinja2-3.1.4########################
tar -xzf jinja2-3.1.4.tar.gz
cd jinja2-3.1.4

pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
pip3 install --no-index --no-user --find-links dist Jinja2

cd /sources
rm -rf jinja-3.1.4
################# udev from systemd-256.4 ##################
tar -xzf systemd-256.4.tar.gz
cd systemd-256.4

sed -i -e 's/GROUP="render"/GROUP="video"/' \
-e 's/GROUP="sgx", //' rules.d/50-udev-default.rules.in

sed '/systemd-sysctl/s/^/#/' -i rules.d/99-systemd.rules.in

sed '/NETWORK_DIRS/s/systemd/udev/' -i src/basic/path-lookup.h

mkdir -p build
cd build
meson setup .. \
--prefix=/usr \
--buildtype=release \
-D mode=release \
-D dev-kvm-mode=0660 \
-D link-udev-shared=false \
-D logind=false \
-D vconsole=false

export udev_helpers=$(grep "'name' :" ../src/udev/meson.build | \
awk '{print $3}' | tr -d ",'" | grep -v 'udevadm')

ninja udevadm systemd-hwdb \
$(ninja -n | grep -Eo '(src/(lib)?udev|rules.d|hwdb.d)/[^ ]*') \
$(realpath libudev.so --relative-to .) \
$udev_helpers

install -vm755 -d {/usr/lib,/etc}/udev/{hwdb.d,rules.d,network}
install -vm755 -d /usr/{lib,share}/pkgconfig
install -vm755 udevadm /usr/bin/
install -vm755 systemd-hwdb /usr/bin/udev-hwdb
ln -svfn ../bin/udevadm /usr/sbin/udevd
cp -av libudev.so{,*[0-9]} /usr/lib/
install -vm644 ../src/libudev/libudev.h /usr/include/
install -vm644 src/libudev/*.pc /usr/lib/pkgconfig/
install -vm644 src/udev/*.pc /usr/share/pkgconfig/
install -vm644 ../src/udev/udev.conf /etc/udev/
install -vm644 rules.d/* ../rules.d/README /usr/lib/udev/rules.d/
install -vm644 $(find ../rules.d/*.rules \
-not -name '*power-switch*') /usr/lib/udev/rules.d/
install -vm644 hwdb.d/* ../hwdb.d/{*.hwdb,README} /usr/lib/udev/hwdb.d/
install -vm755 $udev_helpers /usr/lib/udev
install -vm644 ../network/99-default.link /usr/lib/udev/network

tar -xvf ../../udev-lfs-20230818.tar.xz 
make -f udev-lfs-20230818/Makefile.lfs install
tar -xf ../../systemd-man-pages-256.4.tar.xz \
--no-same-owner --strip-components=1 \
-C /usr/share/man --wildcards '*/udev*' '*/libudev*' \
'*/systemd.link.5' \
'*/systemd-'{hwdb,udevd.service}.8

sed 's|systemd/network|udev/network|' \
/usr/share/man/man5/systemd.link.5 \
> /usr/share/man/man5/udev.link.5

sed 's/systemd\(\\\?-\)/udev\1/' /usr/share/man/man8/systemd-hwdb.8 \
> /usr/share/man/man8/udev-hwdb.8

sed 's|lib.*udevd|sbin/udevd|' \
/usr/share/man/man8/systemd-udevd.service.8 \
> /usr/share/man/man8/udevd.8

rm /usr/share/man/man*/systemd*
unset udev_helpers
udev-hwdb update

cd /sources
rm -rf systemd-256.4
################### man db 2.12.1 ###########################
tar -xf man-db-2.12.1.tar.xz
cd man-db-2.12.1

./configure --prefix=/usr \
--docdir=/usr/share/doc/man-db-2.12.1 \
--sysconfdir=/etc \
--disable-setuid \
--enable-cache-owner=bin \
--with-browser=/usr/bin/lynx \
--with-vgrind=/usr/bin/vgrind \
--with-grap=/usr/bin/grap \
--with-systemdtmpfilesdir= \
--with-systemdsystemunitdir=

make
make check
make install
cd /sources
rm -rf man-db-2.12.1
########################## procps ng 4.0.4 ######################
tar -xf procps-ng-4.0.4.tar.xz
cd  procps-ng-4.0.4

./configure --prefix=/usr \
--docdir=/usr/share/doc/procps-ng-4.0.4 \
--disable-static \
--disable-kill

make 
chown -R tester .
su tester -c "PATH=$PATH make check"
make install
cd /sources
rm -rf procps-ng-4.0.4
#################################util linux 2.40.2 ############
tar -xf util-linux-2.40.2.tar.xz
cd util-linux-2.40.2

./configure --bindir=/usr/bin \
--libdir=/usr/lib \
--runstatedir=/run \
--sbindir=/usr/sbin \
--disable-chfn-chsh \
--disable-login \
--disable-nologin \
--disable-su \
--disable-setpriv \
--disable-runuser \
--disable-pylibmount \
--disable-liblastlog2 \
--disable-static \
--without-python \
--without-systemd \
--without-systemdsystemunitdir \
ADJTIME_PATH=/var/lib/hwclock/adjtime \
--docdir=/usr/share/doc/util-linux-2.40.2

make
echo "running test"
touch /etc/fstab
chown -R tester .
su tester -c "make -k check"
echo "check test and hit enter"
read -r
make install
cd /sources
rm -rf util-linux-2.40.2
################## E2fsprogs 1.47.1 ##################################
tar -xzf e2fsprogs-1.47.1.tar.gz
cd e2fsprogs-1.47.1

mkdir -v build
cd build

../configure --prefix=/usr \
--sysconfdir=/etc \
--enable-elf-shlibs \
--disable-libblkid \
--disable-libuuid \
--disable-uuidd \
--disable-fsck

make
make check
make install
rm -fv /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a
gunzip -v /usr/share/info/libext2fs.info.gz
install-info --dir-file=/usr/share/info/dir /usr/share/info/libext2fs.info
makeinfo -o
 doc/com_err.info ../lib/et/com_err.texinfo
install -v -m644 doc/com_err.info /usr/share/info
install-info --dir-file=/usr/share/info/dir /usr/share/info/com_err.info

cd /sources
rm -rf e2fsprogs-1.47.1
################## sysklogd-2.6.1 #############################
tar -xzf sysklogd-2.6.1.tar.gz
cd sysklogd-2.6.1

./configure --prefix=/usr
 \
--sysconfdir=/etc \
--runstatedir=/run \
--without-logger

make
make install

cat > /etc/syslog.conf << "EOF"
# Begin /etc/syslog.conf
auth,authpriv.* -/var/log/auth.log
*.*;auth,authpriv.none -/var/log/sys.log
daemon.* -/var/log/daemon.log
kern.* -/var/log/kern.log
mail.* -/var/log/mail.log
user.* -/var/log/user.log
*.emerg *
# Do not open any internet ports.
secure_mode 2
# End /etc/syslog.conf
EOF

cd /sources
rm -rf sysklogd-2.6.1
#################### sysvinit 3.10 ##############################
tar -xf sysvinit-3.10.tar.xz
cd sysvinit-3.10

patch -Np1 -i ../sysvinit-3.10-consolidated-1.patch
make
make install
cd /sources
rm -rf sysvinit-3.10
############### cleaning up ##########################
rm -rf /tmp/{*,.*}
find /usr/lib /usr/libexec -name \*.la -delete
find /usr -depth -name $(uname -m)-lfs-linux-gnu\* | xargs rm -rf
userdel -r tester

