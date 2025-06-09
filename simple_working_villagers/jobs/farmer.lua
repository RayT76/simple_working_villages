local func = working_villages.require("jobs/util")
local co_command = working_villages.require("job_coroutines").commands
local use_vh1 = minetest.get_modpath("visual_harm_1ndicators")

-- limited support to two replant definitions
local farming_plants = {
	names = {
		["farming:artichoke_5"]={replant={"farming:artichoke"}},
		["farming:asparagus_5"]={replant={"farming:asparagus"}},
		["farming:barley_8"]={replant={"farming:seed_barley"}},
		["farming:beanpole_5"]={replant={"farming:beanpole","farming:beans"}},  -- untested
		["farming:beetroot_5"]={replant={"farming:beetroot"}},
		["farming:blackberry_4"]={replant={"farming:blackberry"}},
		["farming:blueberry_4"]={replant={"farming:blueberries"}},
		["farming:cabbage_6"]={replant={"farming:cabbage"}},
		["farming:carrot_8"]={replant={"farming:carrot"}},
		["farming:chili_8"]={replant={"farming:chili_pepper"}},
		["farming:cocoa_4"]={replant={"farming:cocoa_beans"}},
		["farming:coffee_5"]={replant={"farming:coffee_beans"}},
		["farming:corn_8"]={replant={"farming:corn"}},
		["farming:cotton_8"]={replant={"farming:seed_cotton"}},
		["farming:cucumber_4"]={replant={"farming:cucumber"}},
		["farming:eggplant_4"]={replant={"farming:eggplant"}},
		["farming:garlic_5"]={replant={"farming:garlic_clove"}},
		["farming:ginger_4"]={replant={"farming:ginger"}},
		["farming:grapes_8"]={replant={"farming:trellis","farming:grapes"}},  -- untested
		["farming:hemp_8"]={replant={"farming:seed_hemp"}}, -- cannot seen to replant
		["farming:lettuce_5"]={replant={"farming:lettuce"}},
		["farming:melon_8"]={replant={"farming:melon_slice"}}, -- cannot seen to replant
		["farming:mint_4"]={replant={"farming:seed_mint"}},
		["farming:oat_8"]={replant={"farming:seed_oat"}},
		["farming:onion_5"]={replant={"farming:onion"}},
		["farming:parsley_3"]={replant={"farming:parsley"}},
		["farming:pea_5"]={replant={"farming:pea_pod"}},
		["farming:pepper_7"]={replant={"farming:peppercorn"}}, -- cannot seen to replant
		["farming:pineapple_8"]={replant={"farming:pineapple_top"}},
		["farming:potato_4"]={replant={"farming:potato"}},
		["farming:pumpkin_8"]={replant={"farming:pumpkin_slice"}}, -- cannot seen to replant
		["farming:raspberry_4"]={replant={"farming:raspberries"}},
		["farming:rhubarb_4"]={replant={"farming:rhubarb"}},
		["farming:rice_8"]={replant={"farming:seed_rice"}},
		["farming:rye_8"]={replant={"farming:seed_rye"}},
		["farming:soy_7"]={replant={"farming:soy_pod"}},
		["farming:spinach_4"]={replant={"farming:spinach"}},
		["farming:sunflower_8"]={replant={"farming:seed_sunflower"}}, -- cannot seen to replant
		["farming:tomato_8"]={replant={"farming:tomato"}},
		["farming:vanilla_8"]={replant={"farming:vanilla"}},
		["farming:wheat_8"]={replant={"farming:seed_wheat"}},

		["ethereal:strawberry_8"]={replant={"ethereal:strawberry"}},

	},
}

local farming_demands = {
	["farming:beanpole"] = 99,
	["farming:trellis"] = 99,
}

function farming_plants.get_plant(item_name)
	-- check more priority definitions
	for key, value in pairs(farming_plants.names) do
		if item_name==key then
			return value
		end
	end
	return nil
end

function farming_plants.is_plant(item_name)
	local data = farming_plants.get_plant(item_name);
	if (not data) then
		return false;
	end
	return true;
end

local function find_plant_node(pos)
	local node = minetest.get_node(pos);
-- TODO rt : may have to rethink this.. some do not follow theaw
-- check here for wild or cultivated
	if (node.param2 == 0) then 
		return false;
	end;


	local data = farming_plants.get_plant(node.name);
	if (not data) then
		return false;
	end
	return true;
end

local searching_range = {x = 50, y = 3, z = 50}

local searching_distance = 50

local function put_func(_,stack)
	if farming_demands[stack:get_name()] then
		return false
	end
	return true;
end

local found_plant_target = nil
local is_searching = false
local need_to_unload = false

local function take_func(villager,stack)
	local item_name = stack:get_name()
	if farming_demands[item_name] then
		local inv = villager:get_inventory()
		local itemstack = ItemStack(item_name)
		itemstack:set_count(farming_demands[item_name])
		if (not inv:contains_item("main", itemstack)) then
			return true
		end
	end
	return false
end

working_villages.register_job("working_villages:job_farmer", {
	description			= "farmer (working_villages)",
	long_description = "I look for cultivated plants to harvest and replant.",
	inventory_image	= "default_paper.png^working_villages_farmer.png",
	jobfunc = function(self)
		if use_vh1 then VH1.update_bar(self.object, self.health) end


-- ONCE ONLY ON CREATE
		if self.job_data["isstarted"] == nil then
			self.job_data["isstarted"] = true		-- to make sure this only runs once
            self.pos_data["job_pos"] = self.object:get_pos() 
        end




		self:handle_night()
		self:handle_chest(take_func, put_func)

		self:handle_job_pos()
		self:buried_check()

		if need_to_unload == false then
			if found_plant_target ~= nil then 

				is_searching = false
				local destination = func.get_closest_clear_spot(self.object:get_pos(),found_plant_target)	
				if destination == false or destination == nil then
					destination = found_plant_target
				else
					local gotores = self:go_to(destination)
					if gotores == false then

					elseif gotores == nil then
						found_plant_target = nil
						destination = nil
					else
						local plant_data = farming_plants.get_plant(minetest.get_node(found_plant_target).name);
						local inv = self:get_inventory()
					  	if inv:room_for_item("main", ItemStack(minetest.get_node(found_plant_target).name)) then

							self:dig(found_plant_target,true)
							if plant_data and plant_data.replant then
								self:delay(100)
								for index, value in ipairs(plant_data.replant) do
									self:place(value, vector.add(found_plant_target, vector.new(0,index-1,0)))
								end
							end
							found_plant_target = nil
							destination = nil
							self:delay(50)
						else
							need_to_unload = true
						end
					end
				end

			else
				self:count_timer("farmer:change_dir")
				found_plant_target = func.search_surrounding(self.object:get_pos(), find_plant_node, searching_range)
				if found_plant_target == nil then 

					


					if is_searching then 
						local my_vel = self.object:get_velocity()
						if my_vel.x == 0 and my_vel.z == 0 and my_vel.y == 0 then
							self:change_direction_randomly()
						end
						if self:timer_exceeded("farmer:change_dir",500) then
							self:change_direction_randomly()
						end
					else

						


						is_searching = true
						self:change_direction_randomly()
					end




				end
			end
		else
			self.job_data.manipulated_chest = false
			while self:handle_chest(take_func, put_func) ~= true do 
				-- wait for handle_chest to return			
			end
			need_to_unload = false
		end
	end,
})

working_villages.farming_plants = farming_plants
