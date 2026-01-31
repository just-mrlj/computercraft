# Ingot Display
The goal of this script is to list all available ingots in your `ME-System` and their amount. 
It also provides ways to filter said display.

## Configuration
You can configure the script through the use of the `Configuration` section:
```lua
-- ===================================
-- CONFIGURATION
-- ===================================

local CONFIG = {
    refreshRate = 5,
    textScale = 0.5,
    showTimestamp = true,
    reconnectDelay = 5,
    amountThresholds = {
        high = 10000,
        medium = 1000,
        low = 100
    }
}
```

## Themes
The script also comes with a theme switcher and allows you to define themes in the file itself.
Example structure for a theme:
```lua
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
    }
}
```


![Screenshot of the live_ingot_control_center.lua in action](https://github.com/just-mrlj/computercraft/blob/main/src/ingot_display.png?raw=true)