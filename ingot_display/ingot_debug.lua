local me = peripheral.find("meBridge")
local monitor = peripheral.find("monitor") or term

monitor.clear()
monitor.setCursorPos(1, 1)
monitor.write("=== ME Ingots ===")

local items = me.listItems()

-- Debug: Show total item count
monitor.setCursorPos(1, 2)
monitor.write("Total items: " .. #items)

local row = 4
local ingotCount = 0

for i, item in ipairs(items) do
    -- Check if tags exist
    if item.tags then
        -- Check if the specific tag exists
        if item.tags["minecraft:item/forge:ingots"] then
            monitor.setCursorPos(1, row)
            monitor.write(item.displayName .. ": " .. item.amount)
            row = row + 1
            ingotCount = ingotCount + 1
        end
    end
end

monitor.setCursorPos(1, 3)
monitor.write("Ingots found: " .. ingotCount)

-- Debug: Print first few items to see their structure
monitor.setCursorPos(1, row + 1)
monitor.write("--- Debug Info ---")
for i = 1, math.min(3, #items) do
    monitor.setCursorPos(1, row + 1 + i)
    monitor.write(items[i].name)
end