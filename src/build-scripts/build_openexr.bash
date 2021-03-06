#!/bin/bash

# The Linux VM used by Travis has OpenEXR 1.x. We really want 2.x.

EXRREPO=${EXRREPO:=https://github.com/openexr/openexr.git}
EXRINSTALLDIR=${EXRINSTALLDIR:=${PWD}/openexr-install}
EXRBRANCH=${EXRBRANCH:=v2.2.0}
EXRCXXFLAGS=${EXRCXXFLAGS:=""}
BASEDIR=`pwd`
pwd
echo "EXR install dir will be: ${EXRINSTALLDIR}"

if [ ! -e ${EXRINSTALLDIR} ] ; then
    mkdir ${EXRINSTALLDIR}
fi

# Clone OpenEXR project (including IlmBase) from GitHub and build
if [ ! -e ./openexr ] ; then
    echo "git clone ${EXRREPO} ./openexr"
    git clone ${EXRREPO} ./openexr
fi

flags=

if [ ${LINKSTATIC:=0} == 1 ] ; then
    flags=${flags} --enable-static --enable-shared=no --with-pic
fi

pushd ./openexr
echo "git checkout ${EXRBRANCH} --force"
git checkout ${EXRBRANCH} --force
cd IlmBase
mkdir build
cd build
cmake --config Release -DCMAKE_INSTALL_PREFIX=${EXRINSTALLDIR} -DCMAKE_CXX_FLAGS=${EXRCXXFLAGS} .. && make clean && make -j 4 && make install
cd ..
cd ../OpenEXR
cp ${BASEDIR}/src/build-scripts/OpenEXR-CMakeLists.txt CMakeLists.txt
cp ${BASEDIR}/src/build-scripts/OpenEXR-IlmImf-CMakeLists.txt IlmImf/CMakeLists.txt
mkdir build
mkdir build/IlmImf
cd build
unzip -d IlmImf ${BASEDIR}/src/build-scripts/b44ExpLogTable.h.zip
unzip -d IlmImf ${BASEDIR}/src/build-scripts/dwaLookups.h.zip
cmake --config Release -DCMAKE_INSTALL_PREFIX=${EXRINSTALLDIR} -DILMBASE_PACKAGE_PREFIX=${EXRINSTALLDIR} -DBUILD_UTILS=0 -DBUILD_TESTS=0 -DCMAKE_CXX_FLAGS=${EXRCXXFLAGS} .. && make clean && make -j 4 && make install
popd

ls -R ${EXRINSTALLDIR}

#echo "listing .."
#ls ..

