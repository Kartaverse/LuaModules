local ffi = require("ffi")

-- Determine the path to the shared library
local function get_script_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)") or "./"
end

local script_path = get_script_path()
local lib_path = script_path .. "grpc_ffi.so"

-- Load the shared library
print("Loading library from: " .. lib_path)
local grpc_lib = ffi.load(lib_path)
print("Library loaded.")

-- Define C declarations
ffi.cdef[[
    // Basic types
    typedef struct grpc_server grpc_server;
    typedef struct grpc_completion_queue grpc_completion_queue;
    typedef struct grpc_channel grpc_channel;
    typedef struct grpc_call grpc_call;
    typedef struct grpc_byte_buffer grpc_byte_buffer;
    
    typedef struct {
        size_t count;
        size_t capacity;
        void* metadata; // Opaque for now
    } grpc_metadata_array;
    
    typedef struct {
        void* method; // grpc_slice
        void* host;   // grpc_slice
        int64_t deadline; // gpr_timespec
        uint32_t flags;
        void* reserved;
    } grpc_call_details;
    
    typedef struct {
        int type;
        int success;
        void* tag;
    } grpc_event;
    
    typedef struct {
        int op;
        uint32_t flags;
        void* reserved;
        union {
            struct {
                size_t count;
                void* metadata;
                struct {
                    uint8_t is_set;
                    int level;
                } maybe_compression_level;
            } send_initial_metadata;
            struct {
                grpc_byte_buffer* send_message;
            } send_message;
            struct {
            } send_close_from_client;
            struct {
                size_t trailing_metadata_count;
                void* trailing_metadata;
                int status;
                void* status_details; // grpc_slice*
            } send_status_from_server;
            struct {
                grpc_metadata_array* recv_initial_metadata;
            } recv_initial_metadata;
            struct {
                grpc_byte_buffer** recv_message;
            } recv_message;
            struct {
                grpc_metadata_array* recv_trailing_metadata;
                int* status;
                void* status_details; // grpc_slice*
                size_t* status_details_capacity;
            } recv_status_on_client;
            struct {
                int* cancelled;
            } recv_close_on_server;
        } data;
    } grpc_op;
    
    typedef struct {
        void* refcount;
        union {
            struct { uint8_t length; uint8_t bytes[23]; } inlined;
            struct { size_t length; uint8_t* bytes; } refcounted;
        } data;
    } grpc_slice;

    // Functions
    const char* grpc_lua_version();
    void grpc_lua_init();
    void grpc_lua_shutdown();

    grpc_completion_queue* grpc_lua_completion_queue_create();
    void grpc_lua_completion_queue_shutdown(grpc_completion_queue* cq);
    void grpc_lua_completion_queue_destroy(grpc_completion_queue* cq);
    grpc_event grpc_lua_completion_queue_next(grpc_completion_queue* cq, double timeout_seconds);

    grpc_server* grpc_lua_server_create(const char* args, grpc_completion_queue* cq);
    int grpc_lua_server_add_insecure_http2_port(grpc_server* server, const char* addr);
    void grpc_lua_server_start(grpc_server* server);
    void grpc_lua_server_destroy(grpc_server* server);
    void grpc_lua_server_shutdown_and_notify(grpc_server* server, grpc_completion_queue* cq, void* tag);
    void* grpc_lua_server_register_method(grpc_server* server, const char* method, const char* host);
    int grpc_lua_server_request_call(
        grpc_server* server, 
        grpc_call** call, 
        grpc_call_details* details, 
        grpc_metadata_array* request_metadata,
        grpc_completion_queue* cq, 
        void* tag);

    grpc_channel* grpc_lua_insecure_channel_create(const char* target);
    void grpc_lua_channel_destroy(grpc_channel* channel);
    grpc_call* grpc_lua_channel_create_call(
        grpc_channel* channel, 
        grpc_completion_queue* cq, 
        const char* method, 
        const char* host, 
        double deadline_seconds);
    void grpc_lua_call_unref(grpc_call* call);
    int grpc_lua_call_start_batch(grpc_call* call, const grpc_op* ops, size_t nops, void* tag);

    void grpc_lua_op_init_send_initial_metadata(grpc_op* op, size_t count, grpc_metadata_array* metadata);
    void grpc_lua_op_init_send_message(grpc_op* op, grpc_byte_buffer* message);
    void grpc_lua_op_init_send_close_from_client(grpc_op* op);
    void grpc_lua_op_init_recv_initial_metadata(grpc_op* op, grpc_metadata_array* metadata);
    void grpc_lua_op_init_recv_message(grpc_op* op, grpc_byte_buffer** message);
    void grpc_lua_op_init_recv_status_on_client(grpc_op* op, grpc_metadata_array* trailing_metadata, int* status, grpc_slice* status_details);
    void grpc_lua_op_init_send_status_from_server(grpc_op* op, size_t count, grpc_metadata_array* metadata, int status, grpc_slice* status_details);
    void grpc_lua_op_init_recv_close_on_server(grpc_op* op, int* cancelled);

    grpc_slice grpc_lua_slice_from_string(const char* str);
    void grpc_lua_slice_unref(grpc_slice slice);
    const char* grpc_lua_slice_to_string(grpc_slice slice);
    size_t grpc_lua_slice_length(grpc_slice slice);

    grpc_byte_buffer* grpc_lua_raw_byte_buffer_create(grpc_slice* slices, size_t nslices);
    void grpc_lua_byte_buffer_destroy(grpc_byte_buffer* bb);
    char* grpc_lua_byte_buffer_to_string(grpc_byte_buffer* bb, size_t* len);
    void grpc_lua_free(void* ptr);
    
    void grpc_lua_metadata_array_init(grpc_metadata_array* array);
    void grpc_lua_metadata_array_destroy(grpc_metadata_array* array);
    void grpc_lua_call_details_init(grpc_call_details* details);
    void grpc_lua_call_details_destroy(grpc_call_details* details);
]]

-- Module table
local M = {}

M.lib = grpc_lib

function M.version()
    return ffi.string(grpc_lib.grpc_lua_version())
end

function M.init()
    grpc_lib.grpc_lua_init()
end

function M.shutdown()
    grpc_lib.grpc_lua_shutdown()
end

-- Constants
M.GRPC_OP_SEND_INITIAL_METADATA = 0
M.GRPC_OP_SEND_MESSAGE = 1
M.GRPC_OP_SEND_CLOSE_FROM_CLIENT = 2
M.GRPC_OP_SEND_STATUS_FROM_SERVER = 3
M.GRPC_OP_RECV_INITIAL_METADATA = 4
M.GRPC_OP_RECV_MESSAGE = 5
M.GRPC_OP_RECV_STATUS_ON_CLIENT = 6
M.GRPC_OP_RECV_CLOSE_ON_SERVER = 7

M.GRPC_QUEUE_SHUTDOWN = 0
M.GRPC_QUEUE_TIMEOUT = 1
M.GRPC_OP_COMPLETE = 2

M.GRPC_STATUS_OK = 0

return M