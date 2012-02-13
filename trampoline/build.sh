#!/bin/sh

# Stop if any command fails
set -e

# Settings
TRAMPOLINE_REPO_URL=https://trampoline.rts-software.org/svn/trunk
TRAMPOLINE_REPO_USER=anonymous
TRAMPOLINE_REPO_PASS=anonymous

LIBPM_VERSION=2.3.0
LIBPM_URL=http://galgas.rts-software.org/download/${LIBPM_VERSION}/galgas-sources-lf.tar.bz2

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

LIBPM_FILE=${SOURCES}/galgas.tar.bz2

if [ ! -e ${LIBPM_FILE} ]; then
	log "Downloading Libpm ($LIBPM_URL)"
	wget -qc $LIBPM_URL -O ${LIBPM_FILE}
fi

if [ ! -e galgas ]; then
	log "Unpacking ${LIBPM_FILE}"
	bunzip2 -kc ${LIBPM_FILE} | tar -xf -
fi

if [ ! -e ${PREFIX}/trampoline ]; then
	log "Checking out trampoline (${TRAMPOLINE_REPO_URL})"
	#svn checkout --quiet --username ${TRAMPOLINE_REPO_USER} --password ${TRAMPOLINE_REPO_PASS} ${TRAMPOLINE_REPO_URL} ${SOURCES}/trampoline
	cp -r ${SOURCES}/trampoline ${PREFIX}/trampoline
fi

if [ ! -e ${PREFIX}/trampoline/galgas ]; then
	log "Installing libpm in trampoline"
	cp -r galgas ${PREFIX}/trampoline/
	cp ${PREFIX}/trampoline/goil/galgas_sources/GALGAS_OUTPUT/file_list.{mke,mak}
fi
export LIBPM_DIRECTORY_PATH=${PREFIX}/trampoline/galgas/libpm
export LIBPM_PATH=${PREFIX}/trampoline/galgas/libpm


log "Moving to build goil ($GOIL_MAKEDIR)"
CUR_DIR=$(pwd)
cd ${GOIL_MAKEDIR}
make -s ${MAKEFLAGS}
cd ${CUR_DIR}

log "Installing goil binaries"
install ${GOIL_MAKEDIR}/goil{_debug,} ${BINDIR}

log "Done."
