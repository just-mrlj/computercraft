-- Test battery() and fuelTank() structure

local reactor = peripheral.wrap("BiggerReactors_Reactor_0")

print("=== Testing battery() ===")
local battery = reactor.battery()

print("Type: " .. type(battery))
print("")

if type(battery) == "table" then
    print("Keys in battery:")
    for key, value in pairs(battery) do
        print("  " .. key .. " = " .. type(value))
        
        -- If it's a function, try calling it
        if type(value) == "function" then
            local success, result = pcall(value)
            if success then
                print("    Calling " .. key .. "() returns: " .. tostring(result))
            end
        else
            print("    Value: " .. tostring(value))
        end
    end
else
    print("battery() returned: " .. tostring(battery))
end

print("")
print("=== Testing fuelTank() ===")
local fuelTank = reactor.fuelTank()

print("Type: " .. type(fuelTank))
print("")

if type(fuelTank) == "table" then
    print("Keys in fuelTank:")
    for key, value in pairs(fuelTank) do
        print("  " .. key .. " = " .. type(value))
        
        -- If it's a function, try calling it
        if type(value) == "function" then
            local success, result = pcall(value)
            if success then
                print("    Calling " .. key .. "() returns: " .. tostring(result))
            end
        else
            print("    Value: " .. tostring(value))
        end
    end
else
    print("fuelTank() returned: " .. tostring(fuelTank))
end

print("")
print("=== Direct method tests ===")

-- Try calling methods that might exist directly
local directTests = {
    "fuelTemperature",
    "casingTemperature", 
    "stackTemperature",
    "active"
}

for _, method in ipairs(directTests) do
    if reactor[method] then
        local success, result = pcall(function()
            return reactor[method]()
        end)
        if success then
            print(method .. "() = " .. tostring(result))
        end
    end
end