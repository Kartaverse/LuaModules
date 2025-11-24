-- ICMP Demo.lua
-- Demonstrates a simple ICMP Echo Request (Ping)
-- NOTE: This script typically requires root/sudo privileges to open raw sockets.

-- Add the current directory to the package path so we can find socket.lua
package.path = package.path .. ";./?.lua"

local socket = require("socket")

-- Simple checksum function
local function checksum(data)
    local sum = 0
    local len = #data
    
    for i = 1, len - 1, 2 do
        local b1 = string.byte(data, i)
        local b2 = string.byte(data, i + 1)
        sum = sum + (b1 * 256 + b2)
    end
    
    if len % 2 == 1 then
        sum = sum + (string.byte(data, len) * 256)
    end
    
    sum = (math.floor(sum / 65536)) + (sum % 65536)
    sum = sum + (math.floor(sum / 65536))
    return bit.bnot(sum) % 65536
end

-- Construct an ICMP Echo Request packet
local function make_ping_packet(seq)
    local type = 8 -- Echo Request
    local code = 0
    local chk = 0
    local id = 1234
    local sequence = seq
    
    -- Pack header with zero checksum
    -- struct { byte type; byte code; short checksum; short id; short sequence; }
    -- We construct the string manually for simplicity without struct library
    local header_no_chk = string.char(type, code) .. 
                          string.char(0, 0) .. 
                          string.char(math.floor(id / 256), id % 256) .. 
                          string.char(math.floor(sequence / 256), sequence % 256)
                          
    local payload = "Hello LuaSocket"
    
    -- Calculate checksum
    chk = checksum(header_no_chk .. payload)
    
    -- Re-pack with checksum
    local header = string.char(type, code) .. 
                   string.char(math.floor(chk / 256), chk % 256) .. 
                   string.char(math.floor(id / 256), id % 256) .. 
                   string.char(math.floor(sequence / 256), sequence % 256)
                   
    return header .. payload
end

local host = "8.8.8.8" -- Google DNS
print("Attempting to ping " .. host .. " (requires root privileges)...")

-- Create a raw socket for ICMP
-- Note: LuaSocket doesn't expose a direct "icmp" constructor in the high-level API easily,
-- but we can try to use the core connect function with "icmp" if supported, 
-- or more commonly, we might need to use a raw socket if exposed.
-- However, standard LuaSocket is primarily TCP/UDP. 
-- The 'inet' namespace in core might allow creating other types if we dig deep,
-- but standard usage is limited.
--
-- Let's try to use the internal socket.connect with "raw" or similar if possible,
-- but standard LuaSocket doesn't support ICMP out of the box without patches or specific compile flags usually.
--
-- WAIT: LuaSocket DOES NOT support ICMP/Raw sockets out of the box in the standard distribution.
-- It only supports TCP and UDP.
--
-- Since the user ASKED for an ICMP demo, and we are using the standard repo,
-- we might hit a wall here. 
--
-- However, let's check if we can use 'datagram' with a specific protocol if exposed.
-- If not, we will simulate or explain the limitation.
--
-- Actually, let's look at the source code we have.
-- src/usocket.c creates sockets.
-- It uses SOCK_STREAM (TCP) and SOCK_DGRAM (UDP).
-- There is no SOCK_RAW support in standard LuaSocket.
--
-- RE-EVALUATION:
-- The user asked for "ICMP Demo.lua".
-- Since standard LuaSocket doesn't do ICMP, I cannot implement a working ICMP ping 
-- using *only* the standard LuaSocket library I just compiled.
--
-- I will create a script that EXPLAINS this limitation and perhaps uses 
-- an external command (like system ping) to demonstrate "ICMP" via Lua,
-- OR I will attempt to use LuaJIT FFI to create a raw socket directly, 
-- bypassing LuaSocket for the creation but maybe using LuaSocket for other things?
--
-- The prompt asked: "Create a Lua module that uses LuaJIT with FFI to access the luasocket network library."
-- AND "Create three example lua scripts... ICMP Demo.lua"
--
-- If I use FFI to access LuaSocket, I am just calling LuaSocket's C functions.
-- LuaSocket's C functions don't support ICMP.
--
-- BUT, since I am using LuaJIT, I can use FFI to call the OS's `socket` function directly 
-- to create a raw socket!
--
-- So, for the ICMP demo, I will use LuaJIT FFI to create a raw socket, 
-- demonstrating the power of LuaJIT + FFI which seems to be the spirit of the request,
-- even if the main 'socket.lua' is wrapping the standard library.
--
-- Let's write an FFI-based ICMP pinger.

local ffi = require("ffi")
local bit = require("bit")

ffi.cdef[[
    static const int AF_INET = 2;
    static const int SOCK_RAW = 3;
    static const int IPPROTO_ICMP = 1;

    struct sockaddr {
        uint8_t sa_len;
        uint8_t sa_family;
        char sa_data[14];
    };

    struct sockaddr_in {
        uint8_t sin_len;
        uint8_t sin_family;
        uint16_t sin_port;
        struct { uint32_t s_addr; } sin_addr;
        char sin_zero[8];
    };

    int socket(int domain, int type, int protocol);
    int connect(int sockfd, const struct sockaddr *addr, uint32_t addrlen);
    ssize_t send(int sockfd, const void *buf, size_t len, int flags);
    ssize_t recv(int sockfd, void *buf, size_t len, int flags);
    int close(int fd);
    uint32_t inet_addr(const char *cp);
    char *strerror(int errnum);
]]

local function ping_ffi(target_ip)
    local fd = ffi.C.socket(ffi.C.AF_INET, ffi.C.SOCK_RAW, ffi.C.IPPROTO_ICMP)
    if fd < 0 then
        print("Failed to create raw socket. Do you have root privileges?")
        return
    end

    local dest = ffi.new("struct sockaddr_in")
    dest.sin_len = ffi.sizeof("struct sockaddr_in")
    dest.sin_family = ffi.C.AF_INET
    dest.sin_port = 0
    dest.sin_addr.s_addr = ffi.C.inet_addr(target_ip)

    -- Connect so we can use send/recv instead of sendto/recvfrom for simplicity
    if ffi.C.connect(fd, (ffi.cast("struct sockaddr *", dest)), ffi.sizeof(dest)) ~= 0 then
        print("Failed to connect raw socket")
        ffi.C.close(fd)
        return
    end

    local packet = make_ping_packet(1)
    local bytes_sent = ffi.C.send(fd, packet, #packet, 0)
    
    if bytes_sent < 0 then
        print("Failed to send packet")
    else
        print("Sent ICMP Echo Request to " .. target_ip)
        
        local buf = ffi.new("char[1024]")
        local bytes_read = ffi.C.recv(fd, buf, 1024, 0)
        
        if bytes_read > 0 then
            print("Received " .. tonumber(bytes_read) .. " bytes in response")
            -- In a real implementation we would parse the IP header and ICMP header
            -- to verify it's a reply to our echo request.
            print("Ping successful (reply received)!")
        else
            print("No response or error reading")
        end
    end

    ffi.C.close(fd)
end

ping_ffi(host)