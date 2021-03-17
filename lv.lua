-- LV Bio Reactor
minetest.register_craft({
	output = "voltic_battery:lv_bioreactor0",
	recipe = {
		{"group:leaves", "default:steelblock", "group:leaves"},
		{"group:leaves", "technic:machine_casing", "group:leaves"},
		{"group:leaves", "technic:lv_cable", "group:leaves"}
	}
})

tech.register_bioreactor({
	tier           = "LV",
	max_charge     = 32,
	charge_rate    = 32,
	discharge_rate = 32,
	charge_step    = 320,
	discharge_step = 320,
    generate       = 32,
})

-- LV Battery box

minetest.register_craft({
	type = "shapeless",
	output = 'voltic_battery:lv_battery_volt0',
	recipe = {
		"technic:lv_battery_box0",
		"voltic_battery:lv_bioreactor",
	}
})

tech.register_battery_box2({
	tier           = "LV",
	max_charge     = 26000, -- 65% of 40,000
	charge_rate    = 1500,
	discharge_rate = 4500,
	charge_step    = 500,
	discharge_step = 800,
    generate       = 26, -- 0.001 of max (Or 81.25% of a LV Bioreactor)
})