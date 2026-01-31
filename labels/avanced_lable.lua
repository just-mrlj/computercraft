-- ===================================
-- MACHINE LABEL DISPLAY - Advanced
-- Full-featured labeling system
-- ===================================

local monitor = peripheral.find("monitor")

if not monitor then
    print("Error: No monitor found!")
    return
end

-- ===================================
-- HELPER FUNCTIONS
-- ===================================

local function clearScreen()
    term.clear()
    term.setCursorPos(1, 1)
end

local function printMenu(title, options)
    clearScreen()
    print("=== " .. title .. " ===")
    print("")
    for i, option in ipairs(options) do
        print(i .. ". " .. option)
    end
    print("")
    print("Enter choice:")
end

local function displayLabel(config)
    monitor.setTextScale(config.scale)
    monitor.setBackgroundColor(config.bgColor)
    monitor.clear()
    monitor.setTextColor(config.textColor)
    
    local w, h = monitor.getSize()
    
    -- Handle multi-line text
    local lines = {}
    for line in config.text:gmatch("[^\n]+") do
        table.insert(lines, line)
    end
    
    -- Center vertically
    local startY = math.floor((h - #lines) / 2) + 1
    
    -- Display each line centered
    for i, line in ipairs(lines) do
        local x = math.floor((w - #line) / 2) + 1
        local y = startY + i - 1
        
        if y >= 1 and y <= h then
            monitor.setCursorPos(x, y)
            monitor.write(line)
        end
    end
end

local function saveConfig(config, filename)
    local file = fs.open(filename, "w")
    file.write(textutils.serialize(config))
    file.close()
end

local function loadConfig(filename)
    if not fs.exists(filename) then
        return nil
    end
    local file = fs.open(filename, "r")
    local data = file.readAll()
    file.close()
    return textutils.unserialize(data)
end

-- ===================================
-- COLOR DEFINITIONS
-- ===================================

local COLOR_NAMES = {
    "Black", "Red", "Green", "Brown", "Blue", "Purple",
    "Cyan", "Light Gray", "Gray", "Pink", "Lime", 
    "Yellow", "Light Blue", "Magenta", "Orange", "White"
}

local COLOR_VALUES = {
    colors.black, colors.red, colors.green, colors.brown,
    colors.blue, colors.purple, colors.cyan, colors.lightGray,
    colors.gray, colors.pink, colors.lime, colors.yellow,
    colors.lightBlue, colors.magenta, colors.orange, colors.white
}

local function selectColor(prompt)
    clearScreen()
    print("=== " .. prompt .. " ===")
    print("")
    for i, name in ipairs(COLOR_NAMES) do
        print(i .. ". " .. name)
    end
    print("")
    print("Enter choice (1-16):")
    local choice = tonumber(read())
    
    if choice and choice >= 1 and choice <= 16 then
        return COLOR_VALUES[choice], COLOR_NAMES[choice]
    end
    return colors.white, "White"
end

-- ===================================
-- MAIN MENU
-- ===================================

local config = {
    text = "Label",
    scale = 1.0,
    bgColor = colors.black,
    bgColorName = "Black",
    textColor = colors.white,
    textColorName = "White"
}

-- Try to load saved config
local savedConfig = loadConfig("label_config.txt")
if savedConfig then
    print("Found saved configuration. Load it? (y/n)")
    local response = read()
    if response:lower() == "y" then
        config = savedConfig
        print("Loaded saved configuration!")
        sleep(1)
    end
end

while true do
    clearScreen()
    print("=== MACHINE LABEL CONFIGURATOR ===")
    print("")
    print("Current Settings:")
    print("  Text: " .. config.text:gsub("\n", " / "))
    print("  Scale: " .. config.scale)
    print("  Background: " .. config.bgColorName)
    print("  Text Color: " .. config.textColorName)
    print("")
    print("Options:")
    print("1. Change Text")
    print("2. Change Text Scale")
    print("3. Change Background Color")
    print("4. Change Text Color")
    print("5. Preview")
    print("6. Apply & Exit")
    print("7. Save Configuration")
    print("8. Exit without Applying")
    print("")
    print("Enter choice:")
    
    local choice = tonumber(read())
    
    if choice == 1 then
        clearScreen()
        print("=== Enter Label Text ===")
        print("")
        print("Enter text (press Enter when done):")
        print("For multi-line, use | to separate lines")
        print("Example: Line 1|Line 2|Line 3")
        print("")
        local input = read()
        config.text = input:gsub("|", "\n")
        
    elseif choice == 2 then
        clearScreen()
        print("=== Text Scale ===")
        print("")
        print("Current scale: " .. config.scale)
        print("Enter new scale (0.5 - 5.0):")
        print("0.5 = very small, 1.0 = normal, 5.0 = very large")
        print("")
        local scale = tonumber(read())
        if scale and scale >= 0.5 and scale <= 5.0 then
            config.scale = scale
        else
            print("Invalid scale! Keeping current value.")
            sleep(1)
        end
        
    elseif choice == 3 then
        config.bgColor, config.bgColorName = selectColor("Background Color")
        
    elseif choice == 4 then
        config.textColor, config.textColorName = selectColor("Text Color")
        
    elseif choice == 5 then
        displayLabel(config)
        print("")
        print("Preview displayed on monitor.")
        print("Press Enter to continue...")
        read()
        
    elseif choice == 6 then
        displayLabel(config)
        clearScreen()
        print("Label applied successfully!")
        print("")
        print("Configuration:")
        print("  Text: " .. config.text:gsub("\n", " / "))
        print("  Scale: " .. config.scale)
        print("  Background: " .. config.bgColorName)
        print("  Text Color: " .. config.textColorName)
        break
        
    elseif choice == 7 then
        saveConfig(config, "label_config.txt")
        print("")
        print("Configuration saved to label_config.txt")
        sleep(1)
        
    elseif choice == 8 then
        clearScreen()
        print("Exiting without applying changes.")
        break
    end
end