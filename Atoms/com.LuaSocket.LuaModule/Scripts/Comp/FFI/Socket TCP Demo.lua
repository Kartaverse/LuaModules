-- TCP Demo.lua
-- Demonstrates a simple HTTP GET request using the custom socket module

-- Add the current directory to the package path so we can find socket.lua
package.path = package.path .. ";./?.lua"

local socket = require("socket")

print("Socket TCP Demo")
print("---------------------------------------------------------------------")
print("Demonstrates a simple HTTP GET request using the custom socket module")
print("---------------------------------------------------------------------")

local host = "www.json.org"
local port = 80
local file = "/example.html"

print("Attempting to connect to " .. host .. ":" .. port)

local c = socket.tcp()
local res, err = c:connect(host, port)

if not res then
    print("Error connecting: " .. err)
    return
end

print("Connected! Sending HTTP GET request...")

c:send("GET " .. file .. " HTTP/1.0\r\nHost: " .. host .. "\r\n\r\n")

print("Request sent. Receiving response...")

local response = ""
while true do
    local s, status, partial = c:receive()
    response = response .. (s or partial)
    if status == "closed" then break end
end

c:close()

print("---------------------------------------------------------------------")
print(response)
print("---------------------------------------------------------------------")
print("Connection closed.")