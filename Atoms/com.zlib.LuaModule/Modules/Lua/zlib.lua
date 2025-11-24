local ffi = require("ffi")

-- Define the C types and functions from zlib.h
ffi.cdef[[
    typedef void (*alloc_func)(void *opaque, unsigned int items, unsigned int size);
    typedef void (*free_func)(void *opaque, void *address);

    typedef struct z_stream_s {
        const unsigned char *next_in;
        unsigned int     avail_in;
        unsigned long    total_in;

        unsigned char    *next_out;
        unsigned int     avail_out;
        unsigned long    total_out;

        const char *msg;
        void *state;

        alloc_func zalloc;
        free_func  zfree;
        void     *opaque;

        int     data_type;
        unsigned long   adler;
        unsigned long   reserved;
    } z_stream;

    typedef z_stream *z_streamp;

    typedef struct gzFile_s *gzFile;

    const char * zlibVersion(void);
    
    int deflateInit_(z_streamp strm, int level, const char *version, int stream_size);
    int deflate(z_streamp strm, int flush);
    int deflateEnd(z_streamp strm);
    
    int inflateInit_(z_streamp strm, const char *version, int stream_size);
    int inflate(z_streamp strm, int flush);
    int inflateEnd(z_streamp strm);

    int deflateInit2_(z_streamp strm, int level, int method, int windowBits, int memLevel, int strategy, const char *version, int stream_size);
    int inflateInit2_(z_streamp strm, int windowBits, const char *version, int stream_size);

    unsigned long crc32(unsigned long crc, const unsigned char *buf, unsigned int len);
    
    // Gzip file access functions
    gzFile gzopen(const char *path, const char *mode);
    int gzwrite(gzFile file, const void *buf, unsigned len);
    int gzread(gzFile file, void *buf, unsigned len);
    int gzclose(gzFile file);
    const char * gzerror(gzFile file, int *errnum);
    int gzeof(gzFile file);
]]

-- Helper to find the shared library in the same directory as this script
local function load_zlib()
    local path = package.searchpath("zlib", package.path)
    if not path then
        error("Could not find zlib.lua in package.path")
    end
    
    -- Get directory of the current file
    local dir = path:match("^(.*[/\\])")
    local lib_path = dir .. "zlib.so"
    
    return ffi.load(lib_path)
end

local zlib = load_zlib()
local M = {}

-- Constants
M.Z_NO_FLUSH      = 0
M.Z_PARTIAL_FLUSH = 1
M.Z_SYNC_FLUSH    = 2
M.Z_FULL_FLUSH    = 3
M.Z_FINISH        = 4
M.Z_BLOCK         = 5
M.Z_TREES         = 6

M.Z_OK            = 0
M.Z_STREAM_END    = 1
M.Z_NEED_DICT     = 2
M.Z_ERRNO         = -1
M.Z_STREAM_ERROR  = -2
M.Z_DATA_ERROR    = -3
M.Z_MEM_ERROR     = -4
M.Z_BUF_ERROR     = -5
M.Z_VERSION_ERROR = -6

M.Z_NO_COMPRESSION         = 0
M.Z_BEST_SPEED             = 1
M.Z_BEST_COMPRESSION       = 9
M.Z_DEFAULT_COMPRESSION    = -1

M.Z_FILTERED            = 1
M.Z_HUFFMAN_ONLY        = 2
M.Z_RLE                 = 3
M.Z_FIXED               = 4
M.Z_DEFAULT_STRATEGY    = 0

M.Z_BINARY   = 0
M.Z_TEXT     = 1
M.Z_UNKNOWN  = 2

M.Z_DEFLATED = 8

-- Helper to get zlib version string
function M.version()
    return ffi.string(zlib.zlibVersion())
end

-- Helper to calculate CRC32
function M.crc32(data, seed)
    seed = seed or 0
    return zlib.crc32(seed, data, #data)
end

-- Compression (Deflate)
function M.deflate(data, level, windowBits)
    level = level or M.Z_DEFAULT_COMPRESSION
    windowBits = windowBits or 15 -- 15 for zlib, -15 for raw deflate, 31 for gzip
    
    local strm = ffi.new("z_stream")
    strm.zalloc = nil
    strm.zfree = nil
    strm.opaque = nil
    
    -- Initialize deflate
    -- We use deflateInit2_ directly to support windowBits
    local version = zlib.zlibVersion()
    local ret = zlib.deflateInit2_(strm, level, M.Z_DEFLATED, windowBits, 8, M.Z_DEFAULT_STRATEGY, version, ffi.sizeof("z_stream"))
    
    if ret ~= M.Z_OK then
        return nil, "deflateInit failed: " .. ret
    end
    
    -- Set input
    local data_ptr = ffi.cast("const unsigned char*", data)
    strm.next_in = data_ptr
    strm.avail_in = #data
    
    -- Prepare output buffer
    -- Initial guess: input size + overhead. We'll grow if needed, but for simplicity in this demo we'll alloc a large enough buffer or chunks.
    -- A simple strategy: allocate a buffer slightly larger than input.
    local chunk_size = 16384
    local out_buffer = {}
    local out_chunk = ffi.new("unsigned char[?]", chunk_size)
    
    while true do
        strm.next_out = out_chunk
        strm.avail_out = chunk_size
        
        ret = zlib.deflate(strm, M.Z_FINISH)
        
        local have = chunk_size - strm.avail_out
        if have > 0 then
            table.insert(out_buffer, ffi.string(out_chunk, have))
        end
        
        if ret == M.Z_STREAM_END then
            break
        elseif ret ~= M.Z_OK then
            zlib.deflateEnd(strm)
            return nil, "deflate failed: " .. ret
        end
    end
    
    zlib.deflateEnd(strm)
    return table.concat(out_buffer)
end

-- Decompression (Inflate)
function M.inflate(data, windowBits)
    windowBits = windowBits or 15 -- 15 for zlib, -15 for raw deflate, 31 for gzip (auto-detect)
    
    local strm = ffi.new("z_stream")
    strm.zalloc = nil
    strm.zfree = nil
    strm.opaque = nil
    strm.avail_in = 0
    strm.next_in = nil
    
    local version = zlib.zlibVersion()
    local ret = zlib.inflateInit2_(strm, windowBits, version, ffi.sizeof("z_stream"))
    
    if ret ~= M.Z_OK then
        return nil, "inflateInit failed: " .. ret
    end
    
    strm.next_in = ffi.cast("const unsigned char*", data)
    strm.avail_in = #data
    
    local chunk_size = 16384
    local out_buffer = {}
    local out_chunk = ffi.new("unsigned char[?]", chunk_size)
    
    while true do
        strm.next_out = out_chunk
        strm.avail_out = chunk_size
        
        ret = zlib.inflate(strm, M.Z_NO_FLUSH)
        
        local have = chunk_size - strm.avail_out
        if have > 0 then
            table.insert(out_buffer, ffi.string(out_chunk, have))
        end
        
        if ret == M.Z_STREAM_END then
            break
        elseif ret ~= M.Z_OK then
            zlib.inflateEnd(strm)
            return nil, "inflate failed: " .. ret
        end
    end
    
    zlib.inflateEnd(strm)
    return table.concat(out_buffer)
end

-- GZIP File Writing
function M.gz_write_file(filename, data)
    local mode = "wb"
    local file = zlib.gzopen(filename, mode)
    if file == nil then
        return false, "Could not open file for writing"
    end
    
    local bytes_written = zlib.gzwrite(file, data, #data)
    zlib.gzclose(file)
    
    if bytes_written ~= #data then
        return false, "Failed to write all data"
    end
    
    return true
end

-- GZIP File Reading
function M.gz_read_file(filename)
    local mode = "rb"
    local file = zlib.gzopen(filename, mode)
    if file == nil then
        return nil, "Could not open file for reading"
    end
    
    local buffer_size = 16384
    local buffer = ffi.new("char[?]", buffer_size)
    local result = {}
    
    while true do
        local bytes_read = zlib.gzread(file, buffer, buffer_size)
        if bytes_read > 0 then
            table.insert(result, ffi.string(buffer, bytes_read))
        elseif bytes_read == 0 then
            break -- EOF
        else
            local errnum = ffi.new("int[1]")
            local errmsg = zlib.gzerror(file, errnum)
            zlib.gzclose(file)
            return nil, "gzread error: " .. ffi.string(errmsg)
        end
    end
    
    zlib.gzclose(file)
    return table.concat(result)
end

return M