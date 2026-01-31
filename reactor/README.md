# Scripts to monitor/control **BIGGER REACOTRS**
The goal of these 3 scripts is to function as a monitoring and controlling and also debugging tool for the [Bigger Reactors](https://www.curseforge.com/minecraft/mc-mods/biggerreactors) mod.
The scripts have been written for the mod version `0.6.0-beta.10.4`

## 1. `reactor_monitor.lua`
Monitoring script showing crucial information. Including color coding of the temperatures (eventho the reactors don't blow up in this version yet) and bar graphs for Energy, Fuel and Waste.

------------------------------------------------------
## 2. `reactor_control.lua`
Script to control the reactor.
Includes two safety features:
1. Overheating protection
2. Under fueling protection
Both of these settings can be configured in the top of the file under the section configuration:
```lua
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
```

------------------------------------------------------
3. `reactor_discovery.lua`
The last file is more of a debug file. While setting up the connection to the reactor I didn't 100% know what to connect to so I asked an LLM to write a debug script laying out the peripherals and this is the result.
It should find a Reactor that is properly hooked up to a computer.