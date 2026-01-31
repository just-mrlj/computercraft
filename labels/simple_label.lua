-- ===================================
-- MACHINE LABEL DISPLAY
-- Simple script to label machines
-- ===================================

local monitor = peripheral.find("monitor")

if not monitor then
    print("Error: No monitor found!")
    print("Please connect a monitor to the computer.")
    return
end

-- ===================================
-- CONFIGURATION
-- ===================================

print("=== Machine Label Setup ===")
print("")

-- Get label text
print("Enter label text:")
local labelText = read()

-- Get text scale
print("")
print("Enter text scale (0.5 - 5.0, default 1.0):")
print("Smaller = more text fits, Larger = easier to read")
local scaleInput = read()
local textScale = tonumber(scaleInput) or 1.0
if textScale < 0.5 then textScale = 0.5 end
if textScale > 5.0 then textScale = 5.0 end

-- Get background color
print("")
print("Select background color:")
print("1. Black")
print("2. Blue")
print("3. Green")
print("4. Red")
print("5. Gray")
print("6. White")
local bgChoice = tonumber(read()) or 1

local bgColors = {
    colors.black,
    colors.blue,
    colors.green,
    colors.red,
    colors.gray,
    colors.white
}
local bgColor = bgColors[bgChoice] or colors.black

-- Get text color
print("")
print("Select text color:")
print("1. White")
print("2. Yellow")
print("3. Orange")
print("4. Red")
print("5. Lime")
print("6. Cyan")
print("7. Black")
local textChoice = tonumber(read()) or 1

local textColors = {
    colors.white,
    colors.yellow,
    colors.orange,
    colors.red,
    colors.lime,
    colors.cyan,
    colors.black
}
local textColor = textColors[textChoice] or colors.white

-- ===================================
-- DISPLAY LABEL
-- ===================================

monitor.setTextScale(textScale)
monitor.setBackgroundColor(bgColor)
monitor.clear()
monitor.setTextColor(textColor)

local w, h = monitor.getSize()

-- Center the text
local x = math.floor((w - #labelText) / 2) + 1
local y = math.floor(h / 2)

monitor.setCursorPos(x, y)
monitor.write(labelText)

-- ===================================
-- CONFIRMATION
-- ===================================

print("")
print("Label displayed successfully!")
print("Text: " .. labelText)
print("Scale: " .. textScale)
print("")
print("The label will stay on screen.")
print("Run this script again to change it.")