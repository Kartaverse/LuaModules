-- LibAV Lua Module for DaVinci Resolve (FFmpeg 6.0)
local ffi = require("ffi")

-- ============================================================================
-- 1. FFI Definitions (FFmpeg 6.0)
-- ============================================================================

ffi.cdef[[
    // Basic Types
    typedef long long int64_t;
    typedef unsigned char uint8_t;
    typedef int int32_t;
    
    // Forward Declarations
    typedef struct AVClass AVClass;
    
    // Error Codes
    int av_strerror(int errnum, char *errbuf, size_t errbuf_size);

    // Rational
    typedef struct AVRational {
        int num;
        int den;
    } AVRational;

    // Dictionary
    typedef struct AVDictionaryEntry {
        char *key;
        char *value;
    } AVDictionaryEntry;

    typedef struct AVDictionary AVDictionary;

    AVDictionaryEntry *av_dict_get(const AVDictionary *m, const char *key, const AVDictionaryEntry *prev, int flags);
    int av_dict_count(const AVDictionary *m);

    // Enums
    enum AVCodecID {
        AV_CODEC_ID_NONE = 0,
        AV_CODEC_ID_H264 = 27,
    };

    enum AVMediaType {
        AVMEDIA_TYPE_UNKNOWN = -1,
        AVMEDIA_TYPE_VIDEO,
        AVMEDIA_TYPE_AUDIO,
        AVMEDIA_TYPE_DATA,
        AVMEDIA_TYPE_SUBTITLE,
        AVMEDIA_TYPE_ATTACHMENT,
        AVMEDIA_TYPE_NB
    };

    enum AVPixelFormat {
        AV_PIX_FMT_NONE = -1,
        AV_PIX_FMT_YUV420P = 0,
        AV_PIX_FMT_RGB24 = 2,
        AV_PIX_FMT_RGBA = 26,
    };
    
    enum AVDiscard {
        AVDISCARD_NONE    =-16,
        AVDISCARD_DEFAULT =  0,
        AVDISCARD_NONREF  =  8,
        AVDISCARD_BIDIR   = 16,
        AVDISCARD_NONINTRA= 24,
        AVDISCARD_NONKEY  = 32,
        AVDISCARD_ALL     = 48,
    };

    // Codec Parameters
    typedef struct AVCodecParameters {
        enum AVMediaType codec_type;
        enum AVCodecID   codec_id;
        uint32_t         codec_tag;
        uint8_t *extradata;
        int      extradata_size;
        int      format;
        int64_t  bit_rate;
        int      bits_per_coded_sample;
        int      bits_per_raw_sample;
        int      profile;
        int      level;
        int      width;
        int      height;
        AVRational sample_aspect_ratio;
        int      field_order;
        int      color_range;
        int      color_primaries;
        int      color_trc;
        int      color_space;
        int      chroma_location;
        int      video_delay;
        uint64_t channel_layout;
        int      channels;
        int      sample_rate;
        int      block_align;
        int      frame_size;
        int      initial_padding;
        int      trailing_padding;
        int      seek_preroll;
    } AVCodecParameters;

    // Packet (Moved before AVStream)
    typedef struct AVPacket {
        void *buf; // AVBufferRef
        int64_t pts;
        int64_t dts;
        uint8_t *data;
        int   size;
        int   stream_index;
        int   flags;
        void *side_data;
        int   side_data_elems;
        int64_t duration;
        int64_t pos;
        void *opaque;
        void *opaque_ref;
        AVRational time_base;
    } AVPacket;

    // Stream
    typedef struct AVStream {
        uint8_t pad[256]; // Padding to cover enough space, we access manually
    } AVStream;

    // Format Context
    typedef struct AVFormatContext {
        const AVClass *av_class;
        struct AVInputFormat *iformat;
        struct AVOutputFormat *oformat;
        void *priv_data;
        void *pb; // AVIOContext
        int ctx_flags;
        unsigned int nb_streams;
        AVStream **streams;
        char filename[1024];
        int64_t start_time;
        int64_t duration;
        int64_t bit_rate;
        unsigned int packet_size;
        int max_delay;
        int flags;
        int64_t probesize;
        int64_t max_analyze_duration;
        const uint8_t *key;
        int keylen;
        unsigned int nb_programs;
        void **programs;
        enum AVCodecID video_codec_id;
        enum AVCodecID audio_codec_id;
        enum AVCodecID subtitle_codec_id;
        unsigned int max_index_size;
        unsigned int max_picture_buffer;
        unsigned int nb_chapters;
        void **chapters;
        AVDictionary *metadata;
        int64_t start_time_realtime;
        int fps_probe_size;
        int error_recognition;
    } AVFormatContext;

    // Codec
    typedef struct AVCodec {
        const char *name;
        const char *long_name;
        enum AVMediaType type;
        enum AVCodecID id;
        int capabilities;
    } AVCodec;

    // Codec Context
    typedef struct AVCodecContext {
        const AVClass *av_class;
        int log_level_offset;
        enum AVMediaType codec_type;
        const AVCodec *codec;
        char codec_name[32];
        enum AVCodecID codec_id;
        unsigned int codec_tag;
        unsigned int stream_codec_tag;
        void *priv_data;
        struct AVCodecInternal *internal;
        void *opaque;
        int64_t bit_rate;
        int bit_rate_tolerance;
        int global_quality;
        int compression_level;
        int flags;
        int flags2;
        uint8_t *extradata;
        int extradata_size;
        AVRational time_base;
        int ticks_per_frame;
        int delay;
        int width, height;
        int coded_width, coded_height;
        int gop_size;
        enum AVPixelFormat pix_fmt;
    } AVCodecContext;
    
    // Frame
    typedef struct AVFrame {
        uint8_t *data[8];
        int linesize[8];
        uint8_t **extended_data;
        int width, height;
        int nb_samples;
        int format;
        int key_frame;
        int pict_type;
        AVRational sample_aspect_ratio;
        int64_t pts;
        int64_t pkt_dts;
        AVRational time_base;
    } AVFrame;

    // Functions - libavformat
    int avformat_open_input(AVFormatContext **ps, const char *url, void *fmt, AVDictionary **options);
    int avformat_find_stream_info(AVFormatContext *ic, AVDictionary **options);
    void avformat_close_input(AVFormatContext **s);
    int av_read_frame(AVFormatContext *s, AVPacket *pkt);
    int av_seek_frame(AVFormatContext *s, int stream_index, int64_t timestamp, int flags);
    void av_dump_format(AVFormatContext *ic, int index, const char *url, int is_output);
    AVFormatContext *avformat_alloc_context(void);
    struct AVStream *avformat_new_stream(AVFormatContext *s, const struct AVCodec *c);
    void avformat_free_context(AVFormatContext *s);

    // Functions - libavcodec
    AVCodec *avcodec_find_decoder(enum AVCodecID id);
    AVCodecContext *avcodec_alloc_context3(const AVCodec *codec);
    int avcodec_parameters_to_context(AVCodecContext *codec, const AVCodecParameters *par);
    int avcodec_open2(AVCodecContext *avctx, const AVCodec *codec, AVDictionary **options);
    void avcodec_free_context(AVCodecContext **avctx);
    
    AVPacket *av_packet_alloc(void);
    void av_packet_free(AVPacket **pkt);
    void av_packet_unref(AVPacket *pkt);

    AVFrame *av_frame_alloc(void);
    void av_frame_free(AVFrame **frame);
    
    int avcodec_send_packet(AVCodecContext *avctx, const AVPacket *avpkt);
    int avcodec_receive_frame(AVCodecContext *avctx, AVFrame *frame);
    const char *avcodec_get_name(enum AVCodecID id);

    // Functions - libswscale
    struct SwsContext;
    struct SwsContext *sws_getContext(int srcW, int srcH, enum AVPixelFormat srcFormat,
                                      int dstW, int dstH, enum AVPixelFormat dstFormat,
                                      int flags, void *srcFilter, void *dstFilter, const double *param);
    void sws_freeContext(struct SwsContext *swsContext);
    int sws_scale(struct SwsContext *c, const uint8_t *const srcSlice[],
                  const int srcStride[], int srcSliceY, int srcSliceH,
                  uint8_t *const dst[], const int dstStride[]);

    // Functions - libavutil
    void *av_malloc(size_t size);
    void av_free(void *ptr);
    int av_image_get_buffer_size(enum AVPixelFormat pix_fmt, int width, int height, int align);
    int av_image_fill_arrays(uint8_t *dst_data[4], int dst_linesize[4],
                             const uint8_t *src,
                             enum AVPixelFormat pix_fmt, int width, int height, int align);
]]

-- ============================================================================
-- 2. Library Loading
-- ============================================================================

local lib_path = "/Applications/DaVinci Resolve/DaVinci Resolve.app/Contents/Libraries/"

local function load_lib(name)
    local path = lib_path .. name
    local ok, lib = pcall(ffi.load, path)
    if not ok then
        error("Failed to load library: " .. path .. "\nError: " .. tostring(lib))
    end
    return lib
end

local avutil = load_lib("libavutil.58.dylib")
local avcodec = load_lib("libavcodec.60.dylib")
local avformat = load_lib("libavformat.60.dylib")
local swscale = load_lib("libswscale.7.dylib")

-- ============================================================================
-- 3. Module Implementation
-- ============================================================================

local LibAV = {}
LibAV.__index = LibAV

-- Constants
local AV_SEEK_FLAG_BACKWARD = 1
local AV_SEEK_FLAG_BYTE = 2
local AV_SEEK_FLAG_ANY = 4
local AV_SEEK_FLAG_FRAME = 8

local SWS_BILINEAR = 2

-- Helper: Check FFmpeg error
local function check_err(ret, msg)
    if ret < 0 then
        local buf = ffi.new("char[256]")
        avutil.av_strerror(ret, buf, 256)
        return false, string.format("%s: %s (%d)", msg, ffi.string(buf), ret)
    end
    return true
end

-- Helper: Find codecpar offset dynamically
local function find_codecpar_offset()
    local ctx = avformat.avformat_alloc_context()
    if ctx == nil then return 208 end -- Fallback
    
    local st = avformat.avformat_new_stream(ctx, nil)
    if st == nil then
        avformat.avformat_free_context(ctx)
        return 208
    end
    
    local st_ptr = ffi.cast("uint8_t*", st)
    local found_offset = nil
    
    -- Scan for a pointer that points to AVCodecParameters
    -- In a new stream, codecpar is allocated and initialized.
    -- codec_type should be AVMEDIA_TYPE_UNKNOWN (-1)
    -- codec_id should be AV_CODEC_ID_NONE (0)
    
    for offset = 0, 512, 8 do
        local ptr_ptr = ffi.cast("AVCodecParameters**", st_ptr + offset)
        local ptr = ptr_ptr[0]
        
        if ptr ~= nil then
            local addr = tonumber(ffi.cast("uintptr_t", ptr))
            if addr > 0x10000 then
                -- Check content
                local ok, type = pcall(function() return ptr.codec_type end)
                local ok2, id = pcall(function() return ptr.codec_id end)
                
                if ok and ok2 then
                    if type == ffi.C.AVMEDIA_TYPE_UNKNOWN and id == ffi.C.AV_CODEC_ID_NONE then
                        -- Found it!
                        found_offset = offset
                        break
                    end
                end
            end
        end
    end
    
    avformat.avformat_free_context(ctx)
    return found_offset or 208
end

-- Open a video file
function LibAV.open(filepath)
    local self = setmetatable({}, LibAV)
    
    -- Determine offset once
    self.codecpar_offset = find_codecpar_offset()
    -- print("DEBUG: Detected codecpar offset: " .. self.codecpar_offset)
    
    self.fmt_ctx_ptr = ffi.new("AVFormatContext*[1]")
    
    -- Open Input
    local ret = avformat.avformat_open_input(self.fmt_ctx_ptr, filepath, nil, nil)
    if ret < 0 then
        local ok, err = check_err(ret, "avformat_open_input")
        return nil, err
    end
    self.fmt_ctx = self.fmt_ctx_ptr[0]

    -- Find Stream Info
    ret = avformat.avformat_find_stream_info(self.fmt_ctx, nil)
    if ret < 0 then
        avformat.avformat_close_input(self.fmt_ctx_ptr)
        local ok, err = check_err(ret, "avformat_find_stream_info")
        return nil, err
    end
    
    -- Find Video Stream Index
    self.video_stream_idx = -1
    for i = 0, self.fmt_ctx.nb_streams - 1 do
        local st_ptr = ffi.cast("uint8_t*", self.fmt_ctx.streams[i])
        local par = ffi.cast("AVCodecParameters**", st_ptr + self.codecpar_offset)[0]
        
        if par and par.codec_type == ffi.C.AVMEDIA_TYPE_VIDEO then
            self.video_stream_idx = i
            break
        end
    end

    return self
end

-- Close the file
function LibAV:close()
    if self.fmt_ctx_ptr then
        avformat.avformat_close_input(self.fmt_ctx_ptr)
        self.fmt_ctx_ptr = nil
        self.fmt_ctx = nil
    end
    if self.codec_ctx then
        local ptr = ffi.new("AVCodecContext*[1]")
        ptr[0] = self.codec_ctx
        avcodec.avcodec_free_context(ptr)
        self.codec_ctx = nil
    end
end

-- Get Metadata
function LibAV:get_metadata()
    local meta = {}
    if self.fmt_ctx.metadata ~= nil then
        local entry = nil
        while true do
            entry = avutil.av_dict_get(self.fmt_ctx.metadata, "", entry, 2) -- 2 = AV_DICT_IGNORE_SUFFIX
            if entry == nil then break end
            local key = ffi.string(entry.key)
            local value = ffi.string(entry.value)
            meta[key] = value
        end
    end
    return meta
end

-- Get Tracks
function LibAV:get_tracks()
    local tracks = {}
    for i = 0, self.fmt_ctx.nb_streams - 1 do
        local st = self.fmt_ctx.streams[i]
        local st_ptr = ffi.cast("uint8_t*", st)
        local offset = self.codecpar_offset or 208 -- Default to 208 if not found (fallback)
        local par = ffi.cast("AVCodecParameters**", st_ptr + offset)[0]
        
        local type_str = "unknown"
        if par then
            if par.codec_type == ffi.C.AVMEDIA_TYPE_VIDEO then type_str = "video"
            elseif par.codec_type == ffi.C.AVMEDIA_TYPE_AUDIO then type_str = "audio"
            elseif par.codec_type == ffi.C.AVMEDIA_TYPE_SUBTITLE then type_str = "subtitle"
            elseif par.codec_type == ffi.C.AVMEDIA_TYPE_DATA then type_str = "data"
            end
        end

        local codec_name = ffi.string(avcodec.avcodec_get_name(par.codec_id))
        
        -- We can't access st.id/duration/time_base easily if AVStream is opaque.
        -- We need to define offsets for those too if we want them.
        -- For now, let's return basic info from codecpar.
        
        local track = {
            index = i,
            type = type_str,
            codec = codec_name,
            -- id = tonumber(st.id),
            -- duration_sec = tonumber(st.duration) * (tonumber(st.time_base.num) / tonumber(st.time_base.den)),
        }

        if par then
            if type_str == "video" then
                track.width = par.width
                track.height = par.height
                -- track.fps = tonumber(st.avg_frame_rate.num) / tonumber(st.avg_frame_rate.den)
            elseif type_str == "audio" then
                track.channels = par.channels
                track.sample_rate = par.sample_rate
            end
        end

        table.insert(tracks, track)
    end
    return tracks
end

-- Get Timecode
-- This attempts to read the timecode from metadata or the timecode track
function LibAV:get_timecode()
    -- 1. Try Metadata
    local meta = self:get_metadata()
    if meta["timecode"] then
        return meta["timecode"]
    end

    -- 2. Try to find a timecode track (TMCD)
    -- This is more complex as it requires reading the packet from the TMCD stream.
    -- For now, we return nil if not in metadata.
    return nil
end

-- Get Frame at Time (seconds)
-- Returns: buffer (string/cdata), width, height, stride
function LibAV:get_frame_at_time(timestamp_sec)
    if self.video_stream_idx < 0 then return nil, "No video stream" end

    local st = self.fmt_ctx.streams[self.video_stream_idx]
    local st_ptr = ffi.cast("uint8_t*", st)
    local offset = self.codecpar_offset or 208
    local par = ffi.cast("AVCodecParameters**", st_ptr + offset)[0]

    -- Initialize Codec Context if not already done
    if not self.codec_ctx then
        local codec = avcodec.avcodec_find_decoder(par.codec_id)
        if codec == nil then return nil, "Decoder not found" end

        self.codec_ctx = avcodec.avcodec_alloc_context3(codec)
        if self.codec_ctx == nil then return nil, "Failed to alloc codec context" end

        if avcodec.avcodec_parameters_to_context(self.codec_ctx, par) < 0 then
            return nil, "Failed to copy codec params"
        end

        if avcodec.avcodec_open2(self.codec_ctx, codec, nil) < 0 then
            return nil, "Failed to open codec"
        end
    end

    -- Seek
    -- We need time_base for seeking. It is at offset 16 usually.
    local tb_ptr = ffi.cast("AVRational*", st_ptr + 16)
    local tb_num = tb_ptr.num
    local tb_den = tb_ptr.den
    
    local target_ts = timestamp_sec / (tonumber(tb_num) / tonumber(tb_den))
    local ret = avformat.av_seek_frame(self.fmt_ctx, self.video_stream_idx, target_ts, AV_SEEK_FLAG_BACKWARD)
    if ret < 0 then return nil, "Seek failed" end

    -- Flush buffers
    -- avcodec.avcodec_flush_buffers(self.codec_ctx) -- Optional, but good practice after seek

    local packet = avcodec.av_packet_alloc()
    local frame = avcodec.av_frame_alloc()
    local rgb_frame = avcodec.av_frame_alloc()
    
    local found_frame = false
    local result_buffer = nil
    local res_w, res_h, res_stride = 0, 0, 0

    while not found_frame do
        ret = avformat.av_read_frame(self.fmt_ctx, packet)
        if ret < 0 then break end

        if packet.stream_index == self.video_stream_idx then
            ret = avcodec.avcodec_send_packet(self.codec_ctx, packet)
            if ret >= 0 then
                while true do
                    ret = avcodec.avcodec_receive_frame(self.codec_ctx, frame)
                    if ret == -11 then break end -- EAGAIN
                    if ret < 0 then break end -- Error or EOF

                    -- Check if this frame is close enough to target?
                    -- For now, we just take the first frame after seek that decodes successfully
                    -- Ideally we check frame->pts >= target_ts
                    
                    if frame.pts >= target_ts then
                        -- Convert to RGBA
                        local w, h = frame.width, frame.height
                        res_w, res_h = w, h
                        
                        -- Setup SwsContext
                        local sws_ctx = swscale.sws_getContext(
                            w, h, frame.format, -- Use frame format, safer than ctx
                            w, h, ffi.C.AV_PIX_FMT_RGBA,
                            SWS_BILINEAR, nil, nil, nil
                        )
                        
                        if sws_ctx == nil then
                            break
                        end
                        
                        -- Allocate buffer for RGBA
                        -- 4 bytes per pixel
                        local buffer_size = w * h * 4
                        local buffer = ffi.new("uint8_t[?]", buffer_size)
                        
                        local dst_data = ffi.new("uint8_t*[4]")
                        local dst_linesize = ffi.new("int[4]")
                        
                        avutil.av_image_fill_arrays(dst_data, dst_linesize, buffer, ffi.C.AV_PIX_FMT_RGBA, w, h, 1)
                        
                        swscale.sws_scale(sws_ctx, 
                            ffi.cast("const uint8_t* const*", frame.data), frame.linesize, 
                            0, h, 
                            dst_data, dst_linesize)
                        
                        swscale.sws_freeContext(sws_ctx)
                        
                        result_buffer = buffer
                        res_stride = dst_linesize[0]
                        found_frame = true
                        break
                    end
                end
            end
        end
        avcodec.av_packet_unref(packet)
        if found_frame then break end
    end

    local pkt_ptr = ffi.new("AVPacket*[1]")
    pkt_ptr[0] = packet
    avcodec.av_packet_free(pkt_ptr)
    
    local frame_ptr = ffi.new("AVFrame*[1]")
    frame_ptr[0] = frame
    avcodec.av_frame_free(frame_ptr)
    
    local rgb_frame_ptr = ffi.new("AVFrame*[1]")
    rgb_frame_ptr[0] = rgb_frame
    avcodec.av_frame_free(rgb_frame_ptr)

    if found_frame then
        return result_buffer, res_w, res_h, res_stride
    else
        return nil, "Frame not found"
    end
end

return LibAV
