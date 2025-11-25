# Media Lua Modules

## Overview

A collection of Lua Modules that allow LuaJIT work with common audio, video, 3D, and networking libraries.

This project is still in an alpha development stage. The source code is provided so you can customize the lua module FFI bindings for your specific and exact needs.

## Libraries

- Base91
- [CPython](Atoms/com.CPython.LuaModule/Docs/Kartaverse/FFI/CPython.md)
- [cURL](Atoms/com.cURL.LuaModule/Docs/Kartaverse/FFI/cURL.md)
- FFmpeg LibAV
- [LuaSocket](Atoms/com.LuaSocket.LuaModule/Docs/Kartaverse/FFI/LuaSocket.md)
- [Perl](Atoms/com.Perl.LuaModule/Docs/Kartaverse/FFI/Perl.md)
- [STB Image](Atoms/com.stb.Image.LuaModule/Docs/Kartaverse/FFI/stb%20image.md)
- [VR Mesh Library](Atoms/com.VRMeshLibrary.LuaModule/Docs/Kartaverse/FFI/VRMeshLibrary.md)
- [zlib](Atoms/com.zlib.LuaModule/Docs/Kartaverse/FFI/zlib.md)

## Shared Libraries

Pre-compiled .so shared library files are provided for macOS ARM64 users.

You might have to edit the "ffi.load()" filepath code for the .lua files to correctly detect the .so shared library in the same Lua Modules folder hierarchy.

## License

The Lua Module FFI wrappers are provided under an MIT open-source software license to align with Lua's license terms. If required by your project, you can use these FFI wrappers under an LGPL license, too.

## Installation

The Lua Module files are provided as Reactor atom packages. This helps to simplify the installation process for BMD Resolve Studio and Fusion Studio usage. The target audience for the Lua Modules are fuse and Lua comp script develpers who create custom data nodes in Fusion.
