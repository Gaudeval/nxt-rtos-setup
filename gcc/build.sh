#!/bin/bash
# Written by Uwe Hermann <uwe@hermann-uwe.de>, released as public domain.
# Modified by Piotr Esden-Tempski <piotr@esden.net>, released as public domain.

#
# Requirements (example is for Debian, replace package names as needed):
#
# apt-get install flex bison libgmp3-dev libmpfr-dev libncurses5-dev \
# libmpc-dev autoconf texinfo build-essential
#
# Or on Ubuntu Maverick give `apt-get build-dep gcc-4.5` a try.
#

# Stop if any command fails
set -e

##############################################################################
# Settings section
# You probably want to customize those
##############################################################################
TARGET=arm-elf		# Or: TARGET=arm-elf
PREFIX=$(pwd)/install	# Install location of your final toolchain
DEPS_PREFIX=$(pwd)/lib_install

# Set to 1 to be quieter while running
QUIET=0

##############################################################################
# Version and download url settings section
##############################################################################
GCCVERSION=4.5.1
GCC=gcc-${GCCVERSION}
GCCURL=http://ftp.gnu.org/gnu/gcc/${GCC}/${GCC}.tar.gz

BINUTILS=binutils-2.20
NEWLIB=newlib-1.18.0
GDB=gdb-7.2

GMP=gmp-5.0.1
MPFR=mpfr-3.0.0
MPC=mpc-0.8.2

LIBELF=libelf-0.8.13

##############################################################################
# Flags section
##############################################################################

CPUS=$(getconf _NPROCESSORS_ONLN)
PARALLEL=-j$((CPUS + 1))
echo "${CPUS} cpu's detected running make with '${PARALLEL}' flag"

GDBFLAGS=
BINUTILFLAGS=

GCCFLAGS=

MAKEFLAGS=${PARALLEL}
TARFLAGS=v

if [ ${QUIET} != 0 ]; then
    TARFLAGS=
    MAKEFLAGS="${MAKEFLAGS} -s"
fi

SUMMON_DIR=$(pwd)
SOURCES=${SUMMON_DIR}/sources
STAMPS=${SUMMON_DIR}/stamps

export PATH="${PREFIX}/bin:${PATH}"
export LD_LIBRARY_PATH="${DEPS_PREFIX}/lib:${PREFIX}/lib:${LD_LIBRARY_PATH}"
export LD_RUN_PATH="${DEPS_PREFIX}/lib:${PREFIX}/lib:${LD_RUN_PATH}"

export LD_FLAGS="${LD_FLAGS} -static"
export LD_FLAGS="${LD_FLAGS} -L${DEPS_PREFIX} -L${PREFIX}/lib"


##############################################################################
# Tool section
##############################################################################
TAR=tar

##############################################################################
# OS and Tooldetection section
# Detects which tools and flags to use
##############################################################################

case "$(uname)" in
	Linux)
	echo "Found Linux OS."
	;;
	Darwin)
	echo "Found Darwin OS."
	#exit 0
	;;
	*)
	echo "Found unknown OS. Aborting!"
	exit 1
	;;
esac

##############################################################################
# Building section
# You probably don't have to touch anything after this
##############################################################################

# Fetch a versioned file from a URL
function fetch {
    if [ ! -e ${STAMPS}/$1.fetch ]; then
        log "Downloading $1 sources..."
        wget -c  $2
        touch ${STAMPS}/$1.fetch
    fi
}

# Log a message out to the console
function log {
    echo "******************************************************************"
    echo "* $*"
    echo "******************************************************************"
}

# Unpack an archive
function unpack {
    log Unpacking $*
    # Use 'auto' mode decompression.  Replace with a switch if tar doesn't support -a
    ARCHIVE=$(ls ${SOURCES}/$1.tar.*)
    case ${ARCHIVE} in
	*.bz2)
	    echo "archive type bz2"
	    TYPE=j
	    ;;
	*.gz)
	    echo "archive type gz"
	    TYPE=z
	    ;;
	*)
	    echo "Unknown archive type of $1"
	    echo ${ARCHIVE}
	    exit 1
	    ;;
    esac
    ${TAR} xf${TYPE}${TARFLAGS} ${SOURCES}/$1.tar.*
}

# Install a build
function install {
    log $1
    ${SUDO} make ${MAKEFLAGS} $2 $3 $4 $5 $6 $7 $8
}

mkdir -p ${STAMPS} ${SOURCES}

cd ${SOURCES}

fetch ${BINUTILS} http://ftp.gnu.org/gnu/binutils/${BINUTILS}.tar.bz2
fetch ${GCC} ${GCCURL}
fetch ${NEWLIB} ftp://sources.redhat.com/pub/newlib/${NEWLIB}.tar.gz
fetch ${GDB} http://ftp.gnu.org/gnu/gdb/${GDB}.tar.bz2

fetch ${GMP} ftp://ftp.gmplib.org/pub/${GMP}/${GMP}.tar.bz2
fetch ${MPFR} http://www.mpfr.org/mpfr-current/${MPFR}.tar.bz2
fetch ${MPC} http://www.multiprecision.org/mpc/download/${MPC}.tar.gz

fetch ${LIBELF} http://www.mr511.de/software/${LIBELF}.tar.gz


cd ${SUMMON_DIR}

if [ ! -e build ]; then
    mkdir build
fi

if [ ! -e ${STAMPS}/${LIBELF}.build ]; then
	unpack ${LIBELF}
	cd build
	log "Configuring ${LIBELF}"
	../${LIBELF}/configure --prefix=${DEPS_PREFIX} --disable-shared --enable-static
	make ${MAKEFLAGS}
	install ${LIBELF} install
	cd ..
	log "Cleaning up ${LIBELF}"
	rm -rf build/* ${LIBELF}
	touch ${STAMPS}/${LIBELF}.build
fi

if [ ! -e ${STAMPS}/${GMP}.build ]; then
	unpack ${GMP}
	cd build
	log "Configuring ${GMP}"
	../${GMP}/configure --prefix=${DEPS_PREFIX} --disable-shared --enable-static
	make ${MAKEFLAGS}
	make ${MAKEFLAGS} check
	install ${GMP} install
	cd ..
	log "Cleaning up ${GMP}"
	rm -rf build/* ${GMP}
	touch ${STAMPS}/${GMP}.build
fi

if [ ! -e ${STAMPS}/${MPFR}.build ]; then
	unpack ${MPFR}
	cd build
	log "Configuring ${MPFR}"
	../${MPFR}/configure --prefix=${DEPS_PREFIX} --with-gmp=${DEPS_PREFIX} --disable-shared --enable-static
	make ${MAKEFLAGS}
	install ${MPFR} install
	cd ..
	log "Cleaning up ${MPFR}"
	rm -rf build/* ${MPFR}
	touch ${STAMPS}/${MPFR}.build
fi

if [ ! -e ${STAMPS}/${MPC}.build ]; then
	unpack ${MPC}
	cd build
	log "Configuring ${MPC}"
	../${MPC}/configure --prefix=${DEPS_PREFIX} --with-gmp=${DEPS_PREFIX} --disable-shared --enable-static
	make ${MAKEFLAGS} 
	install ${MPC} install
	cd ..
	log "Cleaning up ${MPC}"
	rm -rf build/* ${MPC}
	touch ${STAMPS}/${MPC}.build
fi

if [ ! -e ${STAMPS}/${BINUTILS}.build ]; then
    unpack ${BINUTILS}
    cd build
    log "Configuring ${BINUTILS}"
    ../${BINUTILS}/configure --target=${TARGET} \
                           --prefix=${PREFIX} \
													 --disable-shared \
                           --enable-interwork \
                           --enable-multilib \
                           --with-gnu-as \
                           --with-gnu-ld \
                           --disable-nls \
                           --disable-werror \
			   ${BINUTILFLAGS}
    log "Building ${BINUTILS}"
    make ${MAKEFLAGS}
    install ${BINUTILS} install
    cd ..
    log "Cleaning up ${BINUTILS}"
    touch ${STAMPS}/${BINUTILS}.build
    rm -rf build/* ${BINUTILS}
fi

if [ ! -e ${STAMPS}/${GCC}-boot.build ]; then
    unpack ${GCC} boot
    cd build
    log "Configuring ${GCC}-boot"
    ../${GCC}/configure --target=${TARGET} \
                      --prefix=${PREFIX} \
                      --disable-shared \
											--with-mpfr=${DEPS_PREFIX} \
											--with-gmp=${DEPS_PREFIX} \
											--with-mpc=${DEPS_PREFIX} \
                      --enable-interwork \
                      --enable-multilib \
                      --enable-languages="c,c++" \
                      --with-newlib \
                      --without-headers \
                      --with-gnu-as \
                      --with-gnu-ld \
                      --disable-nls \
                      --disable-werror \
		      --with-system-zlib \
					--with-sysroot=${PREFIX} \
		      ${GCCFLAGS}
    log "Building ${GCC}-boot"
    make ${MAKEFLAGS} all-gcc
    install ${GCC}-boot install-gcc
    cd ..
    log "Cleaning up ${GCC}-boot"
    touch ${STAMPS}/${GCC}-boot.build
    rm -rf build/* ${GCC}
fi

if [ ! -e ${STAMPS}/${NEWLIB}.build ]; then
    unpack ${NEWLIB}
    cd build
    log "Configuring ${NEWLIB}"
    ../${NEWLIB}/configure --target=${TARGET} \
                         --prefix=${PREFIX} \
                         --enable-interwork \
                         --enable-multilib \
                         --with-gnu-as \
                         --with-gnu-ld \
                         --disable-nls \
                         --disable-werror \
                         --disable-newlib-supplied-syscalls \
			 --with-float=soft
    log "Building ${NEWLIB}"
    make ${MAKEFLAGS} CFLAGS_FOR_TARGET="-msoft-float" CCASFLAGS="-msoft-float"
    install ${NEWLIB} install
    cd ..
    log "Cleaning up ${NEWLIB}"
    touch ${STAMPS}/${NEWLIB}.build
    rm -rf build/* ${NEWLIB}
fi

# Yes, you need to build gcc again!
if [ ! -e ${STAMPS}/${GCC}.build ]; then
    unpack ${GCC}
    cd build
    log "Configuring ${GCC}"
    ../${GCC}/configure --target=${TARGET} \
                      --prefix=${PREFIX} \
                      --disable-shared \
											--with-mpfr=${DEPS_PREFIX} \
											--with-gmp=${DEPS_PREFIX} \
											--with-mpc=${DEPS_PREFIX} \
                      --enable-interwork \
                      --enable-multilib \
                      --enable-languages="c,c++" \
                      --with-newlib \
                      --with-gnu-as \
                      --with-gnu-ld \
											--disable-nls \
                      --disable-werror \
											--with-sysroot=${PREFIX} \
                      #--with-system-zlib \
	 	     ${GCCFLAGS}
    log "Building ${GCC}"
    make ${MAKEFLAGS}
    install ${GCC} install
    cd ..
    log "Cleaning up ${GCC}"
    touch ${STAMPS}/${GCC}.build
    rm -rf build/* ${GCC}
fi

if [ ! -e ${STAMPS}/${GDB}.build ]; then
    unpack ${GDB}
    cd build
    log "Configuring ${GDB}"
    ../${GDB}/configure --target=${TARGET} \
                      --prefix=${PREFIX} \
                      --enable-interwork \
                      --enable-multilib \
                      --disable-werror \
		      ${GDBFLAGS}
    log "Building ${GDB}"
    make ${MAKEFLAGS}
    install ${GDB} install
    cd ..
    log "Cleaning up ${GDB}"
    touch ${STAMPS}/${GDB}.build
    rm -rf build/* ${GDB}
fi
