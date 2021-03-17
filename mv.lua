-- MV Bio Reactor
minetest.register_craft({
	output = "voltic_battery:mv_bioreactor0",
	recipe = {
		{"group:leaves", "default:steelblock", "group:leaves"},
		{"group:leaves", "voltic_battery:lv_bioreactor0", "group:leaves"},
		{"group:leaves", "technic:mv_cable", "group:leaves"}
	}
})

tech.register_bioreactor({
	tier           = "MV",
	max_charge     = 58,
	charge_rate    = 58,
	discharge_rate = 58,
	charge_step    = 580,
	discharge_step = 580,
    generate       = 58,
})

-- MV Battery box

minetest.register_craft({
	output = 'voltic_battery:mv_battery_volt0',
	recipe = {
		{'technic:mv_battery_box0'},
		{"technic:solar_panel"},
	}
})

tech.register_battery_box2({
	tier           = "MV",
	max_charge     = 130000, -- 65% of 200,000
	charge_rate    = 20500,
	discharge_rate = 80500,
	charge_step    = 2000,
	discharge_step = 8000,
	upgrade        = 1,
	tube           = 1,
    generate       = 47, -- 0.001 of max (Or 81% of a MV Bioreactor)
})