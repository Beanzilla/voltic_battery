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
    generate       = 325, -- 0.25% of max
})