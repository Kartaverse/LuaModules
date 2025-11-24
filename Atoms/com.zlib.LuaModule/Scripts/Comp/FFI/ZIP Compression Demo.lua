-- Add the current directory to package.path so we can find zlib.lua
local current_dir = debug.getinfo(1).source:match("@?(.*/)") or "./"
package.path = current_dir .. "?.lua;" .. package.path

local zlib = require("zlib")

print("Zlib Version: " .. zlib.version())

local original_text = "This is a test string for raw Deflate compression. " .. string.rep("Repeating content to ensure compression works well. ", 5)

print("\n--- Raw Deflate Test (ZIP Algorithm) ---")
print("Original Text Length: " .. #original_text)

-- Compress using raw deflate (windowBits = -15)
-- Negative windowBits suppresses the zlib header/trailer, producing raw deflate data
local compressed_data, err = zlib.deflate(original_text, nil, -15)

if not compressed_data then
    print("Compression failed: " .. err)
    os.exit(1)
end

print("Compressed Data Length: " .. #compressed_data)
print("Compression Ratio: " .. string.format("%.2f%%", (#compressed_data / #original_text) * 100))

-- Decompress using raw inflate (windowBits = -15)
local decompressed_text, err = zlib.inflate(compressed_data, -15)

if not decompressed_text then
    print("Decompression failed: " .. err)
    os.exit(1)
end

print("Decompressed Text Length: " .. #decompressed_text)

if original_text == decompressed_text then
    print("SUCCESS: Original and decompressed text match!")
else
    print("FAILURE: Text mismatch!")
end

print("\n--- Zlib Wrapper Test (Default) ---")
-- Standard zlib wrapper (windowBits = 15)
local zlib_compressed, err = zlib.deflate(original_text)
if zlib_compressed then
    print("Zlib Compressed Length: " .. #zlib_compressed)
    local zlib_decompressed, err = zlib.inflate(zlib_compressed)
    if zlib_decompressed == original_text then
        print("SUCCESS: Zlib wrapper match!")
    else
        print("FAILURE: Zlib wrapper mismatch!")
    end
else
    print("Zlib compression failed: " .. err)
end