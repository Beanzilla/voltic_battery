-- HV battery box

minetest.register_craft({
	output = 'voltic_battery:hv_battery_volt0',
	recipe = {
		{'technic:hv_battery_box0'},
		{"technic:solar_panel"},
	}
})

tech.register_battery_box2({
	tier           = "HV",
	max_charge     = 650000, -- 65% of 1,000,000
	charge_rate    = 100500,
	discharge_rate = 400500,
	charge_step    = 10000,
	discharge_step = 40000,
	upgrade        = 1,
	tube           = 1,
    generate       = 1625, -- 0.25% of max
})

