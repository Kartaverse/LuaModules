local ffi = require("ffi")

-- Helper to find the directory of the current module
local function get_script_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)") or "./"
end

local script_path = get_script_path()
local lib_path = script_path .. "perl_ffi.so"

-- Load the Perl shared library
local perl_lib = ffi.load(lib_path)

-- Define the Perl API
ffi.cdef[[
    typedef struct PerlInterpreter PerlInterpreter;
    
    PerlInterpreter* perl_alloc();
    void perl_construct(PerlInterpreter* my_perl);
    int perl_parse(PerlInterpreter* my_perl, void* xsinit, int argc, char** argv, char** env);
    int perl_run(PerlInterpreter* my_perl);
    void perl_destruct(PerlInterpreter* my_perl);
    void perl_free(PerlInterpreter* my_perl);
    
    // Helper for evaluating strings
    // Note: Perl's API is complex and often macro-heavy. 
    // We might need to bind to specific functions like Perl_eval_pv if they are exported.
    // Checking exported symbols might be necessary if macros hide the real function names.
]]

-- The Perl module table
local M = {}

function M.new()
    local my_perl = perl_lib.perl_alloc()
    if my_perl == nil then
        return nil, "Failed to allocate Perl interpreter"
    end
    perl_lib.perl_construct(my_perl)
    
    local self = {
        _perl = my_perl,
        lib = perl_lib
    }
    
    -- Add destructor
    ffi.gc(self._perl, function(p)
        perl_lib.perl_destruct(p)
        perl_lib.perl_free(p)
    end)
    
    setmetatable(self, { __index = M })
    return self
end

function M.run(self, args)
    -- args should be a table of strings, e.g., {"perl", "-e", "print 'Hello'"}
    -- We need to convert this to char**
    local argc = #args
    local argv = ffi.new("char*[?]", argc + 1)
    for i, v in ipairs(args) do
        argv[i-1] = ffi.new("char[?]", #v + 1, v)
    end
    argv[argc] = nil
    
    local result = perl_lib.perl_parse(self._perl, nil, argc, argv, nil)
    if result ~= 0 then
        return result, "perl_parse failed"
    end
    
    return perl_lib.perl_run(self._perl)
end

return M