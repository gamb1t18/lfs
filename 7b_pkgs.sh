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
8.46




