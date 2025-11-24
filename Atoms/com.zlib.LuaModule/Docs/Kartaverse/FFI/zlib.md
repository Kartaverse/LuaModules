# LuaJIT zlib Module

This module provides LuaJIT FFI bindings to the zlib compression library. It allows you to compress and decompress data using Deflate, Zlib, and GZIP formats directly from Lua.

## Installation

1.  **Compile zlib:**
    The module requires a shared library (`zlib.so` on macOS/Linux, `zlib.dll` on Windows).
    
    To compile on macOS:
    ```bash
    git clone https://github.com/madler/zlib.git
    cd zlib
    ./configure --shared
    make
    cp libz.dylib ../zlib.so
    ```

2.  **Place files:**
    Ensure `zlib.lua` and `zlib.so` are in the same directory. This directory should be in your Lua `package.path` or the same directory as your script.

## Usage

### Loading the Module

```lua
local zlib = require("zlib")
```

### GZIP Compression (Files)

To write a GZIP file:
```lua
local success, err = zlib.gz_write_file("output.gz", "Data to compress")
if not success then error(err) end
```

To read a GZIP file:
```lua
local data, err = zlib.gz_read_file("input.gz")
if not data then error(err) end
```

### In-Memory Compression

**Deflate (Raw):**
Used for ZIP files (no header/trailer).
```lua
local compressed = zlib.deflate(data, nil, -15)
local decompressed = zlib.inflate(compressed, -15)
```

**Zlib (Default):**
Standard zlib wrapper.
```lua
local compressed = zlib.deflate(data)
local decompressed = zlib.inflate(compressed)
```

**GZIP (In-Memory):**
GZIP wrapper.
```lua
local compressed = zlib.deflate(data, nil, 31)
local decompressed = zlib.inflate(compressed, 31)
```

## API Reference

*   `zlib.version()`: Returns the zlib library version.
*   `zlib.crc32(data, seed)`: Calculates CRC32 checksum.
*   `zlib.deflate(data, level, windowBits)`: Compresses data.
    *   `level`: 0-9 (default -1).
    *   `windowBits`: 
        *   `15`: zlib wrapper (default)
        *   `-15`: raw deflate
        *   `31`: gzip wrapper
*   `zlib.inflate(data, windowBits)`: Decompresses data.
*   `zlib.gz_write_file(filename, data)`: Writes data to a .gz file.
*   `zlib.gz_read_file(filename)`: Reads data from a .gz file.

## Examples

See `GZIP Compression Demo.lua` and `ZIP Compression Demo.lua` for complete working examples.