local vrmesh = require("vrmesh")

print("VR Mesh Library Demo")
print("--------------------")

-- Create a new MeshFile instance
local meshFile = vrmesh.new()

-- Open the file for reading
local filename = "MVI_0398.vrmesh"
local res = meshFile:openRead(filename, vrmesh.FLAG_GENERATEMISSINGINDEX)

if res ~= vrmesh.NOERROR then
    print("Error opening file: " .. filename .. " Error code: " .. res)
    meshFile:destroy()
    return
end

print("Successfully opened " .. filename)

-- Get file header
local header, err = meshFile:getFileHeader()
if not header then
    print("Error getting file header: " .. err)
    meshFile:close()
    meshFile:destroy()
    return
end

print("File Header Info:")
print("  Tracks: " .. header.tracks)
print("  Frame Start: " .. header.frame_start)
print("  Frame End: " .. header.frame_end)
print("  Max Mesh Size: " .. header.max_mesh_size)
print("  Frame Time: " .. header.frame_time)
print("  Timescale: " .. header.timescale)

-- Read mesh info for a specific frame (e.g., the first frame)
local track = 0
local frame = header.frame_start
local info, err = meshFile:getMeshInfo(track, frame)

if not info then
    print("Error getting mesh info for track " .. track .. " frame " .. frame .. ": " .. err)
else
    print("Mesh Info for Track " .. track .. " Frame " .. frame .. ":")
    print("  Frame Start: " .. info.frameStart)
    print("  Frame End: " .. info.frameEnd)
    print("  Size: " .. info.size)
    print("  File Offset: " .. tostring(info.fileOffset))

    -- Read mesh data
    local meshData, size = meshFile:readMeshData(info.fileOffset, info.size)
    if not meshData then
        print("Error reading mesh data: " .. size) -- size contains error code here
    else
        print("Mesh Data Read Successfully:")
        print("  Format: " .. meshData.format)
        print("  Grid X: " .. meshData.grid_x)
        print("  Grid Y: " .. meshData.grid_y)
        print("  Data Size: " .. meshData.data_size)
        print("  Actual Read Size: " .. size)
    end
end

-- Close and destroy
meshFile:close()
meshFile:destroy()
print("--------------------")
print("Demo Completed")