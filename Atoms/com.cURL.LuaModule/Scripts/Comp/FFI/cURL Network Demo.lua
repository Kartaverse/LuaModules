local ffi = require("ffi")
local curl = require("curl")

print("cURL Network Demo")
print("------------------------------------------------------------------------------------")

-- Helper to check for errors
local function check(code)
    if code ~= curl.CURLE_OK then
        local err = ffi.string(curl.curl_easy_strerror(code))
        error("cURL error: " .. err)
    end
end

-- Callback to write response data to a Lua string
local function write_callback(ptr, size, nmemb, userdata)
    local bytes = size * nmemb
    local str = ffi.string(ptr, bytes)
    local t = ffi.cast("void**", userdata)
    -- We assume userdata is a pointer to a Lua table (or similar structure) 
    -- but passing Lua objects to C callbacks requires careful handling (e.g. jit.off or IDs).
    -- For simplicity in this demo, we'll just print to stdout or use a global buffer if needed.
    -- However, a better pattern for FFI callbacks is to use an upvalue or a global registry.
    
    -- Since we can't easily pass Lua tables through void* without a registry, 
    -- we will just print the output for this demo.
    io.write(str)
    return bytes
end

-- Cast the callback to a C function pointer
local write_cb = ffi.cast("size_t (*)(char*, size_t, size_t, void*)", write_callback)

print("Version: " .. ffi.string(curl.curl_version()))

-- 1. Simple GET Request
print("\nPerforming GET Request")
local easy = curl.curl_easy_init()
if easy ~= nil then
    check(curl.curl_easy_setopt(easy, curl.CURLOPT_URL, "https://httpbin.org/get"))
    -- Cast the callback to void* for the vararg function, or ensure the type matches exactly what C expects
    -- However, for varargs, LuaJIT usually handles pointers correctly.
    -- The crash might be due to the callback itself or missing global init.
    check(curl.curl_easy_setopt(easy, curl.CURLOPT_WRITEFUNCTION, write_cb))
    check(curl.curl_easy_setopt(easy, curl.CURLOPT_USERAGENT, "LuaJIT-cURL-Agent/1.0"))
    
    -- Enable SSL verification (using system CA bundle usually works, or provide path)
    check(curl.curl_easy_setopt(easy, curl.CURLOPT_SSL_VERIFYPEER, ffi.cast("long", 1)))
    check(curl.curl_easy_setopt(easy, curl.CURLOPT_SSL_VERIFYHOST, ffi.cast("long", 2)))

    local res = curl.curl_easy_perform(easy)
    check(res)

    curl.curl_easy_cleanup(easy)
else
    print("Failed to init curl")
end

-- 2. POST Request with Headers
print("\n\nPerforming POST Request")
easy = curl.curl_easy_init()
if easy ~= nil then
    local url = "https://httpbin.org/post"
    local post_data = '{"name": "LuaJIT", "type": "FFI"}'
    
    check(curl.curl_easy_setopt(easy, curl.CURLOPT_URL, url))
    check(curl.curl_easy_setopt(easy, curl.CURLOPT_POST, ffi.cast("long", 1)))
    check(curl.curl_easy_setopt(easy, curl.CURLOPT_POSTFIELDS, post_data))
    check(curl.curl_easy_setopt(easy, curl.CURLOPT_POSTFIELDSIZE, ffi.cast("long", #post_data)))
    check(curl.curl_easy_setopt(easy, curl.CURLOPT_WRITEFUNCTION, write_cb))
    
    -- Add headers
    local headers = nil
    headers = curl.curl_slist_append(headers, "Content-Type: application/json")
    headers = curl.curl_slist_append(headers, "Accept: application/json")
    check(curl.curl_easy_setopt(easy, curl.CURLOPT_HTTPHEADER, headers))

    local res = curl.curl_easy_perform(easy)
    check(res)

    -- Cleanup
    curl.curl_slist_free_all(headers)
    curl.curl_easy_cleanup(easy)
else
    print("Failed to init curl")
end

print("\n\n------------------------------------------------------------------------------------")
print("Done")

