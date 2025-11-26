# LuaJIT LPeg Module

This is a custom build of the LPeg library for LuaJIT on macOS, using FFI for loading.

## Installation

1. Copy `lpeg.lua` and `lpeg_ffi.so` to your Lua package path (e.g., `/usr/local/lib/lua/5.1/` or a local directory).
2. Ensure both files are in the same directory.

## Usage

```lua
local lpeg = require("lpeg")
-- Use lpeg functions as usual
```

## API

The module exposes the standard LPeg API. See the [official documentation](http://www.inf.puc-rio.br/~roberto/lpeg/) for details.

### Key Functions

- `lpeg.match(pattern, subject [, init])`: Matches a pattern against a string.
- `lpeg.P(value)`: Converts a value into a pattern.
- `lpeg.R(range)`: Matches a range of characters.
- `lpeg.S(set)`: Matches any character in a set.
- `lpeg.C(pattern)`: Captures the match.
- `lpeg.Ct(pattern)`: Captures the match as a table.

## Build

To build the shared library from source:

```bash
gcc -O2 -bundle -undefined dynamic_lookup -I/opt/homebrew/include/luajit-2.1 -o lpeg_ffi.so lpeg-src/*.c