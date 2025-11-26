-- Add the current directory to package.path so we can find zlib.lua
local current_dir = debug.getinfo(1).source:match("@?(.*/)") or "./"
package.path = current_dir .. "?.lua;" .. package.path

local zlib = require("zlib")

print("GZIP Compression Demo")
print("------------------------------------------------------------------------------------")
print("Zlib Version: " .. zlib.version())

-- Test Data
local original_text = "Hello, this is a test string for GZIP compression! " .. string.rep("Repeat this. ", 10)

local filename = comp:MapPath("Temp:/FFI/test_output.gz")
if not bmd.direxists("Temp:/FFI/") then
	bmd.createdir(comp:MapPath("Temp:/FFI/"))
end

print("\n--- GZIP File Test ---")
print("Original Text Length: " .. #original_text)

-- Write GZIP file
print("Writing to " .. tostring(filename))
local success, err = zlib.gz_write_file(filename, original_text)
if not success then
    print("Error writing file: " .. err)
    os.exit(1)
end
print("Write successful.")

-- Read GZIP file
print("Reading from " .. tostring(filename))
local decompressed_text, err = zlib.gz_read_file(filename)
if not decompressed_text then
    print("Error reading file: " .. err)
    os.exit(1)
end

print("Read successful.")
print("Decompressed Text Length: " .. #decompressed_text)

if original_text == decompressed_text then
    print("SUCCESS: Original and decompressed text match!")
else
    print("FAILURE: Text mismatch!")
end

-- Clean up
os.remove(filename)
print("Cleaned up " .. filename)

print("\n--- In-Memory GZIP Test (using deflate with windowBits=31) ---")
-- windowBits = 15 + 16 = 31 enables GZIP encoding
local compressed_data, err = zlib.deflate(original_text, nil, 31)
if not compressed_data then
    print("Compression failed: " .. err)
else
    print("Compressed size: " .. #compressed_data)
    
    -- Decompress using inflate with windowBits=31 (or 47 for auto-detect)
    local decompressed_mem, err = zlib.inflate(compressed_data, 31)
    if not decompressed_mem then
        print("Decompression failed: " .. err)
    else
        if original_text == decompressed_mem then
            print("SUCCESS: In-memory GZIP match!")
        else
            print("FAILURE: In-memory GZIP mismatch!")
        end
    end
end

print("------------------------------------------------------------------------------------")
