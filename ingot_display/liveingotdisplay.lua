local me = peripheral.find("meBridge")
local monitor = peripheral.find("monitor")

if monitor then
    monitor.setTextScale(0.5)
end

local function displayIngots()
    monitor.clear()
    monitor.setCursorPos(1, 1)
    monitor.write("=== Ingot Storage ===")
    
    local items = me.listItems()
    local ingots = {}
    
    -- Filter ingots
    for _, item in ipairs(items) do
        if item.tags then
            for _, tag in ipairs(item.tags) do
                if tag == "minecraft:item/forge:ingots" then
                    table.insert(ingots, item)
                    break
                end
            end
        end
    end
    
    -- Sort by amount (highest first)
    table.sort(ingots, function(a, b) return a.amount > b.amount end)
    
    monitor.setCursorPos(1, 2)
    monitor.write("Total ingots: " .. #ingots)
    
    -- Display
    for i, item in ipairs(ingots) do
        monitor.setCursorPos(1, i + 2)
        monitor.write(item.displayName .. ": " .. item.amount)
    end
end

while true do
    displayIngots()
    sleep(5)
end