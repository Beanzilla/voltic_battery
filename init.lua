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
        Max:       38,000 (38 k)
        Input:     1,500  (1.5k)
        Output:    4,500  (4.5k)
        Generates: 380
    MV:
        Max:       170,000 (170 k)
        Input:     20,500  (20.5k)
        Output:    80,500  (80.5k)
        Generates: 1,700   (1.5 k)
    HV:
        Max:       980,000 (980  k)
        Input:     100,500 (100.5k)
        Output:    400,500 (400.5k)
        Generates: 9,800   (9.8  k)
--]]