# LuaJIT STB Image Module

This is a LuaJIT FFI module for the [stb_image](https://github.com/nothings/stb) single-file image loading and writing libraries. It allows you to load and write images directly from Lua using LuaJIT.

## Files

*   `stb_image.lua`: The Lua module that provides the FFI bindings.
*   `stb_image.so`: The compiled shared library containing the STB image implementation.
*   `stb_impl.c`: The C source file used to compile the shared library.
*   `STB Image Demo.lua`: An example script demonstrating how to use the module.

## Installation

To use this module in your LuaJIT project, you need to ensure that both `stb_image.lua` and `stb_image.so` are accessible to your script.

### Option 1: Local Directory (Recommended for simple projects)

Simply place `stb_image.lua` and `stb_image.so` in the same directory as your main Lua script. The module is designed to automatically look for the `.so` file in the same directory as the `.lua` file.

### Option 2: Lua Package Path

If you want to install the module globally or in a specific library directory:

1.  **Lua File**: Copy `stb_image.lua` to a directory in your `package.path` (e.g., `/usr/local/share/lua/5.1/` or a local `libs` folder).
2.  **Shared Library**: Copy `stb_image.so` to the **same directory** where you put `stb_image.lua`.

**Note:** The `stb_image.lua` script uses `debug.getinfo` to find its own path and load the shared library from there. If you move `stb_image.so` to a different location (like `/usr/local/lib`), you will need to modify `stb_image.lua` to point to the correct path or ensure it's in a standard system library path and change `ffi.load` to just `ffi.load("stb_image")`.

## Usage

```lua
local stb = require("stb_image")
local ffi = require("ffi")

-- Loading an image
local x = ffi.new("int[1]")
local y = ffi.new("int[1]")
local n = ffi.new("int[1]")

-- Force 0 channels to get the default, or 3 for RGB, 4 for RGBA
local data = stb.stbi_load("image.png", x, y, n, 0)

if data ~= nil then
    print("Loaded image: " .. x[0] .. "x" .. y[0] .. " with " .. n[0] .. " channels")
    
    -- Access pixel data (example: first pixel)
    -- data is a pointer to unsigned char
    local r = data[0]
    local g = data[1]
    local b = data[2]
    
    -- Remember to free the memory!
    stb.stbi_image_free(data)
else
    print("Failed to load image: " .. ffi.string(stb.stbi_failure_reason()))
end

-- Writing an image
local width = 100
local height = 100
local channels = 3
local stride = width * channels
local image_data = ffi.new("unsigned char[?]", width * height * channels)

-- ... fill image_data ...

local res = stb.stbi_write_png("output.png", width, height, channels, image_data, stride)
if res == 0 then
    print("Failed to write image")
end
```

## Compilation

If you need to recompile the shared library (e.g., for a different platform):

```bash
clang -shared -fPIC -o stb_image.so stb_impl.c
```

Ensure you have the `stb` headers available (included in the `stb/` directory in this repo).