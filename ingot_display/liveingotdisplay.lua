local me = peripheral.find("meBridge")
local monitor = peripheral.find("monitor")

local green = 1000
local lime = 500
local yellow = 200
local orange = 100

if not me then
    error("ME Bridge not found!")
end

if not monitor then
    error("Monitor not found!")
end

monitor.setTextScale(0.5)

-- Helper function to format large numbers with commas
local function formatNumber(num)
    local formatted = tostring(num)
    local k
    while true do  
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

-- Helper function to draw a horizontal line
local function drawLine(y, char)
    monitor.setCursorPos(1, y)
    local w, h = monitor.getSize()
    monitor.write(string.rep(char or "-", w))
end

local function displayIngots()
    monitor.setBackgroundColor(colors.black)
    monitor.clear()
    
    local w, h = monitor.getSize()
    
    -- Title bar
    monitor.setBackgroundColor(colors.blue)
    monitor.setCursorPos(1, 1)
    monitor.clearLine()
    monitor.setTextColor(colors.white)
    local title = "ME SYSTEM - INGOTS"
    monitor.setCursorPos(math.floor((w - #title) / 2), 1)
    monitor.write(title)
    
    -- Reset background
    monitor.setBackgroundColor(colors.black)
    
    -- Get items
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
    
    -- Display count
    monitor.setCursorPos(1, 2)
    drawLine(2, "=")
    monitor.setTextColor(colors.yellow)
    monitor.setCursorPos(2, 3)
    monitor.write("Total Types: " .. #ingots)
    
    -- Calculate total amount
    local totalAmount = 0
    for _, ingot in ipairs(ingots) do
        totalAmount = totalAmount + ingot.amount
    end
    monitor.setCursorPos(2, 4)
    monitor.write("Total Count: " .. formatNumber(totalAmount))
    
    drawLine(5, "=")
    
    -- Display ingots with colors
    local startRow = 6
    for i, item in ipairs(ingots) do
        if startRow + i - 1 > h then break end -- Don't overflow screen
        
        monitor.setCursorPos(2, startRow + i - 1)
        
        -- Color code based on amount
        if item.amount >= green then
            monitor.setTextColor(colors.lime)
        elseif item.amount >= lime then
            monitor.setTextColor(colors.green)
        elseif item.amount >= yellow then
            monitor.setTextColor(colors.yellow)
        else
            monitor.setTextColor(colors.orange)
        end
        
        -- Format item name (shorten if needed)
        local name = item.displayName
        local maxNameLen = w - 15
        if #name > maxNameLen then
            name = name:sub(1, maxNameLen - 3) .. "..."
        end
        
        monitor.write(name)
        
        -- Right-align the amount
        local amountStr = formatNumber(item.amount)
        monitor.setCursorPos(w - #amountStr - 1, startRow + i - 1)
        monitor.setTextColor(colors.white)
        monitor.write(amountStr)
    end
    
    -- Footer
    monitor.setTextColor(colors.gray)
    monitor.setCursorPos(2, h)
    monitor.write(os.date("%H:%M:%S"))
end

-- Main loop
while true do
    displayIngots()
    sleep(5)
end