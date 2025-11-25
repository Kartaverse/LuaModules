local ffi = require("ffi")

-- Define C structs and functions
ffi.cdef[[
    // Constants
    static const int MESHFILE_NOERROR = 0;
    static const int MESHFILE_ERROR_FILENOTFOUND = -1;
    static const int MESHFILE_ERROR_ALREADYOPEN = -2;
    static const int MESHFILE_ERROR_INVALIDHEADER = -3;
    static const int MESHFILE_ERROR_INVALIDINDEX = -4;
    static const int MESHFILE_ERROR_NODATA = -5;
    static const int MESHFILE_ERROR_FILECREATE = -6;
    static const int MESHFILE_ERROR_FILEWRITEHEADER = -7;
    static const int MESHFILE_ERROR_FILEWRITEDATA = -8;
    static const int MESHFILE_ERROR_INVALIDMODE = -9;
    static const int MESHFILE_ERROR_FILEWRITECLOSE = -10;
    static const int MESHFILE_ERROR_MESHNOTFOUND = -11;
    static const int MESHFILE_ERROR_READDATA = -12;
    static const int MESHFILE_ERROR_BUFFERSMALL = -13;
    static const int MESHFILE_ERROR_INVALIDHANDLE = -14;
    static const int MESHFILE_ERROR_INVALIDPARAMETER = -15;
    static const int MESHFILE_ERROR_FILENOTOPEN = -16;

    static const int MESHFILE_FLAG_GENERATEMISSINGINDEX = 1;

    // Structs
    typedef struct {
        uint32_t format;
        uint32_t grid_x;
        uint32_t grid_y;
        uint32_t data_size;
    } MeshDataBlock;

    typedef struct {
        uint32_t verflags;
        uint32_t tracks;
        uint32_t frame_start;
        uint32_t frame_end;
        uint32_t max_mesh_size;
        uint32_t frame_time;
        uint32_t timescale;
        uint32_t reserved[9];
    } MeshFileheaderBlock;

    // Types
    typedef void* FILE_HANDLE;
    typedef int32_t RESULT_CODE;
    typedef int64_t off_t;

    // Functions
    FILE_HANDLE meshfile_createFile(void);
    RESULT_CODE meshfile_destroyFile(FILE_HANDLE handle);
    RESULT_CODE meshfile_openRead(FILE_HANDLE handle, const char *filename, uint32_t flags);
    RESULT_CODE meshfile_getMeshInfo(FILE_HANDLE handle, uint32_t track, uint32_t frame, uint32_t *frameStart, uint32_t *frameEnd, uint32_t *size, off_t *fileOffset);
    RESULT_CODE meshfile_readMeshData(FILE_HANDLE handle, void *mesh, uint32_t *size, MeshDataBlock *data, off_t fileOffset);
    RESULT_CODE meshfile_close(FILE_HANDLE handle);
    RESULT_CODE meshfile_getFileheader(FILE_HANDLE handle, MeshFileheaderBlock *header, uint32_t *size);
    RESULT_CODE meshfile_openWrite(FILE_HANDLE handle, const char *filename, uint32_t tracks, uint32_t flags);
    RESULT_CODE meshfile_addMesh(FILE_HANDLE handle, uint32_t track, uint32_t frameStart, uint32_t frameEnd, MeshDataBlock *data, void *mesh);
    RESULT_CODE meshfile_setTimeData(FILE_HANDLE handle, uint32_t frameTime, uint32_t frameScale);
]]

-- Helper to find the directory of the current script
local function get_script_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)") or "./"
end

-- Load the shared library
local lib_path = get_script_path() .. "vrmesh_ffi.so"
local vrmesh_lib = ffi.load(lib_path)

-- Module table
local M = {}

-- Expose constants
M.NOERROR = 0
M.ERROR_FILENOTFOUND = -1
M.ERROR_ALREADYOPEN = -2
M.ERROR_INVALIDHEADER = -3
M.ERROR_INVALIDINDEX = -4
M.ERROR_NODATA = -5
M.ERROR_FILECREATE = -6
M.ERROR_FILEWRITEHEADER = -7
M.ERROR_FILEWRITEDATA = -8
M.ERROR_INVALIDMODE = -9
M.ERROR_FILEWRITECLOSE = -10
M.ERROR_MESHNOTFOUND = -11
M.ERROR_READDATA = -12
M.ERROR_BUFFERSMALL = -13
M.ERROR_INVALIDHANDLE = -14
M.ERROR_INVALIDPARAMETER = -15
M.ERROR_FILENOTOPEN = -16

M.FLAG_GENERATEMISSINGINDEX = 1

-- Wrapper class for MeshFile
local MeshFile = {}
MeshFile.__index = MeshFile

function M.new()
    local self = setmetatable({}, MeshFile)
    self.handle = vrmesh_lib.meshfile_createFile()
    return self
end

function MeshFile:destroy()
    if self.handle then
        vrmesh_lib.meshfile_destroyFile(self.handle)
        self.handle = nil
    end
end

function MeshFile:openRead(filename, flags)
    flags = flags or 0
    return vrmesh_lib.meshfile_openRead(self.handle, filename, flags)
end

function MeshFile:close()
    return vrmesh_lib.meshfile_close(self.handle)
end

function MeshFile:getFileHeader()
    local header = ffi.new("MeshFileheaderBlock")
    local size = ffi.new("uint32_t[1]")
    size[0] = ffi.sizeof("MeshFileheaderBlock")
    local res = vrmesh_lib.meshfile_getFileheader(self.handle, header, size)
    
    if res == M.NOERROR then
        return {
            verflags = header.verflags,
            tracks = header.tracks,
            frame_start = header.frame_start,
            frame_end = header.frame_end,
            max_mesh_size = header.max_mesh_size,
            frame_time = header.frame_time,
            timescale = header.timescale
        }
    else
        return nil, res
    end
end

function MeshFile:getMeshInfo(track, frame)
    local frameStart = ffi.new("uint32_t[1]")
    local frameEnd = ffi.new("uint32_t[1]")
    local size = ffi.new("uint32_t[1]")
    local fileOffset = ffi.new("off_t[1]")
    
    local res = vrmesh_lib.meshfile_getMeshInfo(self.handle, track, frame, frameStart, frameEnd, size, fileOffset)
    
    if res == M.NOERROR then
        return {
            frameStart = frameStart[0],
            frameEnd = frameEnd[0],
            size = size[0],
            fileOffset = fileOffset[0]
        }
    else
        return nil, res
    end
end

function MeshFile:readMeshData(fileOffset, bufferSize)
    local mesh = ffi.new("uint8_t[?]", bufferSize)
    local size = ffi.new("uint32_t[1]", bufferSize)
    local data = ffi.new("MeshDataBlock")
    
    local res = vrmesh_lib.meshfile_readMeshData(self.handle, mesh, size, data, fileOffset)
    
    if res == M.NOERROR then
        return {
            format = data.format,
            grid_x = data.grid_x,
            grid_y = data.grid_y,
            data_size = data.data_size,
            mesh_data = mesh -- This returns the cdata pointer, user might need to convert to string if needed
        }, size[0]
    else
        return nil, res
    end
end

function MeshFile:openWrite(filename, tracks, flags)
    flags = flags or 0
    return vrmesh_lib.meshfile_openWrite(self.handle, filename, tracks, flags)
end

function MeshFile:setTimeData(frameTime, frameScale)
    return vrmesh_lib.meshfile_setTimeData(self.handle, frameTime, frameScale)
end

function MeshFile:addMesh(track, frameStart, frameEnd, format, grid_x, grid_y, meshDataStr)
    local data = ffi.new("MeshDataBlock")
    data.format = format
    data.grid_x = grid_x
    data.grid_y = grid_y
    data.data_size = #meshDataStr
    
    -- Cast string to void*
    local meshPtr = ffi.cast("void*", meshDataStr)
    
    return vrmesh_lib.meshfile_addMesh(self.handle, track, frameStart, frameEnd, data, meshPtr)
end

return M