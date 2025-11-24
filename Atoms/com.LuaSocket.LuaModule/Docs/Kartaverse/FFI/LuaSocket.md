# LuaSocket for LuaJIT (macOS)

This project provides a self-contained LuaSocket module compiled for LuaJIT on macOS. It includes a custom `socket.lua` loader that allows the module to be used with a co-located `socket.so` shared library, making it easy to distribute and use without complex installation procedures.

## Contents

*   `socket.lua`: The main Lua module. It automatically loads the sibling `socket.so`.
*   `socket.so`: The compiled LuaSocket C core library (macOS shared object).
*   `Socket TCP Demo.lua`: Example script demonstrating a TCP HTTP GET request.
*   `Socket UDP Demo.lua`: Example script demonstrating a UDP NTP time query.
*   `Socket ICMP Demo.lua`: Example script demonstrating a raw socket ICMP Ping (requires root/sudo).

## Prerequisites

*   **LuaJIT**: Ensure you have LuaJIT installed.
    *   `brew install luajit` (on macOS via Homebrew)

## Installation

No special installation is required. Simply keep `socket.lua` and `socket.so` in the same directory.

## Usage

To use the module in your own scripts, ensure the directory containing `socket.lua` is in your `package.path`, or simply place your script in the same folder.

```lua
-- Add current directory to package path if needed
package.path = package.path .. ";./?.lua"

local socket = require("socket")

-- Use socket functions...
local tcp = socket.tcp()
```

## Running the Demos

Open a terminal in this directory and run the following commands:

### 1. TCP Demo (HTTP Request)
Connects to google.com and fetches the homepage.

```bash
luajit "Socket TCP Demo.lua"
```

### 2. UDP Demo (NTP Time Query)
Connects to time.google.com via UDP and requests the current time.

```bash
luajit "Socket UDP Demo.lua"
```

### 3. ICMP Demo (Ping)
Sends a raw ICMP Echo Request to 8.8.8.8.
**Note:** This script uses LuaJIT FFI to create a raw socket, which requires root privileges on macOS.

```bash
sudo luajit "Socket ICMP Demo.lua"
```

## Compilation Details

The `socket.so` library was compiled from the [lunarmodules/luasocket](https://github.com/lunarmodules/luasocket) repository (version 3.1.0) specifically for LuaJIT 2.1 on macOS.

Build command used:
```bash
make macosx LUAV=5.1 LUAINC_macosx=/usr/local/include/luajit-2.1
```
