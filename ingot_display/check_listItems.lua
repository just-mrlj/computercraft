local me = peripheral.find("meBridge")
local monitor = peripheral.find("monitor") or term

monitor.clear()
monitor.setCursorPos(1, 1)

local items = me.listItems()

-- Find an ingot
local testItem = nil
for _, item in ipairs(items) do
    if item.name:find("ingot") then
        testItem = item
        break
    end
end

if testItem then
    monitor.write("Item: " .. testItem.name)
    monitor.setCursorPos(1, 2)
    monitor.write("Amount: " .. testItem.amount)
    
    monitor.setCursorPos(1, 3)
    monitor.write("--- Tags ---")
    
    local row = 4
    if testItem.tags then
        -- Print all tags
        for tagKey, tagValue in pairs(testItem.tags) do
            monitor.setCursorPos(1, row)
            monitor.write(tagKey .. " = " .. tostring(tagValue))
            row = row + 1
            
            if row > 15 then break end -- Stop if too many
        end
    else
        monitor.setCursorPos(1, row)
        monitor.write("No tags found")
    end
end