local func = simple_working_villages.require("jobs/util")
local use_vh1 = minetest.get_modpath("visual_harm_1ndicators")
local pathfinder = simple_working_villages.require("pathfinder")


local cuttera = {
  -- more priority definitions
	names = {
-- TODO pick up seeds for wheat oats barley
		["farming:weed"]={},
		["default:grass"]={},
		["default:grass_1"]={},
		["default:grass_2"]={},
		["default:grass_3"]={},
		["default:grass_4"]={},
		["default:grass_5"]={},
		["default:marram_grass_1"]={},
		["default:marram_grass_2"]={},
		["default:marram_grass_3"]={},
		["default:marram_grass_4"]={},
		["default:marram_grass_5"]={},
		["default:dry_shrub"]={},
	},
  -- less priority definitions
	groups = {

	},
}

function cuttera.get_grass(item_name)
  -- check more priority definitions
	for key, value in pairs(cuttera.names) do
		if item_name==key then
			return value
		end
	end
  -- check less priority definitions
	for key, value in pairs(cuttera.groups) do
		if minetest.get_item_group(item_name, key) > 0 then
			return value;
		end
	end
	return nil
end

function cuttera.is_grass(item_name)
  local data = cuttera.get_grass(item_name);
  if (not data) then
    return false;
  end
  return true;
end

local function find_grass_node(pos)
	local node = minetest.get_node(pos);
  local data = cuttera.get_grass(node.name);
  if (not data) then
    return false;
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


local function put_func()
  return true;
end

local cuttera_searching_range = {x = 20, y = 5, z = 20}
local cuttera_searching_distance = 50
local cuttera_found_plant_target = nil
local cuttera_path_data = nil

simple_working_villages.register_job("simple_working_villages:villager_male_grasscuttera", {
	description      = "Grass cutter A (simple_working_villages)",
	long_description = "I keep your lawns looking prim and proper.",
	inventory_image  = "default_paper.png^working_villages_grass_collector.png",
	jobfunc = function(self)
		if use_vh1 then VH1.update_bar(self.object, self.health) end
		self:handle_night()
		self:handle_chest(nil, put_func)
		self:handle_job_pos()
		self:handle_obstacles()
		self:buried_check() -- FIX FOR SELF BURIED ERROR -- jumps into the ground ?


		if cuttera_found_plant_target ~= nil then 
			self:set_displayed_action("Cutting Grass")

			--local fpt = func.find_ground_below(found_plant_target)
			local destination = func.get_closest_clear_spot(self.object:get_pos(),cuttera_found_plant_target)	
			if destination == false or destination == nil then
				--found_plant_target = nil
				destination = cuttera_found_plant_target
			else

				cuttera_path_data = pathfinder.plot_movement_to_pos(self.object:get_pos(), destination, false)

				if cuttera_path_data == nil then
					-- TODO should indicate who cannot find a path
					print(self.object:get_luaentity().nametag, " No Path Found to ", destination)
					--return nil
				elseif cuttera_path_data == false then
					print(self.object:get_luaentity().nametag, " IT SEEMS PATHFINDER IS BUSY-- I WILL HAVE TO WAIT MY TURN")
					--return false 
				else
					local gotores = self:go_to_the(cuttera_path_data)
--					if gotores == false then
--						print("BUILDER: waiting for pathfinder")
--						found_plant_target = nil
--						destination = nil
--					else
						if self:dig(cuttera_found_plant_target,true) then
							cuttera_found_plant_target = nil
							destination = nil
						else
							cuttera_found_plant_target = nil
							destination = nil
						end
--					end
				end
			end
		else
			self:set_displayed_action("Searching for Grass to cut")
			self:count_timer("grasscollector:search")
			--self:count_timer("grasscollector:change_dir


			if self:timer_exceeded("grasscollector:search",40) then
--				found_plant_target = func.search_surrounding(self.object:get_pos(), find_grass_node, searching_range)--func.search_surrounding(self.object:get_pos(), find_herb_node, searching_range)
				cuttera_found_plant_target = func.search_surrounding(self.pos_data.job_pos, find_grass_node, cuttera_searching_range)--func.search_surrounding(self.object:get_pos(), find_herb_node, searching_range)
			end


			if cuttera_found_plant_target == nil then
				print("GRASSCUTTER: ADJUSTING SEARCH FROM ", cuttera_searching_distance)
				self.object:set_velocity{x = 0, y = 0, z = 0}				
				self:set_animation(simple_working_villages.animation_frames.STAND)
				cuttera_searching_distance = cuttera_searching_distance + 10000
				--print("GRASSCUTTER: expanding search to ", searching_distance)
				cuttera_searching_range.x = cuttera_searching_distance
				cuttera_searching_range.z = cuttera_searching_distance
			end
		end
	end,

})

simple_working_villages.cuttera = cuttera
