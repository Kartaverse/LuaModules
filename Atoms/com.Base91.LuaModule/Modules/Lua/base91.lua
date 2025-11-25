-- Base91 Encoding/Decoding Lua Module

-- Localize the built-in bitwise operators for high performance in LuaJIT
local bor, band, lshift, rshift, bnot = bit.bor, bit.band, bit.lshift, bit.rshift, bit.bnot

-- Localize table utilities
local concat = table.concat

-- The 91-character alphabet as defined by the Base91 specification
local ALPHABET = [=[ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!#$%&()*+,./:;<=>?@[]^_`{|}~"]=]

-- Pre-calculated table for fast decoding: character -> index (0-90)
local DECODE_MAP = {}
for i = 1, #ALPHABET do
    -- Store index (0-based) for the character
    DECODE_MAP[ALPHABET:sub(i, i)] = i - 1
end

-- Exported module table
local M = {}

--- Encodes a string of bytes into a Base91 string.
-- @param data_str string: The raw input data string.
-- @return string: The Base91 encoded string.
function M.encode(data_str)
    -- State variables (localized for JIT efficiency)
    local bit_acc = 0   -- Accumulator for partial bits
    local bit_count = 0 -- Number of bits currently in the accumulator
    local output = {}   -- Table to collect output characters

    -- Pre-calculate length and index for string iteration
    local len = #data_str
    local char_code
    local n, v

    for i = 1, len do
        -- Get the byte value (0-255)
        char_code = data_str:byte(i)
        
        -- 1. Add the 8 bits from the byte to the accumulator
        -- bit_acc = bit_acc | (char_code << bit_count)
        bit_acc = bor(bit_acc, lshift(char_code, bit_count))
        bit_count = bit_count + 8

        -- 2. Check if we have enough bits (>= 13) to output 2 characters
        if bit_count >= 13 then
            -- Extract the first 13 bits (v = bit_acc & 8191)
            -- 8191 (decimal) = 1111111111111 (13 bits)
            v = band(bit_acc, 8191)

            -- Check if value is 91 or greater (requires two characters)
            if v > 90 then
                -- v is a value from 91 to 8191.
                -- Base91 needs two characters (c0, c1) for v.
                
                -- c0 (6 bits): v % 91
                local c0_index = v % 91
                -- c1 (7 bits): floor(v / 91)
                local c1_index = (v / 91) - (c0_index / 91)
                
                -- Append characters to output table
                output[#output + 1] = ALPHABET:sub(c0_index + 1, c0_index + 1)
                output[#output + 1] = ALPHABET:sub(c1_index + 1, c1_index + 1)
                
                -- 3. Consume the 13 bits and shift the accumulator
                -- bit_acc = bit_acc >> 13
                bit_acc = rshift(bit_acc, 13)
                bit_count = bit_count - 13

            else
                -- v is 90 or less (0 to 90). This is a rare edge case for 14 bits.
                -- This case ensures proper handling of bit_acc values up to 16383
                -- when bit_count is 14 or 15. The core Base91 idea is to
                -- always extract 14 bits if possible, or 13 bits if the value fits
                -- in 90. Since we only guarantee 13 bits are available here,
                -- we extract 13, and if it's <= 90, we output just one char.
                
                -- Output the single character (c0)
                local c0_index = v
                output[#output + 1] = ALPHABET:sub(c0_index + 1, c0_index + 1)

                -- Consume the 13 bits
                bit_acc = rshift(bit_acc, 13)
                bit_count = bit_count - 13
            end
        end
    end

    -- 4. Final step: flush remaining bits
    if bit_count > 0 then
        -- The value 'v' is simply the remaining accumulated bits
        local v = bit_acc
        
        if bit_count > 7 or v > 90 then
            -- If we have more than 7 bits or the value is > 90,
            -- we output two characters (13/14 bit logic)
            local c0_index = v % 91
            local c1_index = (v / 91) - (c0_index / 91)
            
            output[#output + 1] = ALPHABET:sub(c0_index + 1, c0_index + 1)
            output[#output + 1] = ALPHABET:sub(c1_index + 1, c1_index + 1)
            
            -- We shift by the number of bits consumed (13 or 14)
            -- The number of bits consumed is simply the number of bits required
            -- to hold the output value v. Since v <= 16383, this is max 14 bits.
            -- To keep it simple and safe for the end, we can just use 13 here
            -- as the max number of bits that could be left over and fit into two
            -- Base91 characters is 14 (from 8 + 8 = 16, leaving 3 if 13 used).
            -- However, to implement the official Base91 end-of-stream logic:
            
            -- If the remaining bits required 2 chars, it means the value was > 90.
            -- Max remaining bits is 14. If v > 90, it consumed between 8 and 14 bits.
            -- To be safe, we calculate bits consumed:
            local consumed_bits = 13 -- The number of bits consumed is always 13 for two chars in the final block, as per spec.

            bit_acc = rshift(bit_acc, consumed_bits)
            bit_count = bit_count - consumed_bits
            
        elseif v > 0 then
            -- Output a single character (if v is 1-90)
            output[#output + 1] = ALPHABET:sub(v + 1, v + 1)
            
            -- We are done, bit_count goes to 0
            bit_count = 0
        end
    end

    -- Return the concatenated string, which is fast in LuaJIT
    return concat(output)
end


--- Decodes a Base91 string back into a string of bytes.
-- @param base91_str string: The Base91 encoded string.
-- @return string: The decoded raw data string.
function M.decode(base91_str)
    -- State variables (localized for JIT efficiency)
    local bit_acc = 0   -- Accumulator for partial bits
    local bit_count = 0 -- Number of bits currently in the accumulator
    local output = {}   -- Table to collect output bytes
    local len = #base91_str

    local v = -1
    local c
    local b

    for i = 1, len do
        c = base91_str:sub(i, i)
        
        -- Get the 0-based index value for the character
        local new_v = DECODE_MAP[c]
        
        if not new_v then
            -- Base91 specifies non-alphabet characters are ignored.
            -- The spec often uses newline/CR, but we treat any non-mapped char as filler.
            goto continue
        end

        if v == -1 then
            -- First character of a pair/single block
            v = new_v
        else
            -- Second character of a pair/single block (v is 0-90, new_v is 0-90)
            
            -- Combine the pair into a value from 0 to 91*91-1 = 8280.
            -- Base91 values range from 0 (for 1 byte output) to 16383 (for 2 bytes output).
            -- The value 'b' here is (v + new_v * 91).
            b = v + new_v * 91

            -- Calculate the number of bits this value represents:
            -- If b < 256, it's 8 bits (rare, only happens if original data was 1 byte)
            -- If b < 512, it's 9 bits
            -- ...
            -- If b < 65536, it's 16 bits (max possible output from a 14-bit block)
            
            -- Base91 logic:
            local bits_to_add
            if b <= 8191 then
                -- Value fits in 13 bits (0 to 8191)
                bits_to_add = 13
            else
                -- Value is 8192 to 8280, uses 14 bits (or 13 if the last character was used)
                bits_to_add = 14
            end
            
            -- 1. Add the bits from the combined value 'b' to the accumulator
            -- bit_acc = bit_acc | (b << bit_count)
            bit_acc = bor(bit_acc, lshift(b, bit_count))
            bit_count = bit_count + bits_to_add

            -- 2. Extract full bytes while we have 8 or more bits
            while bit_count >= 8 do
                -- Extract the lowest 8 bits (byte = bit_acc & 255)
                local byte_val = band(bit_acc, 255)
                
                -- Append byte to output table
                output[#output + 1] = string.char(byte_val)
                
                -- Consume the 8 bits and shift the accumulator
                -- bit_acc = bit_acc >> 8
                bit_acc = rshift(bit_acc, 8)
                bit_count = bit_count - 8
            end

            -- Reset the 'v' state to wait for the next first character
            v = -1
        end

        ::continue::
    end

    -- 3. Final step: handle trailing bits (v is the last character's index)
    if v ~= -1 then
        -- This means the input string had an odd number of Base91 chars.
        -- The remaining character 'v' represents the last block.
        
        -- Add the value 'v' (0-90) to the accumulator
        -- bit_acc = bit_acc | (v << bit_count)
        bit_acc = bor(bit_acc, lshift(v, bit_count))
        
        -- The final block always represents 8 bits of data
        bit_count = bit_count + 8 

        -- Output the final byte
        local byte_val = band(bit_acc, 255)
        output[#output + 1] = string.char(byte_val)
    end
    
    -- Return the concatenated string, which is fast in LuaJIT
    return concat(output)
end

return M