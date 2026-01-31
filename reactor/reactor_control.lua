-- ===================================
-- BIGGER REACTORS CONTROL CENTER
-- ===================================

local monitor = peripheral.find("monitor")
local reactor = peripheral.wrap("BiggerReactors_Reactor_0")

if not monitor then
    error("No monitor found!")
end

if not reactor then
    error("No reactor found!")
end

-- ===================================
-- CONFIGURATION
-- ===================================

local CONFIG = {
    refreshRate = 1,
    textScale = 0.5,
    autoShutdown = true,
    maxTemp = 2000,
    autoFuelShutdown = true,
    minFuelPercent = 5
}

-- Degree symbol for CP437 encoding (ComputerCraft)
local DEGREE = string.char(176)

-- Colors
local COLORS = {
    background = colors.black,
    titleBar = colors.blue,
    titleText = colors.white,
    labelText = colors.lightGray,
    valueText = colors.white,
    goodValue = colors.lime,
    warnValue = colors.yellow,
    badValue = colors.red,
    buttonOn = colors.green,
    buttonOff = colors.red,
    buttonControl = colors.blue,
    buttonText = colors.white
}

-- ===================================
-- HELPER FUNCTIONS
-- ===================================

local function formatNumber(num)
    if num >= 1000000 then
        return string.format("%.2fM", num / 1000000)
    elseif num >= 1000 then
        return string.format("%.2fK", num / 1000)
    else
        return string.format("%.1f", num)
    end
end

local function formatEnergy(rf)
    if rf >= 1000000000 then
        return string.format("%.2f GRF", rf / 1000000000)
    elseif rf >= 1000000 then
        return string.format("%.2f MRF", rf / 1000000)
    elseif rf >= 1000 then
        return string.format("%.2f KRF", rf / 1000)
    else
        return string.format("%.0f RF", rf)
    end
end

local function drawButton(x, y, width, text, color)
    monitor.setBackgroundColor(color)
    monitor.setTextColor(COLORS.buttonText)
    monitor.setCursorPos(x, y)
    
    local padding = math.floor((width - #text) / 2)
    monitor.write(string.rep(" ", padding) .. text .. string.rep(" ", width - #text - padding))
    monitor.setBackgroundColor(COLORS.background)
end

local function isInButton(mx, my, x, y, width, height)
    return mx >= x and mx < x + width and my >= y and my < y + (height or 1)
end

local function drawBar(x, y, width, percent, color)
    monitor.setCursorPos(x, y)
    monitor.setBackgroundColor(colors.gray)
    monitor.write(string.rep(" ", width))
    
    local filled = math.floor(width * percent)
    if filled > 0 then
        monitor.setCursorPos(x, y)
        monitor.setBackgroundColor(color)
        monitor.write(string.rep(" ", filled))
    end
    
    monitor.setBackgroundColor(COLORS.background)
end

-- ===================================
-- SAFETY CHECKS
-- ===================================

local function performSafetyChecks(data)
    local alerts = {}
    
    -- Temperature check
    if CONFIG.autoShutdown and data.fuelTemp > CONFIG.maxTemp then
        if data.active then
            reactor.setActive(false)
            table.insert(alerts, "EMERGENCY SHUTDOWN: Temperature too high!")
        end
    end
    
    -- Fuel check
    if CONFIG.autoFuelShutdown then
        local fuelPercent = (data.fuel / data.fuelCapacity) * 100
        if fuelPercent < CONFIG.minFuelPercent then
            if data.active then
                reactor.setActive(false)
                table.insert(alerts, "AUTO SHUTDOWN: Low fuel!")
            end
        end
    end
    
    return alerts
end

-- ===================================
-- DISPLAY FUNCTION
-- ===================================

local function displayControl()
    monitor.setTextScale(CONFIG.textScale)
    monitor.setBackgroundColor(COLORS.background)
    monitor.clear()
    
    local w, h = monitor.getSize()
    
    -- ===== TITLE BAR =====
    monitor.setBackgroundColor(COLORS.titleBar)
    monitor.setCursorPos(1, 1)
    monitor.clearLine()
    monitor.setTextColor(COLORS.titleText)
    local title = "REACTOR CONTROL CENTER"
    monitor.setCursorPos(math.floor((w - #title) / 2), 1)
    monitor.write(title)
    monitor.setBackgroundColor(COLORS.background)
    
    -- ===== GET DATA =====
    local success, data = pcall(function()
        local batteryInfo = reactor.battery()
        local fuelInfo = reactor.fuelTank()
        
        return {
            active = reactor.active(),
            energy = batteryInfo.stored(),
            energyCapacity = batteryInfo.capacity(),
            energyProduction = batteryInfo.producedLastTick(),
            fuelTemp = reactor.fuelTemperature(),
            casingTemp = reactor.casingTemperature(),
            stackTemp = reactor.stackTemperature(),
            fuel = fuelInfo.fuel(),
            fuelCapacity = fuelInfo.capacity(),
            waste = fuelInfo.waste(),
            fuelConsumption = fuelInfo.burnedLastTick and fuelInfo.burnedLastTick() or 0
        }
    end)
    
    if not success then
        monitor.setTextColor(COLORS.badValue)
        monitor.setCursorPos(2, 3)
        monitor.write("ERROR: Cannot read reactor")
        return
    end
    
    -- Safety checks
    local alerts = performSafetyChecks(data)
    
    local row = 3
    
    -- ===== STATUS & CONTROL BUTTON =====
    local statusText = data.active and "ONLINE" or "OFFLINE"
    local statusColor = data.active and COLORS.goodValue or COLORS.badValue
    
    monitor.setCursorPos(2, row)
    monitor.setTextColor(COLORS.labelText)
    monitor.write("Status:")
    monitor.setTextColor(statusColor)
    monitor.setCursorPos(11, row)
    monitor.write(statusText)
    
    -- Power button
    local buttonColor = data.active and COLORS.buttonOff or COLORS.buttonOn
    local buttonText = data.active and "SHUTDOWN" or "START UP"
    drawButton(w - 12, row, 10, buttonText, buttonColor)
    
    row = row + 2
    
    -- ===== ALERTS =====
    if #alerts > 0 then
        for _, alert in ipairs(alerts) do
            monitor.setTextColor(COLORS.badValue)
            monitor.setCursorPos(2, row)
            monitor.write("! " .. alert)
            row = row + 1
        end
        row = row + 1
    end
    
    -- ===== ENERGY =====
    monitor.setTextColor(COLORS.labelText)
    monitor.setCursorPos(2, row)
    monitor.write("Energy: " .. formatEnergy(data.energyProduction) .. "/t")
    row = row + 1
    
    local energyPercent = data.energy / data.energyCapacity
    drawBar(2, row, w - 3, energyPercent, COLORS.goodValue)
    
    monitor.setCursorPos(2, row + 1)
    monitor.setTextColor(COLORS.valueText)
    monitor.write(formatEnergy(data.energy) .. " / " .. formatEnergy(data.energyCapacity))
    row = row + 3
    
    -- ===== TEMPERATURES =====
    local tempColor = COLORS.goodValue
    if data.fuelTemp > 1800 then
        tempColor = COLORS.badValue
    elseif data.fuelTemp > 1000 then
        tempColor = COLORS.warnValue
    end
    
    monitor.setTextColor(COLORS.labelText)
    monitor.setCursorPos(2, row)
    monitor.write("Fuel:")
    monitor.setTextColor(tempColor)
    monitor.setCursorPos(9, row)
    monitor.write(string.format("%.0f%sC", data.fuelTemp, DEGREE))
    
    monitor.setTextColor(COLORS.labelText)
    monitor.setCursorPos(20, row)
    monitor.write("Stack:")
    monitor.setTextColor(COLORS.valueText)
    monitor.setCursorPos(28, row)
    monitor.write(string.format("%.0f%sC", data.stackTemp, DEGREE))
    
    monitor.setTextColor(COLORS.labelText)
    monitor.setCursorPos(w - 18, row)
    monitor.write("Casing:")
    monitor.setTextColor(COLORS.valueText)
    monitor.setCursorPos(w - 10, row)
    monitor.write(string.format("%.0f%sC", data.casingTemp, DEGREE))
    row = row + 2
    
    -- ===== FUEL =====
    monitor.setTextColor(COLORS.labelText)
    monitor.setCursorPos(2, row)
    local fuelPercent = data.fuel / data.fuelCapacity
    monitor.write(string.format("Fuel: %.1f%% (%.1f mB/t)", fuelPercent * 100, data.fuelConsumption))
    row = row + 1
    
    local fuelColor = COLORS.goodValue
    if fuelPercent < 0.1 then
        fuelColor = COLORS.badValue
    elseif fuelPercent < 0.3 then
        fuelColor = COLORS.warnValue
    end
    
    drawBar(2, row, w - 3, fuelPercent, fuelColor)
    row = row + 2
    
    -- ===== WASTE =====
    monitor.setTextColor(COLORS.labelText)
    monitor.setCursorPos(2, row)
    local wastePercent = data.waste / data.fuelCapacity
    monitor.write(string.format("Waste: %.1f%%", wastePercent * 100))
    row = row + 1
    
    drawBar(2, row, w - 3, wastePercent, COLORS.warnValue)
    row = row + 2
    
    -- ===== FOOTER =====
    monitor.setTextColor(COLORS.labelText)
    monitor.setCursorPos(2, h)
    monitor.write(os.date("%H:%M:%S"))
    
    monitor.setCursorPos(w - 25, h)
    monitor.write("Touch buttons to control")
end

-- ===================================
-- INPUT HANDLING
-- ===================================

local function handleClick(x, y)
    local w, h = monitor.getSize()
    
    -- Power button
    if isInButton(x, y, w - 12, 3, 10, 1) then
        local isActive = reactor.active()
        reactor.setActive(not isActive)
        return true
    end
    
    return false
end

-- ===================================
-- MAIN LOOP
-- ===================================

local function main()
    displayControl()
    
    while true do
        local event, side, x, y = os.pullEvent()
        
        if event == "monitor_touch" then
            if handleClick(x, y) then
                sleep(0.5)
                displayControl()
            end
        elseif event == "timer" then
            displayControl()
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
-- START
-- ===================================

print("Starting Reactor Control Center...")
print("Auto-shutdown enabled: " .. tostring(CONFIG.autoShutdown))
print("Max temperature: " .. CONFIG.maxTemp .. DEGREE .. "C")
print("Press Ctrl+T to stop")

parallel.waitForAny(main, autoRefresh)