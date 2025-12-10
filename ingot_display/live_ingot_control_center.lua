-- ===================================
-- ME INGOT DISPLAY - Enhanced Version
-- ===================================

local me = peripheral.find("meBridge")
local monitor = peripheral.find("monitor")

if not me then error("ME Bridge not found!") end
if not monitor then error("Monitor not found!") end

-- ===================================
-- CONFIGURATION
-- ===================================

local CONFIG = {
    refreshRate = 5,      -- seconds between auto-refresh
    textScale = 0.5,      -- monitor text scale
    showTimestamp = true, -- show time in footer
    amountThresholds = {  -- color thresholds
        high = 10000,
        medium = 1000,
        low = 100
    }
}

-- ===================================
-- COLOR THEMES
-- ===================================

local THEMES = {
    default = {
        name = "Default",
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
        footerText = colors.gray
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
        footerText = colors.gray
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
        footerText = colors.gray
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
        footerText = colors.gray
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
        footerText = colors.gray
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
        footerText = colors.gray
    }
}

-- Theme names in order for cycling
local THEME_ORDER = {"default", "ocean", "forest", "fire", "dark", "neon"}
local currentThemeIndex = 1
local COLORS = THEMES[THEME_ORDER[currentThemeIndex]]

-- ===================================
-- STATE VARIABLES
-- ===================================

local sortMode = "amount" -- "amount" or "name"
local minAmount = 0        -- Filter threshold

-- ===================================
-- HELPER FUNCTIONS
-- ===================================

-- Format large numbers with commas
local function formatNumber(num)
    local formatted = tostring(num)
    local k
    while true do  
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

-- Draw a button
local function drawButton(x, y, width, text, isActive)
    local bgColor = isActive and COLORS.buttonActive or COLORS.buttonInactive
    local textColor = isActive and COLORS.buttonActiveText or COLORS.buttonText
    
    monitor.setBackgroundColor(bgColor)
    monitor.setTextColor(textColor)
    monitor.setCursorPos(x, y)
    
    -- Center text in button
    local padding = math.floor((width - #text) / 2)
    monitor.write(string.rep(" ", padding) .. text .. string.rep(" ", width - #text - padding))
    monitor.setBackgroundColor(COLORS.background)
end

-- Check if coordinates are within a button
local function isInButton(x, y, btnX, btnY, btnWidth)
    return x >= btnX and x < btnX + btnWidth and y == btnY
end

-- Get color based on amount
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

-- Cycle to next theme
local function nextTheme()
    currentThemeIndex = currentThemeIndex + 1
    if currentThemeIndex > #THEME_ORDER then
        currentThemeIndex = 1
    end
    COLORS = THEMES[THEME_ORDER[currentThemeIndex]]
end

-- ===================================
-- DISPLAY FUNCTIONS
-- ===================================

local function displayIngots()
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
    
    -- ===== CONTROL BUTTONS =====
    local buttonY = 3
    local buttonWidth = 11
    local spacing = 1
    
    -- Row 1: Sort buttons
    drawButton(2, buttonY, buttonWidth, "By Amount", sortMode == "amount")
    drawButton(2 + buttonWidth + spacing, buttonY, buttonWidth, "By Name", sortMode == "name")
    
    -- Row 2: Filter buttons
    buttonY = buttonY + 2
    drawButton(2, buttonY, buttonWidth, "All", minAmount == 0)
    drawButton(2 + buttonWidth + spacing, buttonY, buttonWidth, "100+", minAmount == 100)
    drawButton(2 + (buttonWidth + spacing) * 2, buttonY, buttonWidth, "1000+", minAmount == 1000)
    drawButton(2 + (buttonWidth + spacing) * 3, buttonY, buttonWidth, "10000+", minAmount == 10000)
    
    -- Theme button (right side)
    local themeButtonWidth = 14
    drawButton(w - themeButtonWidth - 1, 3, themeButtonWidth, "Theme", false)
    
    -- ===== GET AND FILTER ITEMS =====
    local items = me.listItems()
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
    
    local statsY = buttonY + 2
    monitor.setTextColor(COLORS.statsText)
    monitor.setCursorPos(2, statsY)
    monitor.write("Types: " .. #ingots)
    monitor.setCursorPos(15, statsY)
    monitor.write("Total: " .. formatNumber(totalAmount))
    
    -- Separator line
    monitor.setTextColor(COLORS.footerText)
    monitor.setCursorPos(1, statsY + 1)
    monitor.write(string.rep("-", w))
    
    -- ===== DISPLAY INGOTS =====
    local startRow = statsY + 2
    for i, item in ipairs(ingots) do
        local currentRow = startRow + i - 1
        if currentRow > h - 1 then break end -- Save space for footer
        
        monitor.setCursorPos(2, currentRow)
        
        -- Set color based on amount
        monitor.setTextColor(getAmountColor(item.amount))
        
        -- Format item name (shorten if needed)
        local name = item.displayName
        local maxNameLen = w - 16
        if #name > maxNameLen then
            name = name:sub(1, maxNameLen - 3) .. "..."
        end
        
        monitor.write(name)
        
        -- Right-align the amount
        local amountStr = formatNumber(item.amount)
        monitor.setCursorPos(w - #amountStr - 1, currentRow)
        monitor.setTextColor(COLORS.normalText)
        monitor.write(amountStr)
    end
    
    -- ===== FOOTER =====
    if CONFIG.showTimestamp then
        monitor.setTextColor(COLORS.footerText)
        monitor.setCursorPos(2, h)
        monitor.write(os.date("%H:%M:%S"))
    end
    
    -- Help text
    monitor.setTextColor(COLORS.footerText)
    local helpText = "Click buttons to change view"
    monitor.setCursorPos(w - #helpText - 1, h)
    monitor.write(helpText)
end

-- ===================================
-- INPUT HANDLING
-- ===================================

local function handleClick(x, y)
    local w = monitor.getSize()
    local buttonWidth = 11
    local spacing = 1
    
    -- Sort buttons (row 3)
    if isInButton(x, y, 2, 3, buttonWidth) then
        sortMode = "amount"
        return true
    elseif isInButton(x, y, 2 + buttonWidth + spacing, 3, buttonWidth) then
        sortMode = "name"
        return true
    end
    
    -- Filter buttons (row 5)
    if isInButton(x, y, 2, 5, buttonWidth) then
        minAmount = 0
        return true
    elseif isInButton(x, y, 2 + buttonWidth + spacing, 5, buttonWidth) then
        minAmount = 100
        return true
    elseif isInButton(x, y, 2 + (buttonWidth + spacing) * 2, 5, buttonWidth) then
        minAmount = 1000
        return true
    elseif isInButton(x, y, 2 + (buttonWidth + spacing) * 3, 5, buttonWidth) then
        minAmount = 10000
        return true
    end
    
    -- Theme button
    local themeButtonWidth = 14
    if isInButton(x, y, w - themeButtonWidth - 1, 3, themeButtonWidth) then
        nextTheme()
        return true
    end
    
    return false
end

-- ===================================
-- MAIN LOOP
-- ===================================

local function main()
    displayIngots()
    
    while true do
        local event, side, x, y = os.pullEvent()
        
        if event == "monitor_touch" then
            if handleClick(x, y) then
                displayIngots() -- Redraw after button click
            end
        elseif event == "timer" then
            displayIngots() -- Auto-refresh
        end
    end
end

-- Auto-refresh timer
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
print("Theme: " .. COLORS.name)
print("Refresh rate: " .. CONFIG.refreshRate .. "s")

-- Run both in parallel
parallel.waitForAny(main, autoRefresh)