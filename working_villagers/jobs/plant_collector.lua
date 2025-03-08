local func = working_villages.require("jobs/util")

local herbs = {
  -- more priority definitions
	names = {
		["default:apple"]={},
		["default:cactus"]={collect_only_top=true},
		["default:papyrus"]={collect_only_top=true},
--		["default:dry_shrub"]={},
		["flowers:mushroom_brown"]={},
		["flowers:mushroom_red"]={},
		["default:blueberry_bush_leaves_with_berries"]={},

		["farming:artichoke_5"]={},
		["farming:asparagus_5"]={},
		["farming:barley_7"]={},
		["farming:beanpole_5"]={},
		["farming:beetroot_5"]={},
		["farming:blackberry_4"]={},
		["farming:blueberry_4"]={},
		["farming:cabbage_6"]={},
		["farming:carrot_7"]={},
		["farming:chili_8"]={},
		["farming:cocoa_4"]={},
		["farming:coffe_5"]={},
		["farming:corn_8"]={},
		["farming:cotton_8"]={},
		["farming:cucumber_4"]={},
		["farming:eggplant_3"]={},
		["farming:garlic_5"]={},
		["farming:grapes_8"]={},
		["farming:hemp_8"]={},
		["farming:lettuce_5"]={},
		["farming:melon_8"]={},
		["farming:mint_4"]={},
		["farming:oat_8"]={},
		["farming:onion_5"]={},
		["farming:parsley_3"]={},
		["farming:pea_5"]={},
		["farming:pepper_7"]={},
		["farming:pineaple_8"]={},
		["farming:potato_3"]={},
		["farming:pumpkin_8"]={},
		["farming:raspberry_4"]={},
		["farming:rhubarb_3"]={},
		["farming:rice_8"]={},
		["farming:rye_8"]={},
		["farming:soy_7"]={},
		["farming:spinach_4"]={},
		["farming:sunflower_8"]={},
		["farming:tomato_7"]={},
		["farming:vanilla_7"]={},
		["farming:wheat_8"]={},




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




-- check for wild or cultivated
	if (node.name == "farming:eggplant_3") then
		if (node.param2 ~= 3) then 
			return false;
		end;
--	end	
	elseif (node.name == "farming:asparagus_5") then
		if (node.param2 ~= 3) then 
			return false;
		end;
--	end	
	elseif (node.name == "farming:spinach_4") then
		if (node.param2 ~= 3) then 
			return false;
		end;
--	end	
	elseif(node.param2 ~= 0) then 
		return false;
	end;


  local data = herbs.get_herb(node.name);
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
--local searching_range = {x = 6, y = 5, z = 6}

local function put_func()
  return true;
end

working_villages.register_job("working_villages:job_herbcollector", {
	description      = "herb collector (working_villages)",
	long_description = "I look for all sorts of wild plants and collect them.",
	inventory_image  = "default_paper.png^working_villages_herb_collector.png",
	jobfunc = function(self)
		--print("Tick");
		self:handle_night()
		self:handle_chest(nil, put_func)
		self:handle_job_pos()

		--print("Starting Search");
		self:count_timer("herbcollector:search")
		self:count_timer("herbcollector:change_dir")
		self:handle_obstacles()

		if self:timer_exceeded("herbcollector:search",100) then
--			print("Searching for Plant");
			self:collect_nearest_item_by_condition(herbs.is_herb, searching_range)
			local target = func.search_surrounding(self.object:get_pos(), find_herb_node, searching_range)
			if target ~= nil then
--				print("Found something at ", target);





--				print("TargetDump = " , dump(target));
--				local tempnode = minetest.get_node(target);
--
--
--				if (tempnode ~= nil) then
--				  print("");
--				  print("nodeDUMP = ",tempnode);
--				  print("nodename = ",tempnode.name);
--				  --print("nodelight = ",tempnode.light);
--				  --print("nodegroups = ",tempnode.groups);
--				  print("nodeparam2 = ",tempnode.param2);
--				  print("nodetable = ",#tempnode);
--
--				  print("nodeipairs");
--				  for _,v in ipairs(tempnode) do print(v) end
--				
--
--				  print("nodepairs");
--				  for _,v in pairs(tempnode) do print(v) end
--				
--
--				else
--				  print("nodeDUMP = NIL");
--				end






				local destination = func.find_adjacent_clear(target)
				if destination then
				  destination = func.find_ground_below(destination)
				end
				if destination==false then
					print("failure: no adjacent walkable found")
					destination = target
				end
				self:go_to(destination)
        --local herb_data = herbs.get_herb(minetest.get_node(target).name);
        herbs.get_herb(minetest.get_node(target).name);
				self:dig(target,true)
			end
		elseif self:timer_exceeded("herbcollector:change_dir",400) then
--			print("Change Direction");
			self:change_direction_randomly()
		end
	end,
})

working_villages.herbs = herbs
