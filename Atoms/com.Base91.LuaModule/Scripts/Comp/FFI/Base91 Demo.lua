-- Load the Base91 module
local base91 = require("base91")

-- 1. Base91 encoded text for "Hello Base91 World."
-- This string is the result of encoding "Hello Base91 World."
local encoded_text = ">OwJh>|LK!90+NdLOrFK5+BB"
local original_text = "Hello Base91 World."

print("Base91 Decoding Demo")
print("----------------------------------------------")
print("Original Text (Goal): ", original_text)
print("Encoded Text (Input): ", encoded_text)
print("----------------------------------------------")
-- 2. Base91 decode the string
local decoded_text = base91.decode(encoded_text)

-- 3. Print the results
print("Decoded Result:")
print(decoded_text)

-- Verification
if decoded_text == original_text then
    print("\nVerification: SUCCESS! The decoded string matches the original.")
else
    print("\nVerification: FAILED. Check the encoding/decoding logic.")
end
print("----------------------------------------------")