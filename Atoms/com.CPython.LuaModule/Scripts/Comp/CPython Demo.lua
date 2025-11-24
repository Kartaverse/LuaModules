-- Add the current directory to the package path so we can require 'cpython'
package.path = package.path .. ";./?.lua"

local cpython = require("cpython")
local ffi = require("ffi")

-- Unset PYTHONPATH to avoid conflicts with system Python
ffi.cdef[[
    int unsetenv(const char *name);
]]
ffi.C.unsetenv("PYTHONPATH")
ffi.C.unsetenv("PYTHONHOME")

print("Initializing Python...")
-- Set PYTHONPATH to include Lib and the build directory for compiled modules
local script_path = debug.getinfo(1, "S").source:sub(2):match("(.*/)") or "./"
local lib_path = script_path .. "cpython/Lib"
local build_lib_path = script_path .. "cpython/build/lib.macosx-26.1-arm64-3.11"
local full_path = lib_path .. ":" .. build_lib_path

local ffi = require("ffi")
local wchar_path = ffi.new("wchar_t[?]", #full_path + 1)
for i = 1, #full_path do
    wchar_path[i-1] = string.byte(full_path, i)
end
wchar_path[#full_path] = 0

cpython.Py_SetPath(wchar_path)
cpython.Py_Initialize()

print("Python Version:")
local version = ffi.string(cpython.Py_GetVersion())
print(version)

print("\nRunning Python code:")
local code = [[
import sys
print(f"Hello from Python! sys.version: {sys.version}")
print(f"sys.path: {sys.path}")
]]
cpython.PyRun_SimpleString(code)

print("\nFinalizing Python...")
cpython.Py_Finalize()
print("Done.")