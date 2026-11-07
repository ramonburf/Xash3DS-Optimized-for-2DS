# Xash3DS, optimized for the 2DS

A fork of [masterfeizz/Xash3DS](https://github.com/masterfeizz/Xash3DS) tuned for the original 2DS and old 3DS (268 MHz ARM11, 64 MB RAM). New 3DS behaviour is unchanged.

## What's different

Faster map loading (all consoles):
- File-existence checks on the SD card are answered from a per-folder listing cache instead of one SD call per probe
- 16 KB file read buffer instead of 2 KB, and no `stat()` on every file open
- No software mipmaps at texture upload (picaGL discards mip levels above 0 anyway)
- Faster sound visibility (PAS) build at map load
- Buffered writes for save files, so level transitions don't do thousands of tiny SD card writes

Lighter defaults on old 3DS / 2DS only:
- `fps_max 30`, 128px max texture size, `r_dynamic 0`, `r_decals 128`, `gl_check_errors 0`

If you used Xash3DS before, delete the saved config in `sdmc:/xash3d/valve/` so the new defaults take effect.

## Building

Needs Docker. From the repository root:

    docker run --rm -v "$PWD:/src" -w /src devkitpro/devkitarm bash scripts/3ds/build.sh

On Windows Git Bash, prefix it with `MSYS_NO_PATHCONV=1`. The script fetches pinned picaGL and hlsdk_3ds versions and writes `Xash3DS.3dsx`.

---

# Xash3D FWGS Engine [![Build Status](https://travis-ci.org/FWGS/xash3d.svg)](https://travis-ci.org/FWGS/xash3d) [![Windows Build Status](https://ci.appveyor.com/api/projects/status/github/FWGS/xash3d?svg=true)](https://ci.appveyor.com/project/a1batross/xash3d)

Latest version of the engine is available at:
https://github.com/FWGS/xash3d

Orignal project: [Xash3D on ModDB](http://www.moddb.com/engines/xash3d-engine)

Xash3D Engine is a custom Gold Source engine rewritten from scratch. Xash3D
is compatible with many of the Gold Source games and mods and should be
able to run almost any existing singleplayer Half-Life mod without a hitch.
The multiplayer part is not yet completed, multiplayer mods should work just
fine, but bear in mind that some features may not work at all or work not
exactly the way they do in Gold Source Engine.

Xash3D FWGS is a fork of Xash3D Engine, which aims on crossplatform and compatibility
with original Xash3D and Gold Source.

- [Building and running Xash3D FWGS](https://github.com/FWGS/xash3d/wiki/Building-and-running)
- [Installing and setting up the server on Debian/Ubuntu Linux](https://github.com/FWGS/xash3d/wiki/How-to-set-up-a-Xash3D-Dedicated-Server-on-Debian-Ubuntu-Linux)

# License

The library is licensed under GPLv3 license, see [COPYING](https://github.com/FWGS/xash3d/blob/master/COPYING) for details.
CMakeLists.txt files are licensed under MIT license, you will find it's text
in every CMakeLists.txt header.
