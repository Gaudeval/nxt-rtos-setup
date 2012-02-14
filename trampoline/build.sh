#!/bin/sh

# Stop if any command fails
set -e

# Settings
TRAMPOLINE_VERSION=2b49
TRAMPOLINE_URL=http://trampoline.rts-software.org/IMG/tgz/trampoline${TRAMPOLINE_VERSION}.tgz

LIBPM_VERSION=2.0.0
LIBPM_URL=http://galgas.rts-software.org/download/${LIBPM_VERSION}/libpm-lf.tar.bz2

# Flags
CPUS=$(getconf _NPROCESSORS_ONLN)
PARALLEL=-j$((CPUS + 1))
echo "${CPUS} cpu's detected running make with '${PARALLEL}' flag"

MAKEFLAGS=${PARALLEL}
TARFLAGS=v

SUMMON_DIR=$(pwd)
SOURCES=${SUMMON_DIR}/sources
PREFIX=${SUMMON_DIR}/install
BINDIR=${PREFIX}/bin

# Tools
TAR=tar

##############################################################################
# OS and Tooldetection section
# Detects which tools and flags to use
##############################################################################

case "$(uname)" in
	Linux)
		echo "Found Linux OS."
		GOIL_MAKEDIR=${PREFIX}/trampoline/goil/makefile_unix/
	;;
	Darwin)
		echo "Found Darwin OS."
		GOIL_MAKEDIR=${PREFIX}/trampoline/goil/makefile_macosx/
	;;
	*)
		echo "Found unknown OS. Aborting!"
		exit 1
	;;
esac


# Building
mkdir -p ${SOURCES} ${BINDIR}

# Log a message out to the console
function log {
	    #echo "******************************************************************"
			echo "* $*"
			#echo "******************************************************************"
}

LIBPM_FILE=${SOURCES}/libpm.tar.bz2
TRAMPOLINE_FILE=${SOURCES}/trampoline.tgz

if [ ! -e ${LIBPM_FILE} ]; then
	log "Downloading Libpm ($LIBPM_URL)"
	wget -qc $LIBPM_URL -O ${LIBPM_FILE}
fi

if [ ! -e libpm ]; then
	log "Unpacking ${LIBPM_FILE}"
	bunzip2 -kc ${LIBPM_FILE} | tar -xf -
fi

if [ ! -e ${TRAMPOLINE_FILE} ]; then
	log "Downloading Trampoline ($TRAMPOLINE_URL)"
	wget -qc ${TRAMPOLINE_URL} -O ${TRAMPOLINE_FILE}
fi

if [ ! -e trampoline${TRAMPOLINE_VERSION} ]; then
	log "Unpacking ${TRAMPOLINE_FILE}"
	tar -xzf ${TRAMPOLINE_FILE}
fi

if [ ! -e ${PREFIX}/trampoline ]; then
	log "Checking out trampoline"
	cp -r trampoline${TRAMPOLINE_VERSION} ${PREFIX}/trampoline
fi

if [ ! -e ${PREFIX}/trampoline/libpm ]; then
	log "Installing libpm in trampoline"
	cp -r libpm ${PREFIX}/trampoline/
fi

export LIBPM_PATH_ENV_VAR=${PREFIX}/trampoline/libpm

log "Moving to build goil ($GOIL_MAKEDIR)"
CUR_DIR=$(pwd)
cd ${GOIL_MAKEDIR}
make -s ${MAKEFLAGS}
cd ${CUR_DIR}

log "Installing goil binaries"
install ${GOIL_MAKEDIR}/goil{_debug,} ${BINDIR}

log "Done."
