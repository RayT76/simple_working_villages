local func = working_villages.require("jobs/util")

local cutter = {
  -- more priority definitions
	names = {
-- TODO pick up seeds for wheat oats barleyw
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

function cutter.get_grass(item_name)
  -- check more priority definitions
	for key, value in pairs(cutter.names) do
		if item_name==key then
			return value
		end
	end
  -- check less priority definitions
	for key, value in pairs(cutter.groups) do
		if minetest.get_item_group(item_name, key) > 0 then
			return value;
		end
	end
	return nil
end

function cutter.is_grass(item_name)
  local data = cutter.get_grass(item_name);
  if (not data) then
    return false;
  end
  return true;
end

local function find_grass_node(pos)
	local node = minetest.get_node(pos);
  local data = cutter.get_grass(node.name);
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

local searching_range = {x = 10, y = 5, z = 10}

local function put_func()
  return true;
end

working_villages.register_job("working_villages:job_grass_cutter", {
	description      = "Grass cutter (working_villages)",
	long_description = "I keep your lawns looking prim and proper.",
	inventory_image  = "default_paper.png^working_villages_grass_collector.png",
	jobfunc = function(self)

		self:lists_nearest_item_by_condition(true,100)
		self:handle_night()
		self:handle_chest(nil, put_func)
		self:handle_job_pos()

		self:count_timer("grasscollector:search")
		self:count_timer("grasscollector:change_dir")
		self:handle_obstacles()
		if self:timer_exceeded("grasscollector:search",100) then
			self:collect_nearest_item_by_condition(cutter.is_grass, searching_range)
			local target = func.search_surrounding(self.object:get_pos(), find_grass_node, searching_range)
			if target ~= nil then
				local destination = func.find_adjacent_clear(target)
				if destination then
				  destination = func.find_ground_below(destination)
				end
				if destination==false then
					print("failure: no adjacent walkable found")
					destination = target
				end
				self:go_to(destination)
        --local grass_data = cutter.get_grass(minetest.get_node(target).name);
        cutter.get_grass(minetest.get_node(target).name);
				self:dig(target,true)
			end
		elseif self:timer_exceeded("grasscollector:change_dir",400) then
			self:change_direction_randomly()
		end
	end,
})

working_villages.cutter = cutter
