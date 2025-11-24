-- UDP Demo.lua
-- Demonstrates a simple UDP time server query (NTP)

-- Add the current directory to the package path so we can find socket.lua
package.path = package.path .. ";./?.lua"

local socket = require("socket")

local host = "time.google.com"
local port = 123 -- NTP port

print("Attempting to connect to " .. host .. ":" .. port .. " (UDP)")

local udp = socket.udp()
udp:settimeout(5)
udp:setpeername(host, port)

-- NTP Packet (48 bytes)
-- First byte: 00100011 (LI=0, VN=4, Mode=3 Client) = 0x23
local ntp_packet = string.char(0x23) .. string.rep(string.char(0), 47)

-- Send NTP request
udp:send(ntp_packet)

print("Request sent. Waiting for response...")

local data, err = udp:receive()

if err then
    print("Error receiving: " .. err)
else
    print("Received " .. #data .. " bytes of data.")
    -- The time protocol (RFC 868) returns a 32-bit binary number
    -- representing seconds since 1900-01-01 00:00:00 GMT.
    -- We'll just print the raw bytes for this demo to prove connectivity.
    print("Raw data (hex):")
    for i = 1, #data do
        io.write(string.format("%02X ", string.byte(data, i)))
    end
    io.write("\n")
end

udp:close()
print("Socket closed.")