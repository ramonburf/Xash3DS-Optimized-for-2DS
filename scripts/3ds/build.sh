#!/bin/bash
# Builds Xash3DS.3dsx with all its dependencies inside the devkitPro Docker image.
#
# From the repository root (Linux / macOS / WSL):
#   docker run --rm -v "$PWD:/src" -w /src devkitpro/devkitarm bash scripts/3ds/build.sh
# From Git Bash on Windows, prefix the command with MSYS_NO_PATHCONV=1
#
# Output: Xash3DS.3dsx in the repository root.
set -e
cd "$(dirname "$0")/../.."
ROOT=$PWD
J=$(nproc)
export PATH=$DEVKITARM/bin:$PATH

# pinned dependency versions this was tested with
PICAGL_URL=https://github.com/masterfeizz/picaGL.git
PICAGL_REV=39039f3a40d4e5bc6c69aac96668401d121c002b
HLSDK_URL=https://github.com/masterfeizz/hlsdk_3ds.git
HLSDK_REV=bd49c261acc3ebf597053b9bc57b69de1249b210

# the engine and game code predate C23 (they define their own true/false)
OLDC="CC=$DEVKITARM/bin/arm-none-eabi-gcc -std=gnu11"
# GCC 14+ turned these old-C warnings into errors; the 2019 engine code relies on them
LEGACY="-Wno-error=incompatible-pointer-types -Wno-error=implicit-function-declaration -Wno-error=return-mismatch -Wno-error=int-conversion"

fetch() # dir url rev
{
	if [ ! -d "$1/.git" ]; then
		git clone -q "$2" "$1"
	fi
	git -C "$1" fetch -q origin
	git -C "$1" checkout -q -f "$3"
	git -C "$1" clean -qfdx
}

git config --global --add safe.directory '*'
git submodule update --init --recursive
mkdir -p deps lib

echo "== picaGL"
fetch deps/picaGL $PICAGL_URL $PICAGL_REV
# modern libctru warns about -D_3DS, and picaGL builds with -Werror
sed -i 's/-DARM11 -D_3DS/-D__3DS__/' deps/picaGL/Makefile
make -C deps/picaGL -j$J
mkdir -p $DEVKITPRO/picaGL/lib $DEVKITPRO/picaGL/include
cp deps/picaGL/lib/libpicaGL.a $DEVKITPRO/picaGL/lib/
cp -r deps/picaGL/include/* $DEVKITPRO/picaGL/include/

echo "== hlsdk (client and server game code)"
fetch deps/hlsdk_3ds $HLSDK_URL $HLSDK_REV
git -C deps/hlsdk_3ds apply "$ROOT/scripts/3ds/hlsdk-newer-gcc.patch"
# cl_dll and dlls compile the same ../dlls/*.cpp into the same .o paths
# (cl_dll with CLDLL_-renamed classes), so build them one at a time
make -C deps/hlsdk_3ds/cl_dll -f Makefile.3ds -j$J "$OLDC"
cp deps/hlsdk_3ds/cl_dll/libclient.a lib/
find deps/hlsdk_3ds -name '*.o' -delete
make -C deps/hlsdk_3ds/dlls -j$J "$OLDC"
cp deps/hlsdk_3ds/dlls/libserver.a lib/

echo "== mainui"
make -C mainui_3ds -f Makefile.3ds -j$J "$OLDC"
cp mainui_3ds/libmainui.a lib/

echo "== engine"
make -j$J TARGET=Xash3DS "$OLDC $LEGACY"
ls -la Xash3DS.3dsx
