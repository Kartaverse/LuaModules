# LuaJIT CPython Module

This project provides a Lua module that uses LuaJIT FFI to access an embedded CPython 3.11 library.

## Prerequisites

*   macOS (tested on Apple Silicon)
*   LuaJIT
*   Clang/GCC
*   Make
*   Git

## Installation

1.  **Clone the repository** (if you haven't already).
2.  **Build CPython**:
    The project includes a `cpython` submodule (or you can clone it manually).
    
    ```bash
    # Clone CPython 3.11 if not present
    git clone --depth 1 --branch 3.11 https://github.com/python/cpython.git
    
    # Configure and Build
    cd cpython
    ./configure --enable-shared
    make -j$(sysctl -n hw.ncpu)
    cd ..
    
    # Copy the shared library
    cp cpython/libpython3.11.dylib cpython.so
    ```

## Usage

1.  Ensure `cpython.lua` and `cpython.so` are in the same directory (or `cpython.so` is in a path accessible relative to `cpython.lua`).
2.  Require the module in your Lua script:

    ```lua
    local cpython = require("cpython")
    
    -- Set the Python path to include the standard library and compiled modules
    -- Adjust paths as necessary for your environment
    local ffi = require("ffi")
    local path = "./cpython/Lib:./cpython/build/lib.macosx-26.1-arm64-3.11"
    local wchar_path = ffi.new("wchar_t[?]", #path + 1)
    for i = 1, #path do
        wchar_path[i-1] = string.byte(path, i)
    end
    wchar_path[#path] = 0
    
    cpython.Py_SetPath(wchar_path)
    
    -- Unset PYTHONPATH/PYTHONHOME to avoid conflicts with system Python
    ffi.cdef[[ int unsetenv(const char *name); ]]
    ffi.C.unsetenv("PYTHONPATH")
    ffi.C.unsetenv("PYTHONHOME")

    cpython.Py_Initialize()
    cpython.PyRun_SimpleString("print('Hello from Python!')")
    cpython.Py_Finalize()
    ```

## Running the Demo

To run the example script, execute the following command in your terminal:

```bash
luajit "CPython Demo.lua"
```

## Files

*   `cpython.lua`: The Lua module definition.
*   `cpython.so`: The compiled CPython shared library.
*   `CPython Demo.lua`: An example script demonstrating usage.

## Distribution

To distribute this module or move it to another location, you need to copy the following:

1.  `cpython.lua`
2.  `cpython.so`
3.  The Python Standard Library (`Lib` folder from the `cpython` source).
4.  The compiled Python modules (located in `cpython/build/lib.macosx-...`).

You should organize them such that `cpython.lua` can find `cpython.so`, and the Python initialization code (like in `CPython Demo.lua`) can point `Py_SetPath` to the `Lib` folder and the compiled modules folder.

## Troubleshooting

*   **Import Errors**: If Python cannot find standard modules, you may need to set `PYTHONHOME` or ensure the `Lib` directory from the CPython source is accessible.
*   **Architecture Mismatch**: Ensure both LuaJIT and the compiled `cpython.so` are built for the same architecture (e.g., arm64 on Apple Silicon).

Sample Output:

```bash
luajit "Py Demo.lua"
Hello from Python! sys.version: 3.11.14+ (heads/3.11:3b7d81d, Nov 24 2025, 05:34:08) [Clang 17.0.0 (clang-1700.4.4.1)]
sys.path: ['/Users/vfx/Desktop/LuaJIT CPython Lua Module/cpython/Lib', '/Users/vfx/Desktop/LuaJIT CPython Lua Module/cpython/build/lib.macosx-26.1-arm64-3.11']
Initializing Python...
Python Version:
3.11.14+ (heads/3.11:3b7d81d, Nov 24 2025, 05:34:08) [Clang 17.0.0 (clang-1700.4.4.1)]

Running Python code:

Finalizing Python...
Done.
```
