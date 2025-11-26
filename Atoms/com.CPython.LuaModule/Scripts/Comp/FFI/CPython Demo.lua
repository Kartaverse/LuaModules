
print("CPython Demo")
print("------------------------------------------------------------------------------------")

local ffi = require("ffi")
local cpython = require("cpython")

print("\nPython Version:")
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

print("\n\n------------------------------------------------------------------------------------")
print("Done")