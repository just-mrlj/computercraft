-- ===================================
-- DYNAMIC MACHINE LABEL
-- Shows updating information
-- ===================================

local monitor = peripheral.find("monitor")

if not monitor then
    error("No monitor found!")
end

-- ===================================
-- CONFIGURATION
-- ===================================

print("=== Dynamic Label Setup ===")
print("")
print("Enter main label text:")
local mainLabel = read()

print("")
print("Enter text scale (0.5-5.0, default 2.0):")
local scaleInput = read()
local textScale = tonumber(scaleInput) or 2.0

print("")
print("Show additional info?")
print("1. Just the label")
print("2. Label + Time")
print("3. Label + Date & Time")
print("4. Label + Status Indicator")
local infoChoice = tonumber(read()) or 1

print("")
print("Select color scheme:")
print("1. Classic (White on Black)")
print("2. Matrix (Lime on Black)")
print("3. Alert (Yellow on Red)")
print("4. Cool (Cyan on Blue)")
print("5. Warm (Orange on Brown)")
local colorChoice = tonumber(read()) or 1

local colorSchemes = {
    {bg = colors.black, text = colors.white, accent = colors.lightGray},
    {bg = colors.black, text = colors.lime, accent = colors.green},
    {bg = colors.red, text = colors.yellow, accent = colors.white},
    {bg = colors.blue, text = colors.cyan, accent = colors.lightBlue},
    {bg = colors.brown, text = colors.orange, accent = colors.yellow}
}

local scheme = colorSchemes[colorChoice]

-- ===================================
-- DISPLAY FUNCTIONS
-- ===================================

local function displayDynamicLabel()
    monitor.setTextScale(textScale)
    monitor.setBackgroundColor(scheme.bg)
    monitor.clear()
    
    local w, h = monitor.getSize()
    
    -- Main label (centered)
    monitor.setTextColor(scheme.text)
    local mainX = math.floor((w - #mainLabel) / 2) + 1
    local mainY = math.floor(h / 2)
    monitor.setCursorPos(mainX, mainY)
    monitor.write(mainLabel)
    
    -- Additional info based on choice
    if infoChoice == 2 then
        -- Show time
        monitor.setTextColor(scheme.accent)
        local timeStr = os.date("%H:%M:%S")
        local timeX = math.floor((w - #timeStr) / 2) + 1
        monitor.setCursorPos(timeX, mainY + 1)
        monitor.write(timeStr)
        
    elseif infoChoice == 3 then
        -- Show date and time
        monitor.setTextColor(scheme.accent)
        local dateStr = os.date("%Y-%m-%d")
        local timeStr = os.date("%H:%M:%S")
        
        local dateX = math.floor((w - #dateStr) / 2) + 1
        monitor.setCursorPos(dateX, mainY + 1)
        monitor.write(dateStr)
        
        local timeX = math.floor((w - #timeStr) / 2) + 1
        monitor.setCursorPos(timeX, mainY + 2)
        monitor.write(timeStr)
        
    elseif infoChoice == 4 then
        -- Show status indicator (blinking dot)
        monitor.setTextColor(scheme.accent)
        local statusText = "* ONLINE *"
        local statusX = math.floor((w - #statusText) / 2) + 1
        monitor.setCursorPos(statusX, mainY + 1)
        monitor.write(statusText)
    end
end

-- ===================================
-- MAIN LOOP
-- ===================================

print("")
print("Label configured!")
print("Displaying on monitor...")
print("Press Ctrl+T to stop")
print("")

local blinkState = true
local lastUpdate = os.clock()

while true do
    local currentTime = os.clock()
    
    -- Update display every 0.5 seconds
    if currentTime - lastUpdate >= 0.5 then
        displayDynamicLabel()
        
        -- Blink effect for status indicator
        if infoChoice == 4 then
            blinkState = not blinkState
            if blinkState then
                monitor.setTextColor(scheme.accent)
            else
                monitor.setTextColor(scheme.bg)
            end
            local w, h = monitor.getSize()
            local mainY = math.floor(h / 2)
            monitor.setCursorPos(math.floor(w/2) - 4, mainY + 1)
            monitor.write("*")
            monitor.setCursorPos(math.floor(w/2) + 5, mainY + 1)
            monitor.write("*")
        end
        
        lastUpdate = currentTime
    end
    
    sleep(0.1)
end