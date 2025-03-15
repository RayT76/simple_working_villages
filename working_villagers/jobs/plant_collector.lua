local func = working_villages.require("jobs/util")
local use_vh1 = minetest.get_modpath("visual_harm_1ndicators")

local herbs = {
  -- more priority definitions
	names = {
		["default:apple"]={param2=0},				-- TODO check param 2
		["default:cactus"]={param2=0,collect_only_top=true},
		["default:papyrus"]={param2=0,collect_only_top=true},
		["flowers:mushroom_brown"]={param2=0},				-- TODO check param 2
		["flowers:mushroom_red"]={param2=0},				-- TODO check param 2
		["default:blueberry_bush_leaves_with_berries"]={},

		["farming:artichoke_5"]={param2=0},
		["farming:asparagus_5"]={param2=3},   -- TODO BREAKS THE RULES ON PARAM 2 = IS THE SAME FOR WILD AND CULTIVATED
		["farming:barley_7"]={param2=0},
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
		["farming:hemp_8"]={param2=0},
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
  -- less priority definitions
	groups = {
--		["flora"]={},
--		["farming"]={},
	},
}

function herbs.get_herb(item_name)
  -- check more priority definitions
	for key, value in pairs(herbs.names) do
		if item_name==key then
			return value
		end
	end
  -- check less priority definitions
	for key, value in pairs(herbs.groups) do
		if minetest.get_item_group(item_name, key) > 0 then
			return value;
		end
	end
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

local searching_range = {x = 10, y = 5, z = 10}

local function put_func()
  return true;
end

working_villages.register_job("working_villages:job_plantcollector", {
	description      = "plant collector (working_villages)",
	long_description = "I look for all sorts of wild plants and herbs to collect.",
	inventory_image  = "default_paper.png^working_villages_herb_collector.png",
	jobfunc = function(self)
		if use_vh1 then VH1.update_bar(self.object, self.health) end
		--print("Tick");
		self:handle_night()
		self:handle_chest(nil, put_func)
		self:handle_job_pos()

		--print("Starting Search");
		self:count_timer("herbcollector:search")
		self:count_timer("herbcollector:change_dir")
		self:handle_obstacles()

		if self:timer_exceeded("herbcollector:search",20) then
--			print("Looking for a Plant");
			self:collect_nearest_item_by_condition(herbs.is_herb, searching_range)
			local target = func.search_surrounding(self.object:get_pos(), find_herb_node, searching_range)
			if target ~= nil then
--				print("Found a Plant");
			
				local destination = func.find_adjacent_clear(target)
				if destination then
				  destination = func.find_ground_below(destination)
				end
				if destination==false then
					print("plant_collector: No adjacent walkable found")
					destination = target
				end
	
				if self:go_to(destination) then
--					print("Got to the Plant")
				else
					print("plant_collector: Could not get to the Plant")
				end

				if self:dig(target,true) then
--					print("I got the Plant")
				else
					print("plant_collector: Could not dig the Plant")
				end
			else
--				print("Cant find a Plant");	
			end
			
		elseif self:timer_exceeded("herbcollector:change_dir",400) then
--			print("Changed Direction");
			self:change_direction_randomly()
		end
	end,
})

working_villages.herbs = herbs
