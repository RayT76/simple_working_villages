local func = working_villages.require("jobs/util")
local function find_snow(p) return minetest.get_node(p).name == "default:snow" end
local searching_range = {x = 5, y = 3, z = 5}
local use_vh1 = minetest.get_modpath("visual_harm_1ndicators")

working_villages.register_job("working_villages:job_medic", {
	description      = "medic (working_villages)",
	long_description = "I fix people and NPC's.\
I love people.",
	inventory_image  = "default_paper.png^working_villages_medic.png",
	jobfunc = function(self)

		if use_vh1 then VH1.update_bar(self.object, self.health) end

		self:handle_night()
		self:handle_job_pos()

		self:count_timer("snowclearer:search")
		self:count_timer("snowclearer:change_dir")
		self:handle_obstacles()
		if self:timer_exceeded("snowclearer:search",50) then
			print("Looking for a wounded person")



  

			local dobj = self:get_nearest_wounded_npc(5)
			if dobj ~= nil then
				print("Found a wounded person")
				ani_pos = dobj:get_pos()
				local destination = func.find_adjacent_clear(ani_pos)

				if destination ~= false then
					print("Going to ", destination)
					self:go_to(destination)

					destination = func.find_adjacent_clear(dobj:get_pos())				
					local distance = vector.distance(self.object:get_pos(), destination)

					if distance < 2 then
						print("Got to the wounded NPC")
						self:set_animation(working_villages.animation_frames.MINE)
						local tophp = dobj:get_hp()

						if dobj:get_luaentity() then
							local luae = dobj:get_luaentity()
							local currhp = luae.health
							print(luae.name, " = ", currhp, "/", tophp)

							if tophp == currhp then
								print("ERR Why does the wounded NPC have full health?")
								print("DUMPDOBJ:", dump(dobj)) -- returns 12 for sheep which is their max
								print("DUMPLUAE:", dump(luae)) -- returns 12 for sheep which is their max
							else  
								if luae ~= nil then 
									luae.health = currhp + 1
									self:delay(40)
								else 
									print("ERR Medic LUAE = NIL") 
								end
							end
							
						end
						self:set_animation(working_villages.animation_frames.STAND)
					end
				else
					print("I cannot find the destination to goto")
				end
			end
			

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
			self:set_displayed_action("looking for work")
		elseif self:timer_exceeded("snowclearer:change_dir",400) then
			--if self:timer_exceeded("snowclearer:change_dir",200) then
			--self:count_timer("snowclearer:search")
			self:change_direction_randomly()
		end
	end,
})
