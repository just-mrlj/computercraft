-- ===================================
-- REACTOR DISCOVERY TOOL
-- Finds your reactor and shows available methods
-- ===================================

print("=== Bigger Reactors Discovery ===")
print("")
print("Looking for reactor...")
print("")

-- Find all connected peripherals
local peripherals = peripheral.getNames()

print("Connected peripherals:")
for _, name in ipairs(peripherals) do
    print("  - " .. name .. " (" .. peripheral.getType(name) .. ")")
end

print("")
print("Looking for reactor peripheral...")

-- Try to find reactor
local reactor = peripheral.find("BiggerReactors_Reactor")
if not reactor then
    reactor = peripheral.find("BigReactors-Reactor")
end

if not reactor then
    -- Manual search for reactor-like peripherals
    for _, name in ipairs(peripherals) do
        local pType = peripheral.getType(name)
        if pType:lower():find("reactor") then
            print("Found potential reactor: " .. name)
            reactor = peripheral.wrap(name)
            break
        end
    end
end

if not reactor then
    print("")
    print("ERROR: No reactor found!")
    print("")
    print("To connect your reactor:")
    print("1. Place a Wired Modem on the Reactor Terminal")
    print("   or Reactor Computer Port")
    print("2. Connect the modem to your computer with")
    print("   Network Cable")
    print("3. Right-click the modem to activate it")
    print("   (it should turn red)")
    print("4. Run this script again")
    return
end

print("")
print("SUCCESS! Reactor found!")
print("")
print("Available methods:")
print("==================")

-- Get all methods
local methods = peripheral.getMethods(peripheral.getName(reactor))
table.sort(methods)

for _, method in ipairs(methods) do
    print("  " .. method)
end

print("")
print("Testing common methods...")
print("=========================")

-- Test common methods
local tests = {
    {"getActive", "Reactor Status"},
    {"getEnergyStored", "Energy Stored"},
    {"getEnergyCapacity", "Energy Capacity"},
    {"getFuelTemperature", "Fuel Temperature"},
    {"getCasingTemperature", "Casing Temperature"},
    {"getFuelAmount", "Fuel Amount"},
    {"getFuelCapacity", "Fuel Capacity"},
    {"getWasteAmount", "Waste Amount"},
    {"getEnergyProducedLastTick", "Energy Production"},
    {"getFuelConsumedLastTick", "Fuel Consumption"},
    {"getNumberOfControlRods", "Control Rods"}
}

for _, test in ipairs(tests) do
    local method, description = test[1], test[2]
    
    if reactor[method] then
        local success, result = pcall(function()
            return reactor[method]()
        end)
        
        if success then
            print(description .. ": " .. tostring(result))
        else
            print(description .. ": [Error calling method]")
        end
    end
end

print("")
print("Discovery complete!")
print("")
print("Run 'reactor_monitor' to display reactor stats")