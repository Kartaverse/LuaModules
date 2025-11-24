# Media Lua Modules

## Overview

A collection of Lua Modules that allow LuaJIT work with common audio, video, 3D, and networking libraries.

This project is still in an alpha development stage. The source code is provided so you can customize the lua module FFI bindings for your specific and exact needs.

## Libraries

- [CPython](Atoms/com.CPython.LuaModule/Docs/Kartaverse/FFI/CPython.md)
- [cURL](Atoms/com.cURL.LuaModule/Docs/Kartaverse/FFI/cURL.md)
- FFmpeg LibAV
- [LuaSocket](Atoms/com.LuaSocket.LuaModule/Docs/Kartaverse/FFI/LuaSocket.md)
- [STB Image](Atoms/com.stb.Image.LuaModule/Docs/Kartaverse/FFI/stb%20image.md)
- [zlib](Atoms/com.zlib.LuaModule/Docs/Kartaverse/FFI/zlib.md)

## Shared Libraries

Pre-compiled .so shared library files are provided for macOS ARM64 users.

## License

The Lua Module FFI wrappers are provided under an MIT open-source software license to aign with Lua's license terms. If required you can use the FFI wrappers under an LGPL license, too.

## Installation

The Lua Module files are provided as Reactor atom packages. Thish helps to simplify the installation process for BMD Resolve Studio and Fusion Studio usage.

The target audience for the Lua Modules are fuse and Lua comp script develpers who create custom data nodes in Fusion.
