local lpeg = require("lpeg")

print("LPeg version:", lpeg.version)

local match = lpeg.match
local P = lpeg.P
local R = lpeg.R
local S = lpeg.S
local C = lpeg.C
local Ct = lpeg.Ct

-- Test 1: Basic matching
local p = P("hello")
assert(match(p, "hello world") == 6)
print("Test 1 Passed: Basic matching")

-- Test 2: Ranges and Sets
local d = R("09")
local w = R("az", "AZ")
local s = S(" \t")
local p2 = w^1 * s * d^1
assert(match(p2, "item 123") == 9)
print("Test 2 Passed: Ranges and Sets")

-- Test 3: Captures
local p3 = C(P("test"))
assert(match(p3, "test") == "test")
print("Test 3 Passed: Captures")

-- Test 4: Table Capture
local p4 = Ct(C(R("09")^1) * (S("+-*/") * C(R("09")^1))^0)
local res = match(p4, "12+34-56")
assert(res[1] == "12")
assert(res[2] == "34")
assert(res[3] == "56")
print("Test 4 Passed: Table Capture")

print("All tests passed successfully!")