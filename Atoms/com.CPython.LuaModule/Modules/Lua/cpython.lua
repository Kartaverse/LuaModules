local ffi = require("ffi")

-- Get the directory of the current script
local function get_script_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)") or "./"
end

local script_path = get_script_path()
local lib_path = script_path .. "cpython.so"

-- Load the CPython shared library
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

return lib