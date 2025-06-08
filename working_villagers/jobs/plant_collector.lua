local func = working_villages.require("jobs/util")
local co_command = working_villages.require("job_coroutines").commands
local use_vh1 = minetest.get_modpath("visual_harm_1ndicators")

local herbs = {
  -- more priority definitions
	names = {
		["default:apple"]={param2=0},				-- TODO check param 2
		["default:cactus"]={param2=0,collect_only_top=true},
		["default:papyrus"]={param2=0,collect_only_top=true},
		["flowers:mushroom_brown"]={param2=0},				-- TODO check param 2
		["flowers:mushroom_red"]={param2=0},				-- TODO check param 2
		["default:blueberry_bush_leaves_with_berries"]={param2=0},

		["farming:artichoke_5"]={param2=0},
		["farming:asparagus_5"]={param2=3},   -- TODO BREAKS THE RULES ON PARAM 2 = IS THE SAME FOR WILD AND CULTIVATED
		["farming:barley_8"]={param2=0},
		["farming:beanpole_5"]={param2=0},
		["farming:beetroot_5"]={param2=0},
		["farming:blackberry_4"]={param2=0},
		["farming:blueberry_4"]={param2=0},
		["farming:cabbage_6"]={param2=0},
		["farming:carrot_7"]={param2=0},
		["farming:chili_8"]={param2=0},
		["farming:cocoa_4"]={param2=0},
		["farming:coffe_5"]={param2=0},
		["farming:corn_8"]={param2=0},
		["farming:cotton_8"]={param2=0},
		["farming:cucumber_4"]={param2=0},
		["farming:eggplant_3"]={param2=3},
		["farming:garlic_5"]={param2=0},
		["farming:grapes_8"]={param2=0},
		["farming:hemp_7"]={param2=0},
		["farming:lettuce_5"]={param2=0},
		["farming:melon_8"]={param2=0},
		["farming:mint_4"]={param2=0},
		["farming:oat_8"]={param2=0},
		["farming:onion_5"]={param2=0},
		["farming:parsley_3"]={param2=0},
		["farming:pea_5"]={param2=0},
		["farming:pepper_7"]={param2=0},
		["farming:pineaple_8"]={param2=0},
		["farming:potato_3"]={param2=0},
		["farming:pumpkin_8"]={param2=0},
		["farming:raspberry_4"]={param2=0},
		["farming:rhubarb_3"]={param2=0},
		["farming:rice_8"]={param2=0},
		["farming:rye_8"]={param2=0},
		["farming:soy_7"]={param2=0},
		["farming:spinach_4"]={param2=3},
		["farming:sunflower_8"]={param2=0},
		["farming:tomato_7"]={param2=0},
		["farming:vanilla_7"]={param2=0},
		["farming:wheat_8"]={param2=0},

	},
--   less priority definitions
--	groups = {
--		["flora"]={},
--		["farming"]={},
--	},
}

function herbs.get_herb(item_name)
  -- check more priority definitions
	for key, value in pairs(herbs.names) do
		if item_name==key then
			return value
		end
	end
  -- check less priority definitions
--	for key, value in pairs(herbs.groups) do
--		if minetest.get_item_group(item_name, key) > 0 then
--			return value;
--		end
--	end
	return nil
end

function herbs.is_herb(item_name)
  local data = herbs.get_herb(item_name);
  if (not data) then
    return false;
  end
  return true;
end

local function find_herb_node(pos)
	local node = minetest.get_node(pos);
	local data = herbs.get_herb(node.name);
	if (not data) then
		return false;
	end

	-- check for wildness
	if (node.param2 ~= data.param2) then 
		return false
	end	

	if data.collect_only_top then
	-- prevent to collect plat part, which can continue to grow
		local pos_below = {x=pos.x, y=pos.y-1, z=pos.z}
		local node_below = minetest.get_node(pos_below);
		if (node_below.name~=node.name) then
			return false;
		end
		local pos_above = {x=pos.x, y=pos.y+1, z=pos.z}
		local node_above = minetest.get_node(pos_above);
		if (node_above.name==node.name) then
			return false;
		end
	end
	return true;
end

local searching_range = {x = 20, y = 5, z = 20}
local searching_distance = 50

local found_plant_target = nil
local is_searching = false


local function put_func()
  return true;
end

working_villages.register_job("working_villages:job_plantcollector", {
	description      = "plant collector (working_villages)",
	long_description = "I look for all sorts of wild plants and herbs to collect.",
	inventory_image  = "default_paper.png^working_villages_herb_collector.png",
	jobfunc = function(self)
		if use_vh1 then VH1.update_bar(self.object, self.health) end
		self:handle_night()
		self:handle_chest(nil, put_func)
		self:handle_job_pos()
		self:handle_obstacles()
		self:buried_check() -- FIX FOR SELF BURIED ERROR -- jumps into the ground ?

		if found_plant_target ~= nil and found_plant_target ~= false then 
			self:set_displayed_action("Collecting a plant at ",found_plant_target)
			is_searching = false
			local fpt = func.find_ground_below(found_plant_target)
			local destination = nil

			if fpt ~= nil then
				destination = func.get_closest_clear_spot(self.object:get_pos(),fpt)	
			else
				destination = func.get_closest_clear_spot(self.object:get_pos(),found_plant_target)
			end

			if destination == false or destination == nil then
				destination = found_plant_target
			else
				local gotores = self:go_to(destination)
				if gotores == false then
					print("PLANTCOLLECTOR: waiting for pathfinder")
				else--if gotores == nil then
				--	found_plant_target = nil
				--	destination = nil
				--else
				-- TODO testing... trying to dig anyway even if not at destination
					if self:dig(found_plant_target,true) then
						found_plant_target = nil
						destination = nil
					else
						found_plant_target = nil
						destination = nil
					end
				end
			end
		else
			self:set_displayed_action("Searching for Plants")
			self:count_timer("herbcollector:search")
			self:count_timer("herbcollector:change_dir")
			if self:timer_exceeded("herbcollector:search",40) then
				found_plant_target = func.search_surrounding(self.pos_data.job_pos, find_herb_node, searching_range)
			end
			if found_plant_target == nil then 
				self.object:set_velocity{x = 0, y = 0, z = 0}				
				self:set_animation(working_villages.animation_frames.STAND)
				searching_distance = searching_distance + 1000
				--print("PLANTCOLLECTOR: expanding search to ", searching_distance)
				searching_range.x = searching_distance
				searching_range.z = searching_distance


--				if is_searching then 
--					my_vel = self.object:get_velocity()
--					if my_vel.x == 0 and my_vel.z == 0 and my_vel.y == 0 then
--						self:change_direction_randomly()
--					end
--					if self:timer_exceeded("herbcollector:change_dir",500) then
--						self:change_direction_randomly()
--					end
--				else
--					is_searching = true
--					self:change_direction_randomly()
--				end
			end
		end
	end,
})

working_villages.herbs = herbs
