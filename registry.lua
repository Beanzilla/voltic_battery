
local digilines_path = minetest.get_modpath("digilines")

local S = tech.getter
local tube_entry = "^pipeworks_tube_connection_metallic.png"
local cable_entry = "^technic_cable_connection_overlay.png"

local fs_helpers = pipeworks.fs_helpers

-- x+2 + (z+2)*2
local dirtab = {
	[4] = 2,
	[5] = 3,
	[7] = 1,
	[8] = 0
}

local tube = {
	insert_object = function(pos, node, stack, direction)
		print(minetest.pos_to_string(direction), dirtab[direction.x+2+(direction.z+2)*2], node.param2)
		if direction.y == 1
			or (direction.y == 0 and dirtab[direction.x+2+(direction.z+2)*2] == node.param2) then
			return stack
		end
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		if direction.y == 0 then
			return inv:add_item("src", stack)
		else
			return inv:add_item("dst", stack)
		end
	end,
	can_insert = function(pos, node, stack, direction)
		print(minetest.pos_to_string(direction), dirtab[direction.x+2+(direction.z+2)*2], node.param2)
		if direction.y == 1
			or (direction.y == 0 and dirtab[direction.x+2+(direction.z+2)*2] == node.param2) then
			return false
		end
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		if direction.y == 0 then
			if meta:get_int("split_src_stacks") == 1 then
				stack = stack:peek_item(1)
			end
			return inv:room_for_item("src", stack)
		else
			if meta:get_int("split_dst_stacks") == 1 then
				stack = stack:peek_item(1)
			end
			return inv:room_for_item("dst", stack)
		end
	end,
	connect_sides = {left=1, right=1, back=1, top=1},
}

local function add_on_off_buttons(meta, ltier, charge_percent)
	local formspec = "image[1,1;1,2;technic_power_meter_bg.png"
			.."^[lowpart:"..charge_percent
			..":technic_power_meter_fg.png]"
	if ltier == "mv" or ltier == "hv" then
		formspec = formspec..
			fs_helpers.cycling_button(
				meta,
				"image_button[3,2.0;1,0.6",
				"split_src_stacks",
				{
					pipeworks.button_off,
					pipeworks.button_on
				}
			).."label[3.9,2.01;Allow splitting incoming 'charge' stacks from tubes]"..
			fs_helpers.cycling_button(
				meta,
				"image_button[3,2.5;1,0.6",
				"split_dst_stacks",
				{
					pipeworks.button_off,
					pipeworks.button_on
				}
			).."label[3.9,2.51;Allow splitting incoming 'discharge' stacks]"
	end
	return formspec
end

function tech.register_battery_box2(data)
	local tier = data.tier
	local ltier = string.lower(tier)
	local self_charge = data.generate

	-- Need to add some form of indicator internally to show how much we charge ourselves by.
	-- Would be nice to have it actually display some numbers rather than nothing
	local formspec =
		"size[8,9]"..
		"image[1,1;1,2;technic_power_meter_bg.png]"..
		"list[context;src;3,1;1,1;]"..
		"image[4,1;1,1;technic_battery_reload.png]"..
		"list[context;dst;5,1;1,1;]"..
		"label[0,0;"..S("Voltic %s Battery"):format(tier).."]"..
		"label[3,0;"..S("Charge").."]"..
		"label[5,0;"..S("Discharge").."]"..
		"label[1,3;"..S("Power level").."]"..
		"list[current_player;main;0,5;8,4;]"..
		"listring[context;dst]"..
		"listring[current_player;main]"..
		"listring[context;src]"..
		"listring[current_player;main]"

	if digilines_path then
		formspec = formspec.."button[0.6,3.7;2,1;edit_channel;edit Channel]"
	end

	if data.upgrade then
		formspec = formspec..
			"list[context;upgrade1;3.5,3;1,1;]"..
			"list[context;upgrade2;4.5,3;1,1;]"..
			"label[3.5,4;"..S("Upgrade Slots").."]"..
			"listring[context;upgrade1]"..
			"listring[current_player;main]"..
			"listring[context;upgrade2]"..
			"listring[current_player;main]"
	end

	local run = function(pos, node)
		local below = minetest.get_node({x=pos.x, y=pos.y-1, z=pos.z})
		local meta           = minetest.get_meta(pos)

		if not tech.is_tier_cable(below.name, tier) then
			meta:set_string("infotext", S("Voltic %s Battery Has No Network"):format(tier))
			return
		end

		local eu_input       = meta:get_int(tier.."_EU_input")
        eu_input = eu_input + self_charge -- Append the self charge input
        -- This should mean it always sees a charge input
		-- I.E. With nothing drawing power we'd produce our normal 380 Eu (Voltic LV Battery),
		-- But lets say that we have a power draw of 100, the battery will still charge up as we have 280 Eu surplus,
		-- Or our power draw could be say 500, then the really cost would be -120 Eu (We'd then start consuming power if avalible)
		local current_charge = meta:get_int("internal_EU_charge")

		local EU_upgrade, tube_upgrade = 0, 0
		if data.upgrade then
			EU_upgrade, tube_upgrade = tech.handle_machine_upgrades(meta)
		end
		local max_charge = data.max_charge * (1 + EU_upgrade / 10)

		-- Charge/discharge the battery with the input EUs
		if eu_input >= 0 then
			current_charge = math.min(current_charge + eu_input, max_charge)
		else
			current_charge = math.max(current_charge + eu_input, 0)
		end

		-- Charging/discharging tools here
		local tool_full, tool_empty
		current_charge, tool_full = tech.charge_tools(meta,
				current_charge, data.charge_step)
		current_charge, tool_empty = tech.discharge_tools(meta,
				current_charge, data.discharge_step,
				max_charge)

		if data.tube then
			local inv = meta:get_inventory()
			tech.handle_machine_pipeworks(pos, tube_upgrade,
			function(pos, x_velocity, z_velocity)
				if tool_full and not inv:is_empty("src") then
					tech.send_items(pos, x_velocity, z_velocity, "src")
				elseif tool_empty and not inv:is_empty("dst") then
					tech.send_items(pos, x_velocity, z_velocity, "dst")
				end
			end)
		end

		-- We allow batteries to charge on less than the demand
		meta:set_int(tier.."_EU_demand",
				math.min(data.charge_rate, max_charge - current_charge))
		meta:set_int(tier.."_EU_supply",
				math.min(data.discharge_rate, current_charge))
			meta:set_int("internal_EU_charge", current_charge)

		-- Select node textures
		local charge_count = math.ceil((current_charge / max_charge) * 8)
		charge_count = math.min(charge_count, 8)
		charge_count = math.max(charge_count, 0)
		local last_count = meta:get_float("last_side_shown")
		if charge_count ~= last_count then
			tech.swap_node(pos,"voltic_battery:"..ltier.."_battery_volt"..charge_count)
			meta:set_float("last_side_shown", charge_count)
		end

		local charge_percent = math.floor(current_charge / max_charge * 100)
		meta:set_string("formspec", formspec..add_on_off_buttons(meta, ltier, charge_percent))
		-- Display the amount we are getting (Or net value)
	    local infotext = S("Voltic @1 Battery: @2 / @3 (@4)", tier,
				tech.EU_string(current_charge),
				tech.EU_string(max_charge),
				tech.EU_string(eu_input)) -- Could be negative
		if eu_input == 0 then
			infotext = S("%s Idle"):format(infotext)
		end
		meta:set_string("infotext", infotext)
	end

	for i = 0, 8 do
		local groups = {snappy=2, choppy=2, oddly_breakable_by_hand=2,
				technic_machine=1, ["technic_"..ltier]=1}
		if i ~= 0 then
			groups.not_in_creative_inventory = 1
		end

		if data.tube then
			groups.tubedevice = 1
			groups.tubedevice_receiver = 1
		end

		-- Changed textures so they look different so a user doesn't need the info in the hud
		local top_tex = "voltic_battery_"..ltier.."_battery_box_top.png"..tube_entry
		local front_tex = "technic_"..ltier.."_battery_box_front.png^technic_power_meter"..i..".png"
		local side_tex = "voltic_battery_"..ltier.."_battery_box_side.png"..tube_entry
		local bottom_tex = "voltic_battery_"..ltier.."_battery_box_bottom.png"..cable_entry

		if ltier == "lv" then
			top_tex = "voltic_battery_"..ltier.."_battery_box_top.png"
			front_tex = "voltic_battery_"..ltier.."_battery_box_side.png^technic_power_meter"..i..".png"
			side_tex = "voltic_battery_"..ltier.."_battery_box_side.png^technic_power_meter"..i..".png"
		end

		minetest.register_node("voltic_battery:"..ltier.."_battery_volt"..i, {
			description = S("Voltic %s Battery"):format(tier),
			tiles = {
				top_tex,
				bottom_tex,
				side_tex,
				side_tex,
				side_tex,
				front_tex},
			groups = groups,
			connect_sides = {"bottom"},
			tube = data.tube and tube or nil,
			paramtype2 = "facedir",
			sounds = default.node_sound_wood_defaults(),
			drop = "voltic_battery:"..ltier.."_battery_volt0",
			on_construct = function(pos)
				local meta = minetest.get_meta(pos)
				local EU_upgrade, tube_upgrade = 0, 0
				if data.upgrade then
					EU_upgrade, tube_upgrade = tech.handle_machine_upgrades(meta)
				end
				local max_charge = data.max_charge * (1 + EU_upgrade / 10)
				local charge = meta:get_int("internal_EU_charge")
				local cpercent = math.floor(charge / max_charge * 100)
				local inv = meta:get_inventory()
				meta:set_string("infotext", S("Voltic %s Battery"):format(tier))
				meta:set_string("formspec", formspec..add_on_off_buttons(meta, ltier, cpercent))
				meta:set_string("channel", ltier.."_battery_volt"..minetest.pos_to_string(pos))
				meta:set_int(tier.."_EU_demand", 0)
				meta:set_int(tier.."_EU_supply", 0)
				meta:set_int(tier.."_EU_input",  0)
				meta:set_float("internal_EU_charge", 0)
				inv:set_size("src", 1)
				inv:set_size("dst", 1)
				inv:set_size("upgrade1", 1)
				inv:set_size("upgrade2", 1)
			end,
			can_dig = tech.machine_can_dig,
			allow_metadata_inventory_put = tech.machine_inventory_put,
			allow_metadata_inventory_take = tech.machine_inventory_take,
			allow_metadata_inventory_move = tech.machine_inventory_move,
			technic_run = run,
			on_rotate = screwdriver.rotate_simple,
			after_place_node = data.tube and pipeworks.after_place,
			after_dig_node = tech.machine_after_dig_node,
			on_receive_fields = function(pos, formname, fields, sender)
				local meta = minetest.get_meta(pos)
				if fields.edit_channel then
					minetest.show_formspec(sender:get_player_name(),
						"technic:battery_box_edit_channel"..minetest.pos_to_string(pos),
						"field[channel;Digiline Channel;"..meta:get_string("channel").."]")
				elseif fields["fs_helpers_cycling:0:split_src_stacks"]
				  or   fields["fs_helpers_cycling:0:split_dst_stacks"]
				  or   fields["fs_helpers_cycling:1:split_src_stacks"]
				  or   fields["fs_helpers_cycling:1:split_dst_stacks"] then
					meta = minetest.get_meta(pos)
					if not pipeworks.may_configure(pos, sender) then return end
					fs_helpers.on_receive_fields(pos, fields)
					local EU_upgrade, tube_upgrade = 0, 0
					if data.upgrade then
						EU_upgrade, tube_upgrade = tech.handle_machine_upgrades(meta)
					end
					local max_charge = data.max_charge * (1 + EU_upgrade / 10)
					local charge = meta:get_int("internal_EU_charge")
					local cpercent = math.floor(charge / max_charge * 100)
					meta:set_string("formspec", formspec..add_on_off_buttons(meta, ltier, cpercent))
				end
			end,
			digiline = {
				receptor = {action = function() end},
				effector = {
					action = function(pos, node, channel, msg)
						if msg ~= "GET" and msg ~= "get" then
							return
						end
						local meta = minetest.get_meta(pos)
						if channel ~= meta:get_string("channel") then
							return
						end
						local inv = meta:get_inventory()
						digilines.receptor_send(pos, digilines.rules.default, channel, {
							demand = meta:get_int(tier.."_EU_demand"),
							supply = meta:get_int(tier.."_EU_supply"),
							input  = meta:get_int(tier.."_EU_input"),
							charge = meta:get_int("internal_EU_charge"),
							max_charge = data.max_charge * (1 + tech.handle_machine_upgrades(meta) / 10),
							src      = inv:get_stack("src", 1):to_table(),
							dst      = inv:get_stack("dst", 1):to_table(),
							upgrade1 = inv:get_stack("upgrade1", 1):to_table(),
							upgrade2 = inv:get_stack("upgrade2", 1):to_table()
						})
					end
				},
			},
		})
	end

	-- Register as a battery type
	-- Battery type machines function as power reservoirs and can both receive and give back power
	for i = 0, 8 do
		tech.register_machine(tier, "voltic_battery:"..ltier.."_battery_volt"..i, tech.battery)
	end

end -- End registration
