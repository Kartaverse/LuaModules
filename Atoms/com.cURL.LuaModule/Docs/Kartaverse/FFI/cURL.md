# LuaJIT cURL Network Module

This project provides a Lua module that uses LuaJIT's FFI to access the cURL library for network I/O. It includes a compiled shared library (`curl.so`) for macOS and a Lua wrapper (`curl.lua`).

## Prerequisites

- **macOS**: The provided `curl.so` is compiled for macOS.
- **LuaJIT**: You need LuaJIT installed to run the scripts.
- **OpenSSL**: The cURL library is linked against OpenSSL (installed via Homebrew).

## Installation

1.  Ensure `curl.lua` and `curl.so` are in the same directory as your script.
2.  Install LuaJIT if you haven't already:
    ```bash
    brew install luajit
    ```

## Usage

Require the module in your Lua script:

```lua
local curl = require("curl")
```

### Example: Simple GET Request

```lua
local ffi = require("ffi")
local curl = require("curl")

local easy = curl.curl_easy_init()
curl.curl_easy_setopt(easy, curl.CURLOPT_URL, "https://httpbin.org/get")
curl.curl_easy_perform(easy)
curl.curl_easy_cleanup(easy)
```

## Running the Demo

A demo script `cURL Network Demo.lua` is provided to test GET and POST requests.

Run it with LuaJIT:

```bash
luajit "cURL Network Demo.lua"
```

## Building from Source

If you need to rebuild `curl.so`:

1.  Clone the cURL repository:
    ```bash
    git clone https://github.com/curl/curl.git
    cd curl
    git checkout curl-8_5_0
    ```
2.  Build with CMake (ensure OpenSSL is installed):
    ```bash
    mkdir build && cd build
    cmake .. -DBUILD_SHARED_LIBS=ON -DCURL_USE_OPENSSL=ON -DOPENSSL_ROOT_DIR=$(brew --prefix openssl)
    make
    ```
3.  Copy the resulting dylib to your project root and rename it:
    ```bash
    cp lib/libcurl.dylib ../../curl.so
    ```

## License

This project uses libcurl, which is licensed under the curl license (MIT/X derivate).
