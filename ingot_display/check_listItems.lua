local me = peripheral.find("meBridge")
local monitor = peripheral.find("monitor") or term

monitor.clear()
monitor.setCursorPos(1, 1)

local items = me.listItems()

-- Find an item that should be an ingot
local testItem = nil
for _, item in ipairs(items) do
    if item.name:find("ingot") then
        testItem = item
        break
    end
end

if testItem then
    monitor.write("Found ingot in list:")
    monitor.setCursorPos(1, 2)
    monitor.write(testItem.name)
    
    local row = 3
    monitor.setCursorPos(1, row)
    monitor.write("Keys in item:")
    
    -- Print all keys in the item
    for key, value in pairs(testItem) do
        row = row + 1
        monitor.setCursorPos(1, row)
        monitor.write(key .. " = " .. tostring(value))
    end
else
    monitor.write("No ingots in listItems()")
    
    -- Try getting gold ingot directly
    monitor.setCursorPos(1, 2)
    monitor.write("Trying getItem()...")
    
    local goldIngot = me.getItem({name = "minecraft:gold_ingot"})
    if goldIngot then
        monitor.setCursorPos(1, 3)
        monitor.write("getItem works!")
        monitor.setCursorPos(1, 4)
        monitor.write("Has tags: " .. tostring(goldIngot.tags ~= nil))
    end
end