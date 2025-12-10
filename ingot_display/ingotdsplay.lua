local me = peripheral.find("meBridge")
local monitor = peripheral.find("monitor") or term

monitor.clear()
monitor.setCursorPos(1, 1)
monitor.write("=== ME Ingots ===")

local items = me.listItems()
local row = 2

for i, item in ipairs(items) do
    -- Check for the ingots tag
    if item.tags and item.tags["minecraft:item/forge:ingots"] then
        monitor.setCursorPos(1, row)
        monitor.write(item.displayName .. ": " .. item.amount)
        row = row + 1
    end
end