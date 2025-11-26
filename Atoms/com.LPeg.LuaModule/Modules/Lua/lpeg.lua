local ffi = require("ffi")

-- 1. Determine the path of this module
local function get_script_path()
    local info = debug.getinfo(1, "S")
    local source = info.source
    if source:sub(1, 1) == "@" then
        return source:sub(2):match("(.*/)")
    else
        return "./"
    end
end

local path = get_script_path()
local lib_path = path .. "lpeg_ffi.so"

-- 2. Load the shared library
local lpeg_lib = ffi.load(lib_path)

-- 3. Define the initialization function
ffi.cdef[[
    int luaopen_lpeg(void *L);
]]

-- 4. Helper to get lua_State
local function get_L()
    local co = coroutine.running()
    if not co then
        -- If main thread (nil in 5.1/JIT), we need to wrap in a coroutine to get the pointer
        -- or use a different method. But wait, if we are in main thread, we can't get the pointer easily.
        -- Let's try to create a dummy coroutine just to get the pointer? 
        -- No, that gives us the coroutine's L, not the main L.
        -- But luaopen_lpeg registers to the registry/global, which is shared.
        -- So we can use a temporary coroutine to initialize the library!
        local L
        local c = coroutine.create(function()
            local cc = coroutine.running()
            local s = tostring(cc)
            local addr = tonumber(s:match("0x(%x+)"), 16)
            L = ffi.cast("void *", addr)
        end)
        coroutine.resume(c)
        return L
    else
        local s = tostring(co)
        local addr = tonumber(s:match("0x(%x+)"), 16)
        return ffi.cast("void *", addr)
    end
end

local L = get_L()

-- 5. Call the initialization function
-- This will register the 'lpeg' module in package.loaded and global 'lpeg'
lpeg_lib.luaopen_lpeg(L)

-- 6. Return the module
-- Since luaopen_lpeg sets the global 'lpeg' (in 5.1/JIT via luaL_register), we can return it.
-- Also check package.loaded.lpeg
return package.loaded.lpeg or _G.lpeg