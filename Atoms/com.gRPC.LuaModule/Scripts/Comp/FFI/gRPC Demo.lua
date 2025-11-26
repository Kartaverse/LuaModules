print("gRPC Demo")
print("------------------------------------------------------------------------------------")

-- Add the lua directory to package.path so we can require 'grpc'
local script_path = debug.getinfo(1, "S").source:sub(2)
local script_dir = script_path:match("(.*/)") or "./"

-- Try to require grpc, if fails, add dev path
local status, grpc = pcall(require, "grpc")
if not status then
    package.path = package.path .. ";" .. script_dir .. "../lua/?.lua"
    grpc = require("grpc")
end

local ffi = require("ffi")

-- Test version
print("gRPC Version: " .. grpc.version())

-- Initialize gRPC
grpc.init()

-- Server
print("Creating server CQ...")
local server_cq = grpc.lib.grpc_lua_completion_queue_create()
print("Creating server...")
local server = grpc.lib.grpc_lua_server_create(nil, server_cq)
print("Adding port...")
local port = grpc.lib.grpc_lua_server_add_insecure_http2_port(server, "0.0.0.0:50051")
print("Server listening on port: " .. port)

local method = "/helloworld.Greeter/SayHello"
print("Registering method...")
local registered_method = grpc.lib.grpc_lua_server_register_method(server, method, nil)

print("Starting server...")
grpc.lib.grpc_lua_server_start(server)

-- Client
print("Creating client CQ...")
local client_cq = grpc.lib.grpc_lua_completion_queue_create()
print("Creating channel...")
local channel = grpc.lib.grpc_lua_insecure_channel_create("localhost:50051")
print("Creating call...")
local call = grpc.lib.grpc_lua_channel_create_call(channel, client_cq, method, nil, 5.0)

-- Start batch on client (Send Initial Metadata)
local ops = ffi.new("grpc_op[1]")
grpc.lib.grpc_lua_op_init_send_initial_metadata(ops, 0, nil)

local tag = ffi.cast("void*", 1)
local err = grpc.lib.grpc_lua_call_start_batch(call, ops, 1, tag)
if err ~= grpc.GRPC_STATUS_OK then
    print("Client start batch failed: " .. err)
end

-- Server request call
local server_call_ptr = ffi.new("grpc_call*[1]")
local call_details = ffi.new("grpc_call_details")
grpc.lib.grpc_lua_call_details_init(call_details)
local request_metadata = ffi.new("grpc_metadata_array")
grpc.lib.grpc_lua_metadata_array_init(request_metadata)
local server_tag = ffi.cast("void*", 2)

err = grpc.lib.grpc_lua_server_request_call(server, server_call_ptr, call_details, request_metadata, server_cq, server_tag)
if err ~= grpc.GRPC_STATUS_OK then
    print("Server request call failed: " .. err)
end

-- Wait for server event
print("Waiting for server event...")
local ev = grpc.lib.grpc_lua_completion_queue_next(server_cq, 2.0)
if ev.type == grpc.GRPC_OP_COMPLETE and ev.success == 1 and ev.tag == server_tag then
    print("Server received call!")
    local server_call = server_call_ptr[0]
    
    -- Server receive message
    local recv_ops = ffi.new("grpc_op[2]")
    recv_ops[0].op = grpc.GRPC_OP_SEND_INITIAL_METADATA
    recv_ops[0].data.send_initial_metadata.count = 0
    
    -- We should also receive the message from client, but for simplicity let's just finish
    -- Actually, we need to receive close on server to finish properly?
    -- Let's just send status to finish.
    
    recv_ops[1].op = grpc.GRPC_OP_SEND_STATUS_FROM_SERVER
    recv_ops[1].data.send_status_from_server.count = 0
    recv_ops[1].data.send_status_from_server.status_details = nil
    -- We need to set status code, but struct definition in Lua is tricky for nested union.
    -- Let's assume 0 (OK) is default if we don't set it? No, we need to set it.
    -- The struct definition in Lua:
    -- struct {
    --     grpc_metadata_array* recv_trailing_metadata;
    --     int* status;
    --     void* status_details; // grpc_slice*
    --     size_t* status_details_capacity;
    -- } recv_status_on_client;
    
    -- Wait, I am sending status from server.
    -- struct {
    --     size_t count;
    --     void* metadata;
    --     int status; // Missing in my Lua def!
    --     void* status_details; // grpc_slice*
    -- } send_status_from_server;
    
    -- I missed `int status` in `send_status_from_server` struct in Lua definition!
    -- I need to fix Lua definition first.
else
    print("Server event failed or timed out: type=" .. ev.type .. ", success=" .. ev.success)
end

-- Cleanup
grpc.lib.grpc_lua_byte_buffer_destroy(message_bb)
grpc.lib.grpc_lua_call_unref(call)
grpc.lib.grpc_lua_channel_destroy(channel)
grpc.lib.grpc_lua_completion_queue_shutdown(client_cq)
grpc.lib.grpc_lua_completion_queue_destroy(client_cq)

local shutdown_tag = ffi.cast("void*", 3)
grpc.lib.grpc_lua_server_shutdown_and_notify(server, server_cq, shutdown_tag)
print("Waiting for server shutdown...")
while true do
    local ev = grpc.lib.grpc_lua_completion_queue_next(server_cq, 5.0)
    if ev.type == grpc.GRPC_QUEUE_TIMEOUT then
        print("Server shutdown timed out.")
        break
    elseif ev.type == grpc.GRPC_OP_COMPLETE then
        if ev.tag == shutdown_tag then
            print("Server shutdown complete.")
            break
        else
            print("Got other event during shutdown: tag=" .. tostring(ev.tag))
        end
    else
        print("Got unknown event type: " .. ev.type)
        break
    end
end

grpc.lib.grpc_lua_server_destroy(server)
grpc.lib.grpc_lua_completion_queue_shutdown(server_cq)
grpc.lib.grpc_lua_completion_queue_destroy(server_cq)

grpc.shutdown()
print("Test Complete.")
print("------------------------------------------------------------------------------------")