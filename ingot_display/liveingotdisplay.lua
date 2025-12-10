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
    
    -- Filter by tag
    for _, item in ipairs(items) do
        if item.tags and item.tags["minecraft:item/forge:ingots"] then
            table.insert(ingots, item)
        end
    end
    
    -- Sort by amount
    table.sort(ingots, function(a, b) return a.amount > b.amount end)
    
    -- Display
    for i, item in ipairs(ingots) do
        monitor.setCursorPos(1, i + 1)
        monitor.write(item.displayName .. ": " .. item.amount)
    end
end

while true do
    displayIngots()
    sleep(5)
end