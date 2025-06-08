local func = working_villages.require("jobs/util")
local co_command = working_villages.require("job_coroutines").commands
local use_vh1 = minetest.get_modpath("visual_harm_1ndicators")

local found_animal_target = nil
local is_searching = false
local search_distance = 20

local function put_func()
  return true;
end

local dobj = nil

working_villages.register_job("working_villages:job_vet", {
	description      = "vet (working_villages)",
	long_description = "I fix animals.\
I Love it.",
	inventory_image  = "default_paper.png^working_villages_vet.png",
	jobfunc = function(self)
		if use_vh1 then VH1.update_bar(self.object, self.health) end

		self:handle_night()
		self:handle_job_pos()
		self:handle_obstacles()
		self:buried_check() -- FIX FOR SELF BURIED ERROR -- jumps into the ground ?

		if found_animal_target ~= nil then 
			self:set_displayed_action("Going to the Animal")
			is_searching = false
			found_animal_target = dobj:get_pos()
			if found_animal_target ~= nil then
				local destination = func.get_closest_clear_spot(self.object:get_pos(),found_animal_target)	
				if destination == false or destination == nil then
					destination = found_animal_target
				end

				local distance = vector.distance(self.object:get_pos(), dobj:get_pos())
				if distance < 2 then
					-- TODO RT need to face target
					self:set_animation(working_villages.animation_frames.MINE)
					local tophp = dobj:get_hp()
					if dobj:get_luaentity() then
						local luae = dobj:get_luaentity()
						local currhp = luae.health
						if tophp ~= currhp then
							if luae ~= nil then 
								luae.health = currhp + 1
								self:delay(40)
							end
						else
							print("VET:I have healed the animal")
							found_animal_target = nil
							destination = nil
							dobj = nil
						end
					end
					self:set_animation(working_villages.animation_frames.STAND)
				else
					found_animal_target = dobj:get_pos()
					if found_animal_target ~= nil then
						destination = func.get_closest_clear_spot(self.object:get_pos(),found_animal_target)

						local gotores = self:go_to(destination)
						if gotores == false then
							print("VET:GOTORES = FALSE")
						elseif gotores == nil then
							print("VET:GOTORES = NIL")
						end
					end
				end
			else
				found_animal_target = dobj:get_pos()
				if found_animal_target ~= nil then
				local destination = func.get_closest_clear_spot(self.object:get_pos(),found_animal_target)
					local gotores = self:go_to(destination)
					if gotores == false then
						print("VET:GOTORES = FALSE")
					elseif gotores == nil then
						print("VET:GOTORES = NIL")
					end
				end
			end
		else
			self:set_displayed_action("Searching for a injured Animal")
			self:count_timer("vet:search")
			self:count_timer("vet:change_dir")
			--self:handle_obstacles()
			if self:timer_exceeded("vet:search",40) then
				dobj = self:get_nearest_wounded_animal(search_distance)
				if dobj ~= nil then
					found_animal_target = dobj:get_pos()
					print("VET:Found a wounded animal at ", found_animal_target)
				end
			end
			if found_animal_target == nil then 
				if is_searching then
					local my_vel = self.object:get_velocity()
					if my_vel.x == 0 and my_vel.z == 0 and my_vel.y == 0 then
						self:change_direction_randomly()
					end
					if self:timer_exceeded("vet:change_dir",500) then
						if is_searching then self:change_direction_randomly() end
					end
				else
					print("VET:Searching")
					is_searching = true
					self:change_direction_randomly()
				end
			end
		end
	end,
})
