local perl = require("perl")

print("Creating Perl interpreter...")
local p, err = perl.new()

if not p then
    print("Error creating interpreter: " .. err)
    os.exit(1)
end

print("Perl interpreter created successfully.")

print("Running Perl code: print 'Hello from Perl!\\n'")
local args = {"perl", "-e", "print 'Hello from Perl!\\n'"}
local result, err = p:run(args)

if result ~= 0 then
    print("Error running Perl code: " .. (err or "unknown error"))
    os.exit(1)
end

print("Perl code executed successfully.")