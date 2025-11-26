local stb = require("stb_image")
local ffi = require("ffi")

print("STB Image Demo")
print("--------------------")

-- Create a simple image in memory (Red, Green, Blue, White) 2x2
local width = 2
local height = 2
local channels = 3
local image_data = ffi.new("unsigned char[?]", width * height * channels)

-- Pixel 1: Red
image_data[0] = 255
image_data[1] = 0
image_data[2] = 0

-- Pixel 2: Green
image_data[3] = 0
image_data[4] = 255
image_data[5] = 0

-- Pixel 3: Blue
image_data[6] = 0
image_data[7] = 0
image_data[8] = 255

-- Pixel 4: White
image_data[9] = 255
image_data[10] = 255
image_data[11] = 255

local filename = comp:MapPath("Temp:/FFI/test_image.png")
if not bmd.direxists("Temp:/FFI/") then
	bmd.createdir(comp:MapPath("Temp:/FFI/"))
end
local stride = width * channels

print("Writing test image to " .. filename)
local res = stb.stbi_write_png(filename, width, height, channels, image_data, stride)

if res == 0 then
    print("Failed to write image")
    os.exit(1)
else
    print("Successfully wrote image")
end

print("Reading test image from " .. filename)
local x = ffi.new("int[1]")
local y = ffi.new("int[1]")
local n = ffi.new("int[1]")

local data = stb.stbi_load(filename, x, y, n, 0)

if data == nil then
    print("Failed to load image: " .. ffi.string(stb.stbi_failure_reason()))
    os.exit(1)
end

print("Image loaded successfully:")
print("Width: " .. x[0])
print("Height: " .. y[0])
print("Channels: " .. n[0])

-- Verify pixel data
print("Verifying pixel data...")
local success = true
for i = 0, (width * height * channels) - 1 do
    if data[i] ~= image_data[i] then
        print(string.format("Mismatch at index %d: expected %d, got %d", i, image_data[i], data[i]))
        success = false
    end
end

if success then
    print("Pixel data verification passed!")
else
    print("Pixel data verification failed!")
end

stb.stbi_image_free(data)
print("Memory freed")