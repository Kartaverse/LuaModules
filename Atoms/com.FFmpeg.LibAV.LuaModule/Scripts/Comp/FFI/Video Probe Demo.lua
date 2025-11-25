-- Test script for LibAV Lua Module
local LibAV = require("libav")

-- Helper to print tables
local function print_table(t, indent)
    indent = indent or ""
    for k, v in pairs(t) do
        if type(v) == "table" then
            print(indent .. k .. ":")
            print_table(v, indent .. "  ")
        else
            print(indent .. k .. ": " .. tostring(v))
        end
    end
end

local function Probe(filepath)

    print("Video Probe Demo")
    print("--------------------")

    print("Opening video: " .. tostring(filepath))
    local video, err = LibAV.open(filepath)

    if not video then
        print("Error opening video:", err)
        return
    end

    print("\n--- Metadata ---")
    local meta = video:get_metadata()
    print_table(meta)

    print("\n--- Tracks ---")
    local tracks = video:get_tracks()
    for _, track in ipairs(tracks) do
        print("Track " .. track.index .. ":")
        print_table(track, "  ")
    end

    print("\n--- Timecode ---")
    local tc = video:get_timecode()
    print("Timecode: " .. tostring(tc))

    print("\n--- Frame Extraction ---")
    -- Try to get a frame at 1.0 second
    local buffer, w, h, stride = video:get_frame_at_time(1.0)
    if buffer then
        print(string.format("Got frame: %dx%d, stride: %d", w, h, stride))
        print("Buffer address: " .. tostring(buffer))
    else
        print("Failed to get frame")
    end

    video:close()
    print("\nClosed video.")
    
    print("--------------------")
    print("Demo Completed")
end

local filename = comp:MapPath("Reactor:/Deploy/Comps/Kartaverse/WarpStitch/WarpStitch Under the Bridge/Media/CameraA.mp4")
Probe(filename)
