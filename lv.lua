-- LV Battery box

minetest.register_craft({
	output = 'voltic_battery:lv_battery_volt0',
	recipe = {
		{"technic:lv_battery_box0"},
		{"technic:solar_panel"},
	}
})

tech.register_battery_box2({
	tier           = "LV",
	max_charge     = 38000,
	charge_rate    = 1500,
	discharge_rate = 4500,
	charge_step    = 500,
	discharge_step = 800,
    generate       = 380,
})