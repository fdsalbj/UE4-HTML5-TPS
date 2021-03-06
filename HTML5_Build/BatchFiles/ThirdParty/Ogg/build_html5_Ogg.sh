#!/bin/bash
set -x -e

# Copyright 1998-2019 Epic Games, Inc. All Rights Reserved.

# NOTE: this script needs to be built from Engine/Platforms/HTML5/Build/BatchFiles/Build_All_HTML5_libs.sh


OGG_HTML5=$(pwd)
OGG_VERSION='libogg-1.2.2'
OGG_HTML5_SRC="$UE4_TPS_SRC/Ogg/$OGG_VERSION"
OGG_HTML5_DST="$HTML5_TPS_LIBS/Ogg/$OGG_VERSION"


# local destination
if [ ! -d "$OGG_HTML5_DST/lib-$UE_EMVER_LIBPATH" ]; then
	mkdir -p "$OGG_HTML5_DST/lib-$UE_EMVER_LIBPATH"
fi


build_via_cmake()
{
	SUFFIX=_O$OLEVEL
	OPTIMIZATION=-O$OLEVEL
	# ----------------------------------------
	rm -rf BUILD$SUFFIX
	mkdir BUILD$SUFFIX
	cd BUILD$SUFFIX
	# ----------------------------------------
#	TYPE=${type^^} # OSX-bash doesn't like this
	TYPE=`echo $type | tr "[:lower:]" "[:upper:]"`
	if [ $TYPE == "DEBUG" ]; then
		DBGFLAG=_DEBUG
	else
		DBGFLAG=NDEBUG
	fi
	EMFLAGS="$UE_EMFLAGS"
	# ----------------------------------------
	EMPATH=$(dirname `which emcc.py`)
	export CFLAGS="-I$EMPATH/system/include/libc" # 1.37.36 needs this...
	# ----------------------------------------
	emcmake cmake -G "$EM_CMAKE_GEN_TYPE" \
		-DBUILD_SHARED_LIBS=OFF \
		-DEMSCRIPTEN_GENERATE_BITCODE_STATIC_LIBRARIES=$UE_USE_BITECODE \
		-DCMAKE_BUILD_TYPE=$type \
		-DCMAKE_C_FLAGS_$TYPE="$OPTIMIZATION -D$DBGFLAG $EMFLAGS" \
		"$OGG_HTML5_SRC"
	cmake --build . -- -j VERBOSE=1 2>&1 | tee zzz_build.log
	# ----------------------------------------
	if [ $OLEVEL == 0 ]; then
		SUFFIX=
	fi
	cp libogg.$UE_LIB_EXT "$OGG_HTML5_DST"/lib-$UE_EMVER_LIBPATH/libogg${SUFFIX}.$UE_LIB_EXT
	cd ..
}

if [ "$USE_INTERMEDIATE_PATH" == "1" ]; then
	mkdir -p $HOME/$UE_EMVER_LIBPATH/$OGG_VERSION
	cd $HOME/$UE_EMVER_LIBPATH/$OGG_VERSION
fi
#type=Debug;       OLEVEL=0;  build_via_cmake
type=Release;     OLEVEL=2;  build_via_cmake
type=Release;     OLEVEL=3;  build_via_cmake
type=MinSizeRel;  OLEVEL=z;  build_via_cmake
ls -l "$OGG_HTML5_DST/lib-$UE_EMVER_LIBPATH"

