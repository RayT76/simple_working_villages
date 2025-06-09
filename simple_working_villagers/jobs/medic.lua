local func = working_villages.require("jobs/util")
local co_command = working_villages.require("job_coroutines").commands
local use_vh1 = minetest.get_modpath("visual_harm_1ndicators")

local found_npc_target = nil
local is_searching = false

local function put_func()
  return true;
end

local dobj = nil


working_villages.register_job("working_villages:job_medic", {
	description      = "medic (working_villages)",
	long_description = "I fix people? and NPC's.\
I love people.",
	inventory_image  = "default_paper.png^working_villages_medic.png",
	jobfunc = function(self)

		if use_vh1 then VH1.update_bar(self.object, self.object:get_hp()) end


-- ONCE ONLY ON CREATE
		if self.job_data["isstarted"] == nil then
			self.job_data["isstarted"] = true		-- to make sure this only runs once
            self.pos_data["job_pos"] = self.object:get_pos() 
        end





		self:handle_night()
		self:handle_job_pos()
		self:handle_obstacles()
		self:buried_check() -- FIX FOR SELF BURIED ERROR -- jumps into the ground ?

		if found_npc_target ~= nil then 
			self:set_displayed_action("Healing an NPC")
			is_searching = false
			found_npc_target = dobj:get_pos()
			if found_npc_target ~= nil then
				local destination = func.get_closest_clear_spot(self.object:get_pos(),found_npc_target)	
				if destination == false or destination == nil then
					destination = found_npc_target
				end

				local distance = vector.distance(self.object:get_pos(), dobj:get_pos())
				if distance < 2 then
					-- TODO RT need to face target
					self:set_animation(working_villages.animation_frames.MINE)

					local tophp = dobj:get_properties().hp_max
					local curhp = dobj:get_hp()

                    print("Top HP = ", tophp)
                    print("Cur HP = ", curhp)
                    print("DUMPDOBJ = ", dump(dobj))
					if dobj:get_luaentity() then
						local luae = dobj:get_luaentity()
						local props = dobj:get_properties()
                        local currhp = luae.health


				--if luae.health < props.hp_max 



						if tophp ~= curhp then
							--if luae ~= nil then 
                                dobj:set_hp(curhp + 1,{"Healed by medic"})
								--luae.health = currhp + 1
								self:delay(40)
							--end
						else
							print("MEDIC:I have healed the NPC")
							found_npc_target = nil
							destination = nil
							dobj = nil
						end
					end
					self:set_animation(working_villages.animation_frames.STAND)
				else
					found_npc_target = dobj:get_pos()
					if found_npc_target ~= nil then
						destination = func.get_closest_clear_spot(self.object:get_pos(),found_npc_target)

						local gotores = self:go_to(destination)
						if gotores == false then
							print("MEDIC:GOTORES = FALSE")
						elseif gotores == nil then
							print("MEDIC:GOTORES = NIL")
						end
					end
				end
			else
				found_npc_target = dobj:get_pos()
				if found_npc_target ~= nil then
				local destination = func.get_closest_clear_spot(self.object:get_pos(),found_npc_target)
					local gotores = self:go_to(destination)
					if gotores == false then
						print("MEDIC:GOTORES = FALSE")
					elseif gotores == nil then
						print("MEDIC:GOTORES = NIL")
					end
				end
			end

		else
			self:set_displayed_action("Searching for a injured NPC")
			self:count_timer("medic:search")
			self:count_timer("medic:change_dir")

			--if self:timer_exceeded("medic:search",40) then
			dobj = self:get_nearest_wounded_npc(50)
			if dobj ~= nil then
				found_npc_target = dobj:get_pos()
				print("MEDIC:Found a wounded NPC at ", found_npc_target)
			end
			--end
			if found_npc_target == nil then 
				if is_searching then 
					local my_vel = self.object:get_velocity()
					if my_vel.x == 0 and my_vel.z == 0 and my_vel.y == 0 then
						self:change_direction_randomly()
					end
					if self:timer_exceeded("medic:change_dir",500) then
						if is_searching then self:change_direction_randomly() end
					end
				else
					print("MEDIC:Searching")
					is_searching = true
					self:change_direction_randomly()
				end
			end
		end
	end,





















--		self:count_timer("medic:search")
--		self:count_timer("medic:change_dir")
--		self:handle_obstacles()
--		if self:timer_exceeded("medic:search",50) then
--			print("Looking for a wounded person")



  

--			local dobj = self:get_nearest_wounded_npc(50)
--			if dobj ~= nil then
--				print("Found a wounded person")
--				local ani_pos = dobj:get_pos()
--				--local destination = func.find_adjacent_clear(ani_pos)
--				local my_dest = func.get_closest_clear_spot(self.object:get_pos(),ani_pos)
				
--				if my_dest ~= false then
--					print("Going to ", my_dest)
--					self:go_to(my_dest)

					--destination = func.find_adjacent_clear(dobj:get_pos())				
--					local distance = vector.distance(self.object:get_pos(), ani_pos)

--					if distance < 2 then
--						print("Got to the wounded NPC")
--						self:set_animation(working_villages.animation_frames.MINE)
--						local tophp = dobj:get_hp()

--						if dobj:get_luaentity() then
--							local luae = dobj:get_luaentity()
--							local currhp = luae.health
--							print("MEDIC_HEALING:", luae.name, " = ", currhp, "/", tophp)
--
--							if tophp == currhp then
--								print("ERR Why does the wounded NPC have full health?")
--								print("DUMPDOBJ:", dump(dobj)) -- returns 12 for sheep which is their max
--								print("DUMPLUAE:", dump(luae)) -- returns 12 for sheep which is their max
--							else  
--								if luae ~= nil then 
--									luae.health = currhp + 1
--									self:delay(40)
--								else 
--									print("ERR Medic LUAE = NIL") 
--								end
--							end
							
--						end
--						self:set_animation(working_villages.animation_frames.STAND)
--					end
--				else
			--		print("Medic cannot find the destination to goto")
--				end
--			end
			

--			local target = func.search_surrounding(self.object:get_pos(), find_snow, searching_range)
--			if target ~= nil then
--				local destination = func.find_adjacent_clear(target)
--				if destination==false then
--					print("failure: no adjacent walkable found")
--					destination = target
--				end
--				self:set_displayed_action("clearing snow away")
--				self:go_to(destination)
--				self:dig(target,true)
--			end
--			self:set_displayed_action("looking for work")
--		elseif self:timer_exceeded("snowclearer:change_dir",400) then
--			--if self:timer_exceeded("snowclearer:change_dir",200) then
			--self:count_timer("snowclearer:search")
--			self:change_direction_randomly()
--		end
--	end,
})
