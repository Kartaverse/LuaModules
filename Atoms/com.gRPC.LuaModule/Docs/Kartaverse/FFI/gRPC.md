# LuaJIT gRPC Module

This module provides gRPC bindings for LuaJIT on macOS.

## Installation

1.  Copy `grpc.lua` and `grpc_ffi.so` to your Lua module path (e.g., `/usr/local/lib/lua/5.1/` or a local directory).
2.  Ensure both files are in the same directory.

## Usage

```lua
local grpc = require("grpc")

-- Initialize gRPC
grpc.init()

-- Get version
print(grpc.version())

-- Shutdown gRPC
grpc.shutdown()
```

## API

### `grpc.version()`

Returns the gRPC library version string.

### `grpc.init()`

Initializes the gRPC library. Must be called before using other gRPC functions.

### `grpc.shutdown()`

Shuts down the gRPC library. Should be called when done.

## Building from Source

1.  Run `./build.sh` to build the shared library.
2.  Artifacts will be placed in `Releases/Modules/Lua`.