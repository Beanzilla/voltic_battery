--[[ About this mod:
    This mod was made so technic batteries could produce a small amount of energy
    The "rule" for these self generating batteries is quite simple...
    1. Each battery produces aproximatly 1% of it's max capacity.
    2. Regardless of environment the battery will produce energy.
    3. Due to self generating, the battery will naturaly have less max 
    capacity.
    4. Input and Output is 500 EUs faster
]]--

-- Setup
local path = minetest.get_modpath("voltic_battery")
tech = rawget(_G, "technic") or {}
dofile(path.."/registry.lua") -- Add the "upgraded" battery register

-- Activate tiers
dofile(path.."/lv.lua")
dofile(path.."/mv.lua")
dofile(path.."/hv.lua")

--[[ Stats:
    LV:
        Max:       26,000 (26 k)
        Input:     1,500  (1.5k)
        Output:    4,500  (4.5k)
        Generates: 26
    MV:
        Max:       130,000 (130 k)
        Input:     20,500  (20.5k)
        Output:    80,500  (80.5k)
        Generates: 130
    HV:
        Max:       650,000 (650  k)
        Input:     100,500 (100.5k)
        Output:    400,500 (400.5k)
        Generates: 650
--]]