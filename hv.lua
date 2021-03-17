-- HV Bio Reactor
minetest.register_craft({
	output = "voltic_battery:hv_bioreactor0",
	recipe = {
		{"group:leaves", "default:steelblock", "group:leaves"},
		{"group:leaves", "voltic_battery:mv_bioreactor0", "group:leaves"},
		{"group:leaves", "technic:hv_cable", "group:leaves"}
	}
})

tech.register_bioreactor({
	tier           = "HV",
	max_charge     = 130,
	charge_rate    = 130,
	discharge_rate = 130,
	charge_step    = 1300,
	discharge_step = 1300,
    generate       = 130,
})

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
    generate       = 105, -- 0.001 of max (Or 80.7% of a HV Bioreactor)
})

