local fail = simple_working_villages.require("failures")
local log = simple_working_villages.require("log")
local func = simple_working_villages.require("jobs/util")
local co_command = simple_working_villages.require("job_coroutines").commands
local pathfinder = simple_working_villages.require("pathfinder")

--TODO: add variable precision

function simple_working_villages.villager:go_on_the_path(mydest, isrunning)
		

		local mypos = self.object:get_pos()
	--	local mypos = vector.round(self.object:get_pos())
	--	local mypos = self.object:get_pos()
		local adjdst = {
			x = mydest.x,
			y = mypos.y,
			z = mydest.z
		}

--		local thedist = vector.distance(mypos,adjdst)	
		local thedist = vector.distance(mypos,mydest)	
		--print("JUST GO ON THE PATH = ", thedist)

		if thedist > 0.6 then 

			if isrunning then
				self:change_direction(mydest,self.run_speed)
			else
				self:change_direction(mydest,self.walk_speed)
			end



			local tempmv = self.object:get_velocity()


			local tempv = {x = 0, y = tempmv.y, z = 0}
			if math.round(mypos.y) > mydest.y then
				tempv.y = -5
			elseif  math.round(mypos.y) < mydest.y then
				tempv.y = 6.5
			end
--
--			local checkv = {x = adjdst.x, y = mypos.y -0.5, z = adjdst.z}




--			local checkd = vector.distance(mypos,checkv)
--			local tempmv = self.object:get_velocity()
			self.object:set_velocity{x = tempmv.x, y = tempv.y, z = tempmv.z}

			-- TODO bit of a dirty fix for slabs screwing with y
--			if func.get_goto_distance_check(self.object:get_pos(),mydest) then
--				thedist = 0
--			end	
			return nil
		else
			return true
		end

--	self.object:set_velocity{x = 0, y = 0, z = 0}
--	self:set_animation(simple_working_villages.animation_frames.STAND)
--	return true

end













function simple_working_villages.villager:go_to_the(inpath)

--print(self.object:get_luaentity().nametag, " GOTOTHE:")

	if inpath == nil or inpath == false then
		-- TODO should indicate who cannot find a path
		print(self.object:get_luaentity().nametag, " No InPath location Found [go_to_the(inpath)]")
		return nil
	end




	local curr_step = 1
	self:set_animation(simple_working_villages.animation_frames.WALK)
	while inpath[curr_step] ~= nil do
		
		local mypos = self.object:get_pos()
		local mydest = inpath[curr_step]
--print("Going (", curr_step, ") to ", mydest)
		local thedist = vector.distance(mypos,mydest)

-- TODO check if i am already there needs be done on planning
		

		local timeoutcount = 100


		while thedist > 1 do
--print("JUST GOING TO THEDIST = ", thedist)

			self:handle_goto_obstacles(true)
			self:handle_doors()
			mypos = self.object:get_pos()
			local tempmv = self.object:get_velocity()
			timeoutcount = timeoutcount - 1
			if timeoutcount < 0 then 
--print(self.object:get_luaentity().nametag, " GOTO_TIMEOUT", inpath[curr_step])
				return false
			end
			local tempv = {x = 0, y = tempmv.y, z = 0}
			if math.round(mypos.y) > mydest.y then
				tempv.y = -6
			elseif  math.round(mypos.y) < mydest.y then
				tempv.y = 6.5
			end

			local checkv = {x = mydest.x, y = mypos.y -0.5, z = mydest.z}
			local checkd = vector.distance(mypos,checkv)
			self:change_direction(inpath[curr_step])
			local tempmv = self.object:get_velocity()
			self.object:set_velocity{x = tempmv.x, y = tempv.y, z = tempmv.z}

			-- TODO bit of a dirty fix for slabs screwing with y
			if func.get_goto_distance_check(self.object:get_pos(),inpath[curr_step]) then
				thedist = 0
			end	
--			end
			thedist = vector.distance(self.object:get_pos(),inpath[curr_step]) -- checkd
			coroutine.yield()

		end
		curr_step = curr_step + 1;
	end				

	self.object:set_velocity{x = 0, y = 0, z = 0}
	self:set_animation(simple_working_villages.animation_frames.STAND)
	return true

end











--TODO: add variable precision
function simple_working_villages.villager:go_to(pos, can_fall)

	local canfall = false
	if can_fall ~= nil then
		canfall = can_fall
	end

			--self:set_state_info("I'm working out a route.")
			--self:set_displayed_action("Working out a route")
			--self:set_animation(simple_working_villages.animation_frames.STAND)
			--self.object:set_velocity{x = 0, y = 0, z = 0}

	local my_pos = self.object:get_pos()
--	print("GO_TO FUNCTION MY_POS ", my_pos)
	--local my_pos_v = func.validate_pos(my_pos)
--	print("GO_TO FUNCTION MY_POS_V ", my_pos)

	if pos == nil then
		print(self.object:get_luaentity().nametag, " No GOTO Pos Found = ", pos )
		return nil
	end

	local to_pos = vector.new(pos.x,pos.y,pos.z)
--	print("GO_TO FUNCTION TO_POS ", to_pos)
	--local to_pos_v = func.validate_pos(to_pos)
--	print("GO_TO FUNCTION TO_POS_V ", pos)

	--print("DEBUG:SELF.OBJECT:", dump(self.object))
	--print("DEBUG:PATHFINDER:", dump(pathfinder))
	

	local path_data = nil

	path_data = pathfinder.plot_movement_to_pos(my_pos, to_pos, canfall)

	if path_data == nil then
		-- TODO should indicate who cannot find a path
		print(self.object:get_luaentity().nametag, " No Path Found to ", to_pos)
		return nil
	end




	-- TODO do i yeald here or do I return false and Yeald elsewhere
	if path_data == false then
		print(self.object:get_luaentity().nametag, " IT SEEMS PATHFINDER IS BUSY-- I WILL HAVE TO WAIT MY TURN")
		return false 
	end

	local curr_step = 1
	self:set_animation(simple_working_villages.animation_frames.WALK)
	while path_data[curr_step] ~= nil do
		
		local mypos = self.object:get_pos()
		local mydest = path_data[curr_step]
--print("Going (", curr_step, ") to ", mydest)
		local thedist = vector.distance(mypos,mydest)
		local timeoutcount = 200


		while thedist > 0.6 do
--print("JUST GOING TO THEDIST = ", thedist)

		self:handle_doors()							-- TODO ADD TO THE REST OF THE BOTS


			mypos = self.object:get_pos()
			local tempmv = self.object:get_velocity()
			timeoutcount = timeoutcount - 1
			if timeoutcount < 0 then 
print(self.object:get_luaentity().nametag, " GOTO_TIMEOUT", path_data[curr_step])
				return -1
			end

			local tempv = {x = 0, y = tempmv.y, z = 0}
		
			--if math.abs(mypos.x - mydest.x) < 0.1 and math.abs(mypos.z - mydest.z) < 0.1 and math.round(mypos.y) > mydest.y then
			
--print("myposY:",mypos.y, " mydestY:", mydest.y)			
			if math.round(mypos.y) > mydest.y then
--print(self.object:get_luaentity().nametag, " : WHILE I NEED TO GO DOWN NOW")
				tempv.y = -6
				--self:delay(2)
			--if math.abs(mypos.x - mydest.x) < 0.1 and math.abs(mypos.z - mydest.z) < 0.1 and math.round(mypos.y) < mydest.y then
			elseif  math.round(mypos.y) < mydest.y then

--print(self.object:get_luaentity().nametag, " : WHILE I NEED TO GO UP NOW")
				tempv.y = 6.5
				--self:delay(2)
			end


			local checkv = {x = mydest.x, y = mypos.y -0.5, z = mydest.z}
			local checkd = vector.distance(mypos,checkv)
--print("JUST GOING TO POINT : CHECKD = ", checkd)

--			if checkd < 1 then
--				print("JUST GOING UPDOWN")
--				self.object:set_velocity(tempv)
--			else

				self:change_direction(path_data[curr_step])

				

				local tempmv = self.object:get_velocity()
				self.object:set_velocity{x = tempmv.x, y = tempv.y, z = tempmv.z}

				-- TODO bit of a dirty fix for slabs screwing with y
				if func.get_goto_distance_check(self.object:get_pos(),path_data[curr_step]) then
					thedist = 0
				end	
--			end
			thedist = vector.distance(self.object:get_pos(),path_data[curr_step]) -- checkd
			coroutine.yield()
		
		end
		curr_step = curr_step + 1;
	end				

	self.object:set_velocity{x = 0, y = 0, z = 0}
	self:set_animation(simple_working_villages.animation_frames.STAND)
	return true



		
--	end	
--	self.destination=vector.round(pos)
--	if func.walkable_pos(self.destination) then
--		self.destination=pathfinder.get_ground_level(vector.round(self.destination))
--	end
--	local val_pos = func.validate_pos(self.object:get_pos())
--	self.path = pathfinder.find_path(val_pos, self.destination, self)
--	self:set_timer("go_to:find_path",0) -- find path interval
--	self:set_timer("go_to:change_dir",0)
--	self:set_timer("go_to:give_up",0)
--	if self.path == nil then
		
		--TODO: actually no path shouldn't be accepted
		--we'd have to check whether we can find a shorter path in the right direction
		--return false, fail.no_path
--		self.path = {self.destination}
--	end
--i	print("the first waypiont on his path:" .. minetest.pos_to_string(self.path[1]))
--	self:change_direction(self.path[1])
--	self:set_animation(simple_working_villages.animation_frames.WALK)

--	while #self.path ~= 0 do
--		self:count_timer("go_to:find_path")
--		self:count_timer("go_to:change_dir")
--		if self:timer_exceeded("go_to:find_path",100) then
--			val_pos = func.validate_pos(self.object:get_pos())
--			if func.walkable_pos(self.destination) then
--				self.destination=pathfinder.get_ground_level(vector.round(self.destination))
--			end
--			local path = pathfinder.find_path(val_pos,self.destination,self)
--			if path == nil then
--				self:count_timer("go_to:give_up")
--				if self:timer_exceeded("go_to:give_up",3) then
--					print("villager can't find path to "..minetest.pos_to_string(val_pos))
--					return false, fail.no_path
--				end
--			else
--				self.path = path
--			end
--		end
--
--		if self:timer_exceeded("go_to:change_dir",30) then
--			self:change_direction(self.path[1])
--		end
--
--		-- follow path
--		if self:is_near({x=self.path[1].x,y=self.object:get_pos().y,z=self.path[1].z}, 1) then
--			table.remove(self.path, 1)
--
--			if #self.path == 0 then -- end of path
--				 --keep walking another step for good measure
--rt				coroutine.yield()
--				break
--			else -- else next step, follow next path.
--				self:set_timer("go_to:find_path",0)
--				self:change_direction(self.path[1])
--			end
--		end
--		-- if vilager is stopped by obstacles, the villager must jump.
--		self:handle_obstacles(true)
--		-- end step
--		coroutine.yield()
--	end
--	-- stop
--	self.object:set_velocity{x = 0, y = 0, z = 0}
--	self.path = nil
--	self:set_animation(simple_working_villages.animation_frames.STAND)
--	return true
end






function simple_working_villages.villager:collect_nearest_item_by_condition(cond, searching_range)
	local item = self:get_nearest_item_by_condition(cond, searching_range)
	if item == nil then
		return false
	end
	local pos = item:get_pos()
	--print("collecting item at:".. minetest.pos_to_string(pos))
	local inv=self:get_inventory()
	if inv:room_for_item("main", ItemStack(item:get_luaentity().itemstring)) then

		--print("Sapling y = ", pos.y)
		
		--if pos.y < self.object:get_pos() + searching_range.y then

			local gotores = self:go_to(pos) ---------------------------------------------------------------------------------------------------------------------TODO
			while gotores == false do  
				--print("WAITINGFORPATHFINDER")
				coroutine.yield()
				gotores = self:go_to(pos)
			end
			if gotores == nil then print("NOPATHFOUND") end


		self:pickup_item()
		--end
	end
end

-- delay the async action by @step_count steps
function simple_working_villages.villager:delay(step_count)
	for _=0,step_count do
		coroutine.yield()
	end
end

local drop_range = {x = 2, y = 10, z = 2}

function simple_working_villages.villager:dig(pos,collect_drops)
	if func.is_protected(self, pos) then return false, fail.protected end
	self.object:set_velocity{x = 0, y = 0, z = 0}
	local dist = vector.subtract(pos, self.object:get_pos())
	if vector.length(dist) > 5 then
		self:set_animation(simple_working_villages.animation_frames.STAND)
		return false, fail.too_far
	end
	self:set_animation(simple_working_villages.animation_frames.MINE)
	self:set_yaw_by_direction(dist)
	for _=0,30 do coroutine.yield() end --wait 30 steps
	local destnode = minetest.get_node(pos)
	--if not minetest.dig_node(pos) then --somehow this drops the items
	-- return false, fail.dig_fail
	--end
	local def_node = minetest.registered_items[destnode.name];
	local old_meta = nil;
	if (def_node~=nil) and (def_node.after_dig_node~=nil) then
		old_meta = minetest.get_meta(pos):to_table();
	end
	minetest.remove_node(pos)
	local stacks = minetest.get_node_drops(destnode.name)
	for _, stack in ipairs(stacks) do
		local leftover = self:add_item_to_main(stack)
		if not leftover:is_empty() then
			minetest.add_item(pos, leftover)
		end
	end
	if (old_meta) then
		def_node.after_dig_node(pos, destnode, old_meta, nil)
	end
	for _, callback in ipairs(minetest.registered_on_dignodes) do
		local pos_copy = {x=pos.x, y=pos.y, z=pos.z}
		local node_copy = {name=destnode.name, param1=destnode.param1, param2=destnode.param2}
		callback(pos_copy, node_copy, nil)
	end
	local sounds = minetest.registered_nodes[destnode.name]
	if sounds then
		if sounds.sounds then
			local sound = sounds.sounds.dug
			if sound then
				minetest.sound_play(sound,{object=self.object, max_hear_distance = 10})
			end
		end
	end
	self:set_animation(simple_working_villages.animation_frames.STAND)
	if collect_drops then
		local mystacks = minetest.get_node_drops(destnode.name)
		--perhaps simplify by just checking if the found item is one of the drops
		for _, stack in ipairs(mystacks) do
			local function is_drop(n)
				local name
				if type(n) == "table" then
					name = n.name
				else
					name = n
				end
				if name == stack then
					return true
				end
				return false
			end
			self:collect_nearest_item_by_condition(is_drop,drop_range)
			-- add to inventory, when using remove_node
			--[[local leftover = self:add_item_to_main(stack)
			if not leftover:is_empty() then
				minetest.add_item(pos, leftover)
			end]]
		end
	end
	return true
end

function simple_working_villages.villager:place(item,pos)
--	print("Trying to place ",item, " at pos ", pos)
	if type(pos)~="table" then
		error("no target position given")
	end
	if func.is_protected(self,pos) then return false, fail.protected end
	local dist = vector.subtract(pos, self.object:get_pos())
	if vector.length(dist) > 5 then
		return false, fail.too_far
	end
	local destnode = minetest.get_node(pos)
	if not minetest.registered_nodes[destnode.name].buildable_to then
	 return false, fail.blocked
	end
	local find_item = function(name)
		if type(item)=="string" then
			return name == simple_working_villages.buildings.get_registered_nodename(item)
		elseif type(item)=="table" then
			return name == simple_working_villages.buildings.get_registered_nodename(item.name)
		elseif type(item)=="function" then
			return item(name)
		else
			log.error("got %s instead of an item",item)
			error("no item to place given")
		end
	end
--	print("wield_stack")
	local wield_stack = self:get_wield_item_stack()
--	print("move item to wield")
	if not (find_item(wield_stack:get_name()) or self:move_main_to_wield(find_item)) then
	 return false, fail.not_in_inventory
	end
--	print("set animation")
	if self.object:get_velocity().x==0 and self.object:get_velocity().z==0 then
		self:set_animation(simple_working_villages.animation_frames.MINE)
	else
		self:set_animation(simple_working_villages.animation_frames.WALK_MINE)
	end
--	print("turn to target")
	self:set_yaw_by_direction(dist)
	--wait 15 steps
	for _=0,15 do coroutine.yield() end
	--get wielded item
	local stack = self:get_wield_item_stack()
--	print("create pointed_thing facing upward")
	--TODO: support given pointed thing via function parameter
	local pointed_thing = {
		type = "node",
		above = pos,
		under = vector.add(pos, {x = 0, y = -1, z = 0}),
	}
	--TODO: try making a placer
	local itemname = stack:get_name()
--	print("place item")
	if type(item)=="table" then
--		print("Table Found")
		minetest.set_node(pointed_thing.above, item)
		--minetest.place_node(pos, item) --loses param2
		stack:take_item(1)
	else
--		print("No Table Found")
--		print("Get before node")
		local before_node = minetest.get_node(pos)
--		print("Get before count")
		local before_count = stack:get_count()
--		print("Get Definition")
		local itemdef = stack:get_definition()
		if itemdef.on_place then
--			print("On Place")
--			print("Itemdef:", dump(itemdef))
--			print("Pointed_Thing:", dump(pointed_thing))
--			print("Self:", dump(self))

			local daowner = core.get_player_by_name(self.owner_name)
			if daowner ~= nil then
				stack = itemdef.on_place(stack, daowner, pointed_thing)
			end
--			print("splaced?)")

--			stack = minetest.item_place_node(stack, self, pointed_thing)


		elseif itemdef.type=="node" then
			stack = minetest.item_place_node(stack, self, pointed_thing)
			
		end
--		print("After Place")
		local after_node = minetest.get_node(pos)
		-- if the node didn't change, then the callback failed
		if before_node.name == after_node.name then
			return false, fail.protected
		end
		-- if in creative mode, the callback may not reduce the stack
		if before_count == stack:get_count() then
			stack:take_item(1)
		end
	end
--	print("take item")
	self:set_wield_item_stack(stack)
	coroutine.yield()
--	print("handle sounds")
	local sounds = minetest.registered_nodes[itemname]
	if sounds then
		if sounds.sounds then
			local sound = sounds.sounds.place
			if sound then
				minetest.sound_play(sound,{object=self.object, max_hear_distance = 10})
			end
		end
	end
--	print("reset animation")
	if self.object:get_velocity().x==0 and self.object:get_velocity().z==0 then
		self:set_animation(simple_working_villages.animation_frames.STAND)
	else
		self:set_animation(simple_working_villages.animation_frames.WALK)
	end

	return true
end

function simple_working_villages.villager:manipulate_chest(chest_pos, take_func, put_func, data)
	if func.is_chest(chest_pos) then
		-- try to put items
		local vil_inv = self:get_inventory();

		-- from villager to chest
		if put_func then
			local size = vil_inv:get_size("main");
			for index = 1,size do
				local stack = vil_inv:get_stack("main", index);
				if (not stack:is_empty()) then

					if (put_func(self, stack, data)) then
--						print("PUT_FUNC OK")
						local chest_meta = minetest.get_meta(chest_pos);
						local chest_inv = chest_meta:get_inventory();
						local leftover = chest_inv:add_item("main", stack);

						if leftover:is_empty() then 
--						print("LEFTOVER IS EMPTY")
						else
--						print("LEFTOVER TO CHEST = ", dump(leftover))
						coroutine.yield(co_command.pause,"Seems I no room for produce in my chest")
						end
						
--						print("LEFTOVER TO CHEST = ", dump(leftover))

						vil_inv:set_stack("main", index, leftover);
						for _=0,10 do coroutine.yield() end --wait 10 steps
						
					else
--						print("PUT_FUNC NOT OK")
					end

				else
--					print("FARMER : STACK IS EMPTY")
				end
			end
		end
		-- from chest to villager
		if take_func then
			local chest_meta = minetest.get_meta(chest_pos);
			local chest_inv = chest_meta:get_inventory();
			local size = chest_inv:get_size("main");
			for index = 1,size do
				chest_meta = minetest.get_meta(chest_pos);
				chest_inv = chest_meta:get_inventory();
				local stack = chest_inv:get_stack("main", index);
				if (not stack:is_empty()) and (take_func(self, stack, data)) then
					local leftover = vil_inv:add_item("main", stack);
					chest_inv:set_stack("main", index, leftover);
					for _=0,10 do coroutine.yield() end --wait 10 steps
				end
			end
		end
	else
		if self.nametag ~= nil then
			log.error("%s could not find thier chest", self.nametag)
		else
			log.error("%s could not find thier chest", self.inventory_name)
		end
	end
end

function simple_working_villages.villager.wait_until_dawn()
	local daytime = minetest.get_timeofday()
	while (daytime < 0.2 or daytime > 0.805) do
		coroutine.yield()
		daytime = minetest.get_timeofday()
	end
end

function simple_working_villages.villager:sleep()

	--print("SLEEP DUMP:", dump(self))

	if self.nametag ~= nil then
		log.action("%s is laying down", self.nametag)
	else
		log.action("%s is laying down", self.inventory_name)
	end

	self.object:set_velocity{x = 0, y = 0, z = 0}
	local bed_pos = vector.new(self.pos_data.bed_pos)
	local bed_top = func.find_adjacent_pos(bed_pos,
		function(p) return string.find(minetest.get_node(p).name,"_top") end)
	local bed_bottom = func.find_adjacent_pos(bed_pos,
		function(p) return string.find(minetest.get_node(p).name,"_bottom") end)
	if bed_top and bed_bottom then
		self:set_yaw_by_direction(vector.subtract(bed_bottom, bed_top))
		bed_pos = vector.divide(vector.add(bed_top,bed_bottom),2)
	else
		if self.nametag ~= nil then
			log.info("%s found no bed",self.nametag)
		else
			log.info("%s found no bed",self.inventory_name)
		end
	end
	self:set_animation(simple_working_villages.animation_frames.LAY)
	self.object:set_pos(bed_pos)
	self:set_state_info("Zzzzzzz...")
	self:set_displayed_action("sleeping")
	self.wait_until_dawn()

	local pos=self.object:get_pos()
	self.object:set_pos({x=pos.x,y=pos.y+0.5,z=pos.z})
	if self.nametag ~= nil then
		log.action("%s gets up",self.nametag)
	else
		log.action("%s gets up",self.inventory_name)
	end
	self:set_animation(simple_working_villages.animation_frames.STAND)
	self:set_state_info("I'm starting into the new day.")
	self:set_displayed_action("active")
end

function simple_working_villages.villager:goto_bed()
	local pos=self.object:get_pos()



	if self.pos_data.home_pos==nil then
		if self.nametag ~= nil then
			log.info("%s don't know where Home is !",self.nametag)
		else
			log.info("%s don't know where Home is !",self.inventory_name)
		end
		log.action("villager %s is waiting until dawn", self.inventory_name)
		self:set_state_info("I'm waiting for dawn to come.")
		self:set_displayed_action("waiting until dawn")
		self:set_animation(simple_working_villages.animation_frames.SIT)
		self.object:set_velocity{x = 0, y = 0, z = 0}
		self.wait_until_dawn()
		self:set_animation(simple_working_villages.animation_frames.STAND)
		self:set_state_info("I'm starting into the new day.")
		self:set_displayed_action("active")
	else
		local h_pos = vector.new(self.pos_data.home_pos.x,self.pos_data.home_pos.y,self.pos_data.home_pos.z)
		--print("I am going Home to ", h_pos);
		if self.nametag ~= nil then
			log.info("%s is going home",self.nametag)
		else
			log.info("%s is going home",self.inventory_name)
		end
		self:set_state_info("I'm going home, it's late.")
		self:set_displayed_action("going home")


		local gotores = self:go_to(h_pos,true) ---------------------------------------------------------------------------------------------------------------------TODO
		while gotores == false do  
			print("WAITINGFORPATHFINDER TO GO TO HOME")
			coroutine.yield()
			gotores = self:go_to(pos)
		end
		if gotores == nil then print("NOPATHFOUND") end


		if gotores then ---------------------------------------------------------------------------------------------------------------------TODO
--			print("GOTO RETURNED HOME TRUE")
			if self.nametag ~= nil then
				log.info("%s going to bed",self.nametag)
			else
				log.info("%s going to bed",self.inventory_name)
			end
			self:set_state_info("I'm going to bed, it's late.")

			local bed_pos = self.pos_data.bed_pos
			local b_pos = vector.new(bed_pos.x,bed_pos.y,bed_pos.z)

			local my_pos=self.object:get_pos()
--			print("MY_POS = ", my_pos) 
			local my_dest = func.get_closest_clear_spot(my_pos,b_pos)
--			print("I think my bed is at ", my_dest)

			local gotores = self:go_to(my_dest) ---------------------------------------------------------------------------------------------------------------------TODO
			while gotores == false do  
				print("WAITINGFORPATHFINDER TO GO TO BED")
				coroutine.yield()
				gotores = self:go_to(my_dest)
			end

			if not gotores then ---------------------------------------------------------------------------------------------------------------------TODO
				if self.nametag ~= nil then
					log.info("%s Could not get to the BED",self.nametag)
				else
					log.info("%s Could not get to the BED",self.inventory_name)
				end
			end
			self:set_state_info("I am going to sleep soon.")
			self:set_displayed_action("waiting for dusk")
			local tod = minetest.get_timeofday()
			while (tod > 0.2 and tod < 0.805) do
				coroutine.yield()
				tod = minetest.get_timeofday()
			end
			self:sleep()

			local gotores = self:go_to(self.pos_data.home_pos) ---------------------------------------------------------------------------------------------------------------------TODO
			while gotores == false do  
				print("WAITINGFORPATHFINDER TO GOTO HOME POS")
				coroutine.yield()
				gotores = self:go_to(pos)
			end
			if gotores == nil then print("NOPATHFOUND") end
				--self:go_to(self.pos_data.home_pos) ---------------------------------------------------------------------------------------------------------------------TODO
		
		else
			print("GOTO RETURNED HOME FALSE")
		end

	end 
end










function simple_working_villages.villager:handle_night()
	local tod = minetest.get_timeofday()
	if	tod < 0.2 or tod > 0.76 then
		if (self.job_data.in_work == true) then
			self.job_data.in_work = false;
		end
		self:goto_bed()
		self.job_data.manipulated_chest = false;
	end
end

function simple_working_villages.villager:goto_job()
	if self.nametag ~= nil then
		log.action("%s is going to their job",self.nametag)
	else
		log.action("%s is going to their job",self.inventory_name)
	end
	if self.pos_data.job_pos==nil then
		if self.nametag ~= nil then
			log.info("%s couldn't find his job position",self.nametag)
		else
			log.info("%s couldn't find his job position",self.inventory_name)
		end
		self.job_data.in_work = true;
	else
		if self.nametag ~= nil then
			log.info("%s going to thier job position",self.nametag)
		else
			log.info("%s going to thier job position",self.inventory_name)
		end
		self:set_state_info("I am going to my job position.")
		self:set_displayed_action("going to job")
		print(self.nametag, " GOINGTOJOB:", vector.new(self.pos_data.job_pos.x,self.pos_data.job_pos.y,self.pos_data.job_pos.z))

		local gotores = self:go_to(vector.new(self.pos_data.job_pos.x,self.pos_data.job_pos.y,self.pos_data.job_pos.z))
		while gotores == false do  
			print(self.nametag, " WAITINGFORPATHFINDER GOTO MY JOB")
			coroutine.yield()  -- TODO should i return false here then yeald ???
			gotores = self:go_to(vector.new(self.pos_data.job_pos.x,self.pos_data.job_pos.y,self.pos_data.job_pos.z))
		end
		if gotores == nil then 
			print(self.nametag, " NOPATHFOUNDTOJOB ", vector.new(self.pos_data.job_pos.x,self.pos_data.job_pos.y,self.pos_data.job_pos.z))
			return false
		end

		self.job_data.in_work = true;
	end
	self:set_state_info("I'm working.")
	self:set_displayed_action("active")
	return true
end







function simple_working_villages.villager:handle_chest(take_func, put_func, data)
	local pos = self.object:get_pos()
	if (not self.job_data.manipulated_chest) then
		self.job_data.manipulated_chest = true;

		if (self.pos_data.chest_pos~=nil) then




			local c_pos = self.pos_data.chest_pos
			print("DUMP CHEST_POS ", dump(c_pos))

			


		
			local my_dest = func.get_closest_clear_spot(self.object:get_pos(),c_pos)
			print("DUMP MY_DEST ", dump(my_dest))
--			print("THE CLOSEST I CAN GET TO MY CHEST IS ", my_dest)

			if self.nametag ~= nil then
				log.info("%s is handling a chest", self.nametag)
			else
				log.info("%s is handling a chest", self.inventory_name)
			end
			self:set_state_info("I am taking and puting items from/to my chest.")
			self:set_displayed_action("active")

			local gotores = self:go_to(my_dest) ---------------------------------------------------------------------------------------------------------------------TODO
			while gotores == false do  
--				print(self.nametag, " WAITING FOR PATHFINDER TO FIND MY CHEST")
				coroutine.yield()
				gotores = self:go_to(pos)
			end
			if gotores == nil then 
				print(self.nametag, " NO PATH FOUND TO MY CHEST") 
			else
				--self:go_to(my_dest) ---------------------------------------------------------------------------------------------------------------------TODO
				self:manipulate_chest(c_pos, take_func, put_func, data);
			end
			return true
		end
	end
end

function simple_working_villages.villager:handle_job_pos()
	if (not self.job_data.in_work) then
		self:goto_job()
	end
end
















