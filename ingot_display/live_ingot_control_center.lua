-- ===================================
-- ME INGOT DISPLAY - Crash Resistant
-- ===================================

local monitor = peripheral.find("monitor")

if not monitor then error("Monitor not found!") end

-- ===================================
-- CONFIGURATION
-- ===================================

local CONFIG = {
    refreshRate = 5,
    textScale = 0.5,
    showTimestamp = true,
    reconnectDelay = 5, -- seconds to wait before reconnecting
    amountThresholds = {
        high = 10000,
        medium = 1000,
        low = 100
    }
}

-- ===================================
-- COLOR THEMES
-- ===================================

local THEMES = {
    computercraft = {
        name = "CC",
        titleBar = colors.blue,
        titleText = colors.white,
        background = colors.black,
        buttonActive = colors.lime,
        buttonInactive = colors.gray,
        buttonText = colors.white,
        buttonActiveText = colors.black,
        amount_high = colors.lime,
        amount_medium = colors.green,
        amount_low = colors.yellow,
        amount_verylow = colors.orange,
        statsText = colors.yellow,
        normalText = colors.white,
        footerText = colors.gray,
        errorText = colors.red
    },
    
    ocean = {
        name = "Ocean",
        titleBar = colors.cyan,
        titleText = colors.white,
        background = colors.black,
        buttonActive = colors.lightBlue,
        buttonInactive = colors.gray,
        buttonText = colors.white,
        buttonActiveText = colors.black,
        amount_high = colors.lime,
        amount_medium = colors.lightBlue,
        amount_low = colors.cyan,
        amount_verylow = colors.blue,
        statsText = colors.lightBlue,
        normalText = colors.white,
        footerText = colors.gray,
        errorText = colors.red
    },
    
    forest = {
        name = "Forest",
        titleBar = colors.green,
        titleText = colors.white,
        background = colors.black,
        buttonActive = colors.lime,
        buttonInactive = colors.gray,
        buttonText = colors.white,
        buttonActiveText = colors.black,
        amount_high = colors.lime,
        amount_medium = colors.green,
        amount_low = colors.yellow,
        amount_verylow = colors.orange,
        statsText = colors.lime,
        normalText = colors.white,
        footerText = colors.gray,
        errorText = colors.red
    },
    
    fire = {
        name = "Fire",
        titleBar = colors.red,
        titleText = colors.white,
        background = colors.black,
        buttonActive = colors.orange,
        buttonInactive = colors.gray,
        buttonText = colors.white,
        buttonActiveText = colors.black,
        amount_high = colors.yellow,
        amount_medium = colors.orange,
        amount_low = colors.red,
        amount_verylow = colors.pink,
        statsText = colors.orange,
        normalText = colors.white,
        footerText = colors.gray,
        errorText = colors.white
    },
    
    dark = {
        name = "Dark",
        titleBar = colors.gray,
        titleText = colors.white,
        background = colors.black,
        buttonActive = colors.white,
        buttonInactive = colors.gray,
        buttonText = colors.white,
        buttonActiveText = colors.black,
        amount_high = colors.white,
        amount_medium = colors.lightGray,
        amount_low = colors.gray,
        amount_verylow = colors.gray,
        statsText = colors.lightGray,
        normalText = colors.white,
        footerText = colors.gray,
        errorText = colors.red
    },
    
    neon = {
        name = "Neon",
        titleBar = colors.purple,
        titleText = colors.white,
        background = colors.black,
        buttonActive = colors.magenta,
        buttonInactive = colors.gray,
        buttonText = colors.white,
        buttonActiveText = colors.white,
        amount_high = colors.pink,
        amount_medium = colors.magenta,
        amount_low = colors.purple,
        amount_verylow = colors.blue,
        statsText = colors.pink,
        normalText = colors.white,
        footerText = colors.gray,
        errorText = colors.red
    }
}

local THEME_ORDER = {"neon", "ocean", "forest", "fire", "dark", "computercraft"}
local currentThemeIndex = 1
local COLORS = THEMES[THEME_ORDER[currentThemeIndex]]

-- ===================================
-- STATE VARIABLES
-- ===================================

local me = nil  -- Will be set by connectME()
local sortMode = "amount"
local minAmount = 0
local lastError = nil
local connectionStatus = "disconnected"

-- ===================================
-- ME CONNECTION HANDLING
-- ===================================

-- Try to connect to ME system
local function connectME()
    me = peripheral.find("meBridge")
    if me then
        connectionStatus = "connected"
        lastError = nil
        return true
    else
        connectionStatus = "disconnected"
        lastError = "ME Bridge not found"
        return false
    end
end

-- Check if ME is still connected
local function checkMEConnection()
    if not me then
        return false
    end
    
    -- Try a simple operation to verify connection
    local success, result = pcall(function()
        return me.listItems ~= nil
    end)
    
    if not success or not result then
        connectionStatus = "disconnected"
        me = nil
        return false
    end
    
    return true
end

-- Safe wrapper for ME operations
local function safeMECall(func)
    if not checkMEConnection() then
        return nil, "ME system disconnected"
    end
    
    local success, result = pcall(func)
    
    if not success then
        lastError = result
        connectionStatus = "error"
        -- Try to reconnect
        me = nil
        return nil, result
    end
    
    return result, nil
end

-- ===================================
-- HELPER FUNCTIONS
-- ===================================

local function formatNumber(num)
    local formatted = tostring(num)
    local k
    while true do  
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

local function drawButton(x, y, width, text, isActive)
    local bgColor = isActive and COLORS.buttonActive or COLORS.buttonInactive
    local textColor = isActive and COLORS.buttonActiveText or COLORS.buttonText
    
    monitor.setBackgroundColor(bgColor)
    monitor.setTextColor(textColor)
    monitor.setCursorPos(x, y)
    
    local padding = math.floor((width - #text) / 2)
    monitor.write(string.rep(" ", padding) .. text .. string.rep(" ", width - #text - padding))
    monitor.setBackgroundColor(COLORS.background)
end

local function isInButton(x, y, btnX, btnY, btnWidth)
    return x >= btnX and x < btnX + btnWidth and y == btnY
end

local function getAmountColor(amount)
    if amount >= CONFIG.amountThresholds.high then
        return COLORS.amount_high
    elseif amount >= CONFIG.amountThresholds.medium then
        return COLORS.amount_medium
    elseif amount >= CONFIG.amountThresholds.low then
        return COLORS.amount_low
    else
        return COLORS.amount_verylow
    end
end

local function nextTheme()
    currentThemeIndex = currentThemeIndex + 1
    if currentThemeIndex > #THEME_ORDER then
        currentThemeIndex = 1
    end
    COLORS = THEMES[THEME_ORDER[currentThemeIndex]]
end

-- ===================================
-- ERROR DISPLAY
-- ===================================

local function displayError(errorMsg)
    monitor.setTextScale(CONFIG.textScale)
    monitor.setBackgroundColor(COLORS.background)
    monitor.clear()
    
    local w, h = monitor.getSize()
    
    -- Title bar
    monitor.setBackgroundColor(COLORS.titleBar)
    monitor.setCursorPos(1, 1)
    monitor.clearLine()
    monitor.setTextColor(COLORS.titleText)
    local title = "ME SYSTEM - ERROR"
    monitor.setCursorPos(math.floor((w - #title) / 2), 1)
    monitor.write(title)
    monitor.setBackgroundColor(COLORS.background)
    
    -- Error message
    monitor.setTextColor(COLORS.errorText)
    local centerY = math.floor(h / 2)
    
    monitor.setCursorPos(2, centerY - 2)
    monitor.write("CONNECTION LOST")
    
    monitor.setTextColor(COLORS.normalText)
    monitor.setCursorPos(2, centerY)
    monitor.write("Attempting to reconnect...")
    
    if errorMsg then
        monitor.setTextColor(COLORS.footerText)
        monitor.setCursorPos(2, centerY + 2)
        -- Wrap error message if too long
        if #errorMsg > w - 4 then
            errorMsg = errorMsg:sub(1, w - 7) .. "..."
        end
        monitor.write("Error: " .. errorMsg)
    end
    
    -- Status indicator
    monitor.setTextColor(COLORS.footerText)
    monitor.setCursorPos(2, h)
    monitor.write("Status: " .. connectionStatus)
    monitor.setCursorPos(w - 8, h)
    monitor.write(os.date("%H:%M:%S"))
end

-- ===================================
-- DISPLAY FUNCTIONS
-- ===================================

local function displayIngots()
    -- Check connection first
    if not checkMEConnection() then
        displayError(lastError)
        return false
    end
    
    monitor.setTextScale(CONFIG.textScale)
    monitor.setBackgroundColor(COLORS.background)
    monitor.clear()
    
    local w, h = monitor.getSize()
    
    -- ===== TITLE BAR =====
    monitor.setBackgroundColor(COLORS.titleBar)
    monitor.setCursorPos(1, 1)
    monitor.clearLine()
    monitor.setTextColor(COLORS.titleText)
    local title = "ME SYSTEM - INGOTS [" .. COLORS.name .. "]"
    monitor.setCursorPos(math.floor((w - #title) / 2), 1)
    monitor.write(title)
    monitor.setBackgroundColor(COLORS.background)
    
    -- ===== GET AND FILTER ITEMS =====
    local items, err = safeMECall(function()
        return me.listItems()
    end)
    
    if not items then
        displayError(err)
        return false
    end
    
    local ingots = {}
    
    for _, item in ipairs(items) do
        if item.tags then
            for _, tag in ipairs(item.tags) do
                if tag == "minecraft:item/forge:ingots" and item.amount >= minAmount then
                    table.insert(ingots, item)
                    break
                end
            end
        end
    end
    
    -- ===== SORT =====
    if sortMode == "amount" then
        table.sort(ingots, function(a, b) return a.amount > b.amount end)
    else
        table.sort(ingots, function(a, b) return a.displayName < b.displayName end)
    end
    
    -- ===== STATS =====
    local totalAmount = 0
    for _, ingot in ipairs(ingots) do
        totalAmount = totalAmount + ingot.amount
    end
    
    local statsY = 3
    monitor.setTextColor(COLORS.statsText)
    monitor.setCursorPos(2, statsY)
    monitor.write("Types: " .. #ingots)
    monitor.setCursorPos(15, statsY)
    monitor.write("Total: " .. formatNumber(totalAmount))
    
    -- Connection status indicator (small dot)
    monitor.setTextColor(COLORS.amount_high)
    monitor.setCursorPos(w - 1, statsY)
    monitor.write("*")
    
    -- Separator line
    monitor.setTextColor(COLORS.footerText)
    monitor.setCursorPos(1, statsY + 1)
    monitor.write(string.rep("-", w))
    
    -- ===== DISPLAY INGOTS =====
    local startRow = statsY + 2
    local endRow = h - 4
    for i, item in ipairs(ingots) do
        local currentRow = startRow + i - 1
        if currentRow > endRow then break end
        
        monitor.setCursorPos(2, currentRow)
        monitor.setTextColor(getAmountColor(item.amount))
        
        local name = item.displayName
        local maxNameLen = w - 16
        if #name > maxNameLen then
            name = name:sub(1, maxNameLen - 3) .. "..."
        end
        
        monitor.write(name)
        
        local amountStr = formatNumber(item.amount)
        monitor.setCursorPos(w - #amountStr - 1, currentRow)
        monitor.setTextColor(COLORS.normalText)
        monitor.write(amountStr)
    end
    
    -- ===== CONTROL BUTTONS AT BOTTOM =====
    local buttonWidth = 11
    local spacing = 1
    local buttonY = h - 2
    
    monitor.setTextColor(COLORS.footerText)
    monitor.setCursorPos(1, buttonY - 1)
    monitor.write(string.rep("-", w))
    
    drawButton(2, buttonY, buttonWidth, "By Amount", sortMode == "amount")
    drawButton(2 + buttonWidth + spacing, buttonY, buttonWidth, "By Name", sortMode == "name")
    
    local themeButtonWidth = 14
    drawButton(w - themeButtonWidth - 1, buttonY, themeButtonWidth, "Theme", false)
    
    buttonY = buttonY + 1
    drawButton(2, buttonY, buttonWidth, "All", minAmount == 0)
    drawButton(2 + buttonWidth + spacing, buttonY, buttonWidth, "100+", minAmount == 100)
    drawButton(2 + (buttonWidth + spacing) * 2, buttonY, buttonWidth, "1000+", minAmount == 1000)
    drawButton(2 + (buttonWidth + spacing) * 3, buttonY, buttonWidth, "10000+", minAmount == 10000)
    
    if CONFIG.showTimestamp then
        monitor.setTextColor(COLORS.footerText)
        local timeStr = os.date("%H:%M:%S")
        monitor.setCursorPos(w - #timeStr - 1, buttonY)
        monitor.write(timeStr)
    end
    
    return true
end

-- ===================================
-- INPUT HANDLING
-- ===================================

local function handleClick(x, y)
    local w, h = monitor.getSize()
    local buttonWidth = 11
    local spacing = 1
    
    if isInButton(x, y, 2, h - 2, buttonWidth) then
        sortMode = "amount"
        return true
    elseif isInButton(x, y, 2 + buttonWidth + spacing, h - 2, buttonWidth) then
        sortMode = "name"
        return true
    end
    
    local themeButtonWidth = 14
    if isInButton(x, y, w - themeButtonWidth - 1, h - 2, themeButtonWidth) then
        nextTheme()
        return true
    end
    
    if isInButton(x, y, 2, h - 1, buttonWidth) then
        minAmount = 0
        return true
    elseif isInButton(x, y, 2 + buttonWidth + spacing, h - 1, buttonWidth) then
        minAmount = 100
        return true
    elseif isInButton(x, y, 2 + (buttonWidth + spacing) * 2, h - 1, buttonWidth) then
        minAmount = 1000
        return true
    elseif isInButton(x, y, 2 + (buttonWidth + spacing) * 3, h - 1, buttonWidth) then
        minAmount = 10000
        return true
    end
    
    return false
end

-- ===================================
-- MAIN LOOP
-- ===================================

local function main()
    -- Initial connection attempt
    if not connectME() then
        displayError("Initial connection failed")
    end
    
    displayIngots()
    
    while true do
        local event, side, x, y = os.pullEvent()
        
        if event == "monitor_touch" then
            if handleClick(x, y) then
                displayIngots()
            end
        elseif event == "timer" then
            -- Try to reconnect if disconnected
            if not checkMEConnection() then
                print("Connection lost, attempting reconnect...")
                sleep(CONFIG.reconnectDelay)
                connectME()
            end
            displayIngots()
        elseif event == "peripheral" or event == "peripheral_detach" then
            -- Peripheral changed, try to reconnect
            sleep(1)
            connectME()
            displayIngots()
        end
    end
end

local function autoRefresh()
    while true do
        sleep(CONFIG.refreshRate)
        os.queueEvent("timer")
    end
end

-- ===================================
-- START PROGRAM
-- ===================================

print("Starting ME Ingot Display...")
print("Refresh rate: " .. CONFIG.refreshRate .. "s")
print("Attempting to connect to ME system...")

-- Run both in parallel
parallel.waitForAny(main, autoRefresh)