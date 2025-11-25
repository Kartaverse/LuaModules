# LuaJIT Perl Module

This module allows you to embed a Perl interpreter within LuaJIT using the FFI library. It provides a simple API to initialize a Perl interpreter and execute Perl code.

## Installation

1.  Ensure you have `perl.lua` and `perl_ffi.so` in the same directory.
2.  Place this directory in your Lua package path, or ensure the files are in a location where `require("perl")` can find them.
3.  The `perl_ffi.so` library is a shared library compiled from the Perl source code. It is configured to be relocatable, so it should work as long as it is in the same directory as `perl.lua`.

## Usage

```lua
local perl = require("perl")

-- Create a new Perl interpreter instance
local p, err = perl.new()
if not p then
    error("Failed to create Perl interpreter: " .. err)
end

-- Run Perl code
-- The arguments simulate the command line arguments passed to the perl executable
local args = {"perl", "-e", "print 'Hello from Perl!\\n'"}
local result, err = p:run(args)

if result ~= 0 then
    error("Perl execution failed: " .. (err or "unknown error"))
end
```

## API

### `perl.new()`

Creates a new Perl interpreter instance.

*   **Returns:**
    *   `p`: A table representing the Perl interpreter instance, or `nil` on failure.
    *   `err`: An error message string if creation failed.

### `p:run(args)`

Parses and executes Perl code using the interpreter instance.

*   **Parameters:**
    *   `args`: A table of strings representing the command-line arguments to pass to the Perl interpreter. The first argument should typically be "perl".
*   **Returns:**
    *   `result`: The exit code of the Perl execution (0 usually indicates success).
    *   `err`: An error message string if the `perl_parse` step failed.

## Building from Source

To build the `perl_ffi.so` library, you need the Perl source code.

1.  Clone the Perl repository.
2.  Configure the build with `-Duseshrplib` to generate a shared library.
3.  Compile the source.
4.  Rename the generated `libperl.dylib` (on macOS) to `perl_ffi.so`.
5.  Use `install_name_tool` to set the install name to `@loader_path/perl_ffi.so` for portability.