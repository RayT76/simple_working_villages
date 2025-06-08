local func = working_villages.require("jobs/util")
local co_command = working_villages.require("job_coroutines").commands
local use_vh1 = minetest.get_modpath("visual_harm_1ndicators")

local is_building = false



local function find_building(p)
	if minetest.get_node(p).name ~= "working_villages:building_marker" then
		return false
	end
	local meta = minetest.get_meta(p)
	if meta:get_string("state") ~= "begun" then
		return false
	end
	local build_pos = working_villages.buildings.get_build_pos(meta)
	if build_pos == nil then
		return false
	end
	if working_villages.buildings.get(build_pos)==nil then
		return false
	end
	return true
end
local searching_range = {x = 30, y = 20, z = 30}

local builder_searching_range = {x = 20, y = 5, z = 20}
local builder_searching_distance = 50
local builder_found_plant_target = nil
local builder_path_data = nil



working_villages.register_job("working_villages:job_builder", {
	description      = "builder (working_villages)",
	long_description = "I look for the nearest building marker with a started building site. "..
"There I'll help building up the building.\
If I have the materials of course. Also I'll look for building markers within a 10 block radius. "..
"And I ignore paused building sites.",
	inventory_image  = "default_paper.png^working_villages_builder.png",
	jobfunc = function(self)
		if use_vh1 then VH1.update_bar(self.object, self.health) end

		local my_pos = self.object:get_pos()
		self:handle_night()
		self:handle_job_pos()
		self:handle_doors()							-- TODO ADD TO THE REST OF THE BOTS
		if is_building == false then self:handle_goto_obstacles(true) end
		self:buried_check()


		self:count_timer("builder:search")
		if self:timer_exceeded("builder:search",50) then
--print("Searching for active building site")

			local marker = nil
			local test_pos = func.find_building_marker(self.pos_data.job_pos,300,20)
			if test_pos ~= nil then
--print("TEST Found building markers")
--print("DUMP:", dump(test_pos))

				local is_index = nil
				for index, ipos in pairs(test_pos) do
	
					if is_index == nil then
--print("BINDEX:", index, " data:", ipos) --  should change list to pos or item
						if find_building(ipos) then
							is_index = index
							marker = ipos
						end
					end
				end



				--find_building(p)
			else
				print("TEST NOT Found building marker")
			end


--			local marker = func.search_surrounding(self.object:get_pos(), find_building, searching_range)

			
			if marker == nil then
			 self:set_state_info("I am currently looking for a building site nearby.\nHowever there wasn't one the last time I checked.")
			else
				--print("DUMP:MARKER", dump(marker))



				local meta = minetest.get_meta(marker)
				--print("DUMP:META", dump(meta))
				local build_pos = working_villages.buildings.get_build_pos(meta)
        			local building_on_pos = working_villages.buildings.get(build_pos)
				if building_on_pos.nodedata and (meta:get_int("index") > #building_on_pos.nodedata) then
				  self:set_state_info("I am currently marking a building as finished.")

					-- TODO use my better function... maybe this works
					local destination = func.find_adjacent_clear(marker)
					destination = func.find_ground_below(destination)
					if destination==false then
						print("failure: no adjacent walkable found")
						destination = marker
					end
					

					self:go_to(destination,true)



					meta:set_string("state","built")
					is_building = false
					meta:set_string("house_label", "house " .. minetest.pos_to_string(marker))
					--TODO: save beds
					meta:set_string("formspec",working_villages.buildings.get_formspec(meta))
					return
				end





				-- TODO RT looking for a nil node ?? not sure why though
				self:set_state_info("I am currently working on a building.")
				is_building = true
				local nnode = working_villages.buildings.get(build_pos).nodedata[meta:get_int("index")]
				if nnode == nil then
					
					meta:set_int("index",meta:get_int("index")+1)
					return
				end





				local npos = nnode.pos


				nnode = nnode.node
				local nname = working_villages.buildings.get_registered_nodename(nnode.name)
				if nname == "air" then
					meta:set_int("index",meta:get_int("index")+1)
					return
				end
				local function is_material(name)
					return name == nname
				end
				local wield_stack = self:get_wield_item_stack()
				if nname:find("beds:") and nname:find("_top") then
					local inv = self:get_inventory()
					if inv:room_for_item("main", ItemStack(nname)) then
						inv:add_item("main", ItemStack(nname))
					else
						local msg = "builder at " .. minetest.pos_to_string(self.object:get_pos()) ..
							" doesn't have enough inventory space"
						if self.owner_name then
							minetest.chat_send_player(self.owner_name,msg)
						else
							print(msg)
						end
						-- should later be intelligent enough to use his own or any other chest
						self:set_state_info("I am currently waiting to get some space in my inventory.")
						return co_command.pause, "waiting for inventory space"
					end
				end


				-- TODO TRY OPENBOOK REPLACEMENT
				if (nname=="homedecor:book_open_blue") or (nname=="homedecor:book_open_red") or (nname=="homedecor:book_open_grey") or (nname=="homedecor:book_open_green") or (nname=="homedecor:book_open_violet") then
					if self:has_item_in_main(function (name) return name == "homedecor:book_red" end) then
						local inv = self:get_inventory()
					  	if inv:room_for_item("main", ItemStack(nname)) then
							self:replace_item_from_main(ItemStack("homedecor:book_red"),ItemStack(nname))
						else
							local msg = "builder at " .. minetest.pos_to_string(self.object:get_pos()) ..
							" doesn't have enough inventory space"
							if self.owner_name then
								minetest.chat_send_player(self.owner_name,msg)
							else
								print(msg)
							end
						-- should later be intelligent enough to use his own or any other chest
							self:set_state_info("I am currently waiting to get some space in my inventory.")
							return co_command.pause, "waiting for inventory space"
						end
					end
				end

				-- TODO TRY DOOR REPLACEMENT
				if (nname=="doors:door_wood_a") or (nname=="doors:door_wood_b") or (nname=="doors:door_wood_c") or (nname=="doors:door_wood_d") then
					if self:has_item_in_main(function (name) return name == "doors:door_wood" end) then
						local inv = self:get_inventory()
					  	if inv:room_for_item("main", ItemStack(nname)) then
							self:replace_item_from_main(ItemStack("doors:door_wood"),ItemStack(nname))
						else
							local msg = "builder at " .. minetest.pos_to_string(self.object:get_pos()) ..
							" doesn't have enough inventory space"
							if self.owner_name then
								minetest.chat_send_player(self.owner_name,msg)
							else
								print(msg)
							end
						-- should later be intelligent enough to use his own or any other chest
							self:set_state_info("I am currently waiting to get some space in my inventory.")
							return co_command.pause, "waiting for inventory space"
						end
					end
				end


				if nname=="default:torch_wall" then
					if self:has_item_in_main(function (name) return name == "default:torch" end) then
						local inv = self:get_inventory()
					  	if inv:room_for_item("main", ItemStack(nname)) then
							self:replace_item_from_main(ItemStack("default:torch"),ItemStack(nname))
						else
							local msg = "builder at " .. minetest.pos_to_string(self.object:get_pos()) ..
							" doesn't have enough inventory space"
							if self.owner_name then
								minetest.chat_send_player(self.owner_name,msg)
							else
								print(msg)
							end
						-- should later be intelligent enough to use his own chest
							self:set_state_info("I am currently waiting to get some space in my inventory.")
							return co_command.pause, "waiting for inventory space"
						end
					end
				end


				if nname=="default:glass" then
					
					nnode.param1 = 0
					
				end

				if is_material(wield_stack:get_name()) or self:has_item_in_main(is_material) then


			--local fpt = func.find_ground_below(found_plant_target)
--			print("NPOS=", dump(npos))
			local mydestination = func.get_closest_clear_spot(self.object:get_pos(),npos)	
--			print("mydestination=", mydestination)
			if mydestination == false or mydestination == nil then
				print("Builder: No clostest clear spot found")
				-- ? destination = target
				--found_plant_target = nil
				--mydestination = nil
				mydestination = npos
			end


					--print("trying to get into place")
					--local destination = func.find_adjacent_clear(npos)
					--FIXME: check if the ground is actually below (get_reachable)
					--destination = func.find_ground_below(destination)
					--if destination==false then
					--	print("failure: no adjacent walkable found")
						--mydestination = npos
					--end
					self:set_state_info("I am building.")


				--print("NNODE:", dump(nnode))
				--print("NPOS:", dump(npos))



				local gotores = self:go_to(mydestination, true)
				if gotores == false then
					print("Builder: pathfinder in use, I will wait")

										

				elseif gotores == nil then
		--			print("Builder: Could not get to the Place point at ", mydestination)
					--found_plant_target = nil
					--destination = nil
				elseif gotores == -1 then
		--			print("Builder: Got stuck i think need to recalculate ", mydestination)
					 gotores = self:go_to(mydestination, true)

					--found_plant_target = nil
					--destination = nil
				else
					if self:place(nnode,npos) then
		--				print("Builder: placed ok")
						meta:set_int("index",meta:get_int("index")+1)
						--found_plant_target = nil
						--destination = nil
					else
						print("Builder: Could not place at ",mydestination)
						--found_plant_target = nil
						--destination = nil
						--coroutine.yield(co_command.pause,"error in building")
					end
				end







					--self:go_to(destination, true)


					-- TODO check for dirt and remove if needed
					--function working_villages.villager:dig(pos,collect_drops)
--					local n_n = minetest.get_node(npos).name

					--print("Replacing ", n_n, " with ", nnode.name)

					--if (string.find(n_n,"air") then
					--			default:dirt

--					if n_n ~= "air" then
--						self:dig(npos,true)
--					end
--					print("trying to place an item")
--					self:place(nnode,npos)


-- TODO Just ignore a non placed item ??
--					if minetest.get_node(npos).name==nnode.name then
						--meta:set_int("index",meta:get_int("index")+1)
--					else
--						print("Something went wrong with the place")
--					end
				else
					local msg = "builder at " .. minetest.pos_to_string(self.object:get_pos()) .. " doesn't have " .. nname
					if self.owner_name then
						minetest.chat_send_player(self.owner_name,msg)
					else
						print(msg)
					end
					self:set_state_info(("I am currently waiting for somebody to give me some %s."):format(nname))
					coroutine.yield(co_command.pause,"waiting for materials")
				end
			end
		end
	end,
})
