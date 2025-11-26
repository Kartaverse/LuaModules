local ffi = require("ffi")
print("\nInitializing Python...")

-- Helper to find the shared library in the same directory as this script
local function get_script_path()
	local str = debug.getinfo(2, "S").source:sub(2)
	return str:match("(.*/)") or "./"
end

-- Load the CPython shared library
local lib_path = get_script_path() .. tostring("cpython.so")
print("\nPython FFI Path: ")
print(lib_path)
local lib = ffi.load(lib_path)

-- Define the C interface
ffi.cdef[[
	void Py_Initialize();
	void Py_Finalize();
	int PyRun_SimpleString(const char *command);
	void Py_SetPythonHome(const wchar_t *home);
	void Py_SetPath(const wchar_t *path);
	const char *Py_GetVersion();
	int unsetenv(const char *name);
]]

-- Unset PYTHONPATH to avoid conflicts with system Python
ffi.C.unsetenv("PYTHONPATH")
ffi.C.unsetenv("PYTHONHOME")
-- print("Clearing Environment Variables:")
-- print("PYTHONPATH")
-- print("PYTHONHOME")

-- Set PYTHONPATH to include Lib and the build directory for compiled modules
local cpython_lib_path = get_script_path() .. tostring("cpython/Lib")
local cpython_build_lib_path = get_script_path() .. tostring("cpython/lib.macosx-26.1-arm64-3.11")
local full_path = cpython_lib_path .. ":" .. cpython_build_lib_path
local wchar_path = ffi.new("wchar_t[?]", #full_path + 1)
for i = 1, #full_path do
	wchar_path[i-1] = string.byte(full_path, i)
end
wchar_path[#full_path] = 0

print("\nPython SetPath: ")
print(full_path)

lib.Py_SetPath(wchar_path)
lib.Py_Initialize()

return lib