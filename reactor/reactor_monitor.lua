-- ===================================
-- BIGGER REACTORS MONITOR
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
    textScale = 0.5
}

-- Degree symbol for CP437 encoding (ComputerCraft)
local DEGREE = string.char(176)

-- Color scheme
local COLORS = {
    background = colors.black,
    titleBar = colors.blue,
    titleText = colors.white,
    labelText = colors.lightGray,
    valueText = colors.white,
    goodValue = colors.lime,
    warnValue = colors.yellow,
    badValue = colors.red,
    barFull = colors.green,
    barEmpty = colors.gray,
    offline = colors.red
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

local function drawBar(x, y, width, percent, color)
    monitor.setCursorPos(x, y)
    monitor.setBackgroundColor(COLORS.barEmpty)
    monitor.write(string.rep(" ", width))
    
    local filled = math.floor(width * percent)
    if filled > 0 then
        monitor.setCursorPos(x, y)
        monitor.setBackgroundColor(color or COLORS.barFull)
        monitor.write(string.rep(" ", filled))
    end
    
    monitor.setBackgroundColor(COLORS.background)
end

local function drawLabel(x, y, label, value, valueColor)
    monitor.setCursorPos(x, y)
    monitor.setTextColor(COLORS.labelText)
    monitor.write(label .. ":")
    
    monitor.setTextColor(valueColor or COLORS.valueText)
    monitor.setCursorPos(x + #label + 2, y)
    monitor.write(tostring(value))
end

local function getTempColor(temp)
    if temp < 1000 then
        return COLORS.goodValue
    elseif temp < 1800 then
        return COLORS.warnValue
    else
        return COLORS.badValue
    end
end

-- ===================================
-- DISPLAY FUNCTION
-- ===================================

local function displayReactorInfo()
    monitor.setTextScale(CONFIG.textScale)
    monitor.setBackgroundColor(COLORS.background)
    monitor.clear()
    
    local w, h = monitor.getSize()
    
    -- ===== TITLE BAR =====
    monitor.setBackgroundColor(COLORS.titleBar)
    monitor.setCursorPos(1, 1)
    monitor.clearLine()
    monitor.setTextColor(COLORS.titleText)
    local title = "BIGGER REACTORS MONITOR"
    monitor.setCursorPos(math.floor((w - #title) / 2), 1)
    monitor.write(title)
    monitor.setBackgroundColor(COLORS.background)
    
    -- ===== GET REACTOR DATA =====
    local success, data = pcall(function()
        local batteryInfo = reactor.battery()
        local fuelInfo = reactor.fuelTank()
        
        return {
            active = reactor.active(),
            -- Battery info
            energy = batteryInfo.stored(),
            energyCapacity = batteryInfo.capacity(),
            energyProduction = batteryInfo.producedLastTick(),
            -- Temperatures
            fuelTemp = reactor.fuelTemperature(),
            casingTemp = reactor.casingTemperature(),
            stackTemp = reactor.stackTemperature(),
            -- Fuel info
            fuel = fuelInfo.fuel(),
            fuelCapacity = fuelInfo.capacity(),
            waste = fuelInfo.waste(),
            fuelReactivity = fuelInfo.fuelReactivity(),
            -- Burn rate might not exist in all versions
            fuelConsumption = fuelInfo.burnedLastTick and fuelInfo.burnedLastTick() or 0
        }
    end)
    
    if not success then
        monitor.setTextColor(COLORS.badValue)
        monitor.setCursorPos(2, 3)
        monitor.write("ERROR: Cannot read reactor data")
        monitor.setCursorPos(2, 5)
        monitor.setTextColor(COLORS.labelText)
        monitor.write(tostring(data))
        return
    end
    
    local row = 3
    
    -- ===== STATUS =====
    local statusText = data.active and "ONLINE" or "OFFLINE"
    local statusColor = data.active and COLORS.goodValue or COLORS.offline
    
    monitor.setCursorPos(2, row)
    monitor.setTextColor(COLORS.labelText)
    monitor.write("Status:")
    monitor.setTextColor(statusColor)
    monitor.setCursorPos(11, row)
    monitor.write(statusText)
    row = row + 2
    
    -- ===== ENERGY =====
    monitor.setTextColor(COLORS.labelText)
    monitor.setCursorPos(2, row)
    monitor.write("Energy Buffer")
    row = row + 1
    
    local energyPercent = data.energy / data.energyCapacity
    drawBar(2, row, w - 3, energyPercent, COLORS.barFull)
    
    monitor.setCursorPos(2, row + 1)
    monitor.setTextColor(COLORS.valueText)
    monitor.write(formatEnergy(data.energy) .. " / " .. formatEnergy(data.energyCapacity))
    
    monitor.setCursorPos(w - 12, row + 1)
    monitor.write(string.format("%.1f%%", energyPercent * 100))
    row = row + 3
    
    -- ===== PRODUCTION =====
    drawLabel(2, row, "Production", formatEnergy(data.energyProduction) .. "/t", COLORS.goodValue)
    row = row + 2
    
    -- ===== TEMPERATURES =====
    monitor.setTextColor(COLORS.labelText)
    monitor.setCursorPos(2, row)
    monitor.write("Temperatures")
    row = row + 1
    
    local fuelTempColor = getTempColor(data.fuelTemp)
    drawLabel(2, row, "  Fuel", string.format("%.0f%sC", data.fuelTemp, DEGREE), fuelTempColor)
    row = row + 1
    
    local stackTempColor = getTempColor(data.stackTemp)
    drawLabel(2, row, "  Stack", string.format("%.0f%sC", data.stackTemp, DEGREE), stackTempColor)
    row = row + 1
    
    local casingTempColor = getTempColor(data.casingTemp)
    drawLabel(2, row, "  Casing", string.format("%.0f%sC", data.casingTemp, DEGREE), casingTempColor)
    row = row + 2
    
    -- ===== FUEL =====
    monitor.setTextColor(COLORS.labelText)
    monitor.setCursorPos(2, row)
    monitor.write("Fuel Level")
    row = row + 1
    
    local fuelPercent = data.fuel / data.fuelCapacity
    local fuelColor = COLORS.barFull
    if fuelPercent < 0.1 then
        fuelColor = COLORS.badValue
    elseif fuelPercent < 0.3 then
        fuelColor = COLORS.warnValue
    end
    
    drawBar(2, row, w - 3, fuelPercent, fuelColor)
    
    monitor.setCursorPos(2, row + 1)
    monitor.setTextColor(COLORS.valueText)
    monitor.write(formatNumber(data.fuel) .. " / " .. formatNumber(data.fuelCapacity) .. " mB")
    
    monitor.setCursorPos(w - 12, row + 1)
    monitor.write(string.format("%.1f%%", fuelPercent * 100))
    row = row + 2
    
    if data.fuelConsumption > 0 then
        drawLabel(2, row, "  Burn Rate", formatNumber(data.fuelConsumption) .. " mB/t")
        row = row + 1
    end
    
    drawLabel(2, row, "  Reactivity", string.format("%.2f%%", data.fuelReactivity * 100))
    row = row + 2
    
    -- ===== WASTE =====
    monitor.setTextColor(COLORS.labelText)
    monitor.setCursorPos(2, row)
    monitor.write("Waste Level")
    row = row + 1
    
    local wastePercent = data.waste / data.fuelCapacity
    local wasteColor = COLORS.warnValue
    
    drawBar(2, row, w - 3, wastePercent, wasteColor)
    
    monitor.setCursorPos(2, row + 1)
    monitor.setTextColor(COLORS.valueText)
    monitor.write(formatNumber(data.waste) .. " mB")
    
    monitor.setCursorPos(w - 12, row + 1)
    monitor.write(string.format("%.1f%%", wastePercent * 100))
    row = row + 2
    
    -- ===== FOOTER =====
    monitor.setTextColor(COLORS.labelText)
    monitor.setCursorPos(2, h)
    monitor.write(os.date("%H:%M:%S"))
end

-- ===================================
-- MAIN LOOP
-- ===================================

print("Starting Bigger Reactors Monitor...")
print("Refresh rate: " .. CONFIG.refreshRate .. "s")
print("Press Ctrl+T to stop")

while true do
    local success, err = pcall(displayReactorInfo)
    
    if not success then
        print("Error: " .. tostring(err))
    end
    
    sleep(CONFIG.refreshRate)
end