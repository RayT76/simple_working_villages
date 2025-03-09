local func = working_villages.require("jobs/util")
local function find_snow(p) return minetest.get_node(p).name == "default:snow" end
local searching_range = {x = 5, y = 3, z = 5}

working_villages.register_job("working_villages:vet", {
	description      = "vet (working_villages)",
	long_description = "I fix animals.\
I Love it.",
	inventory_image  = "default_paper.png^working_villages_vet.png",
	jobfunc = function(self)
		self:handle_night()
		self:handle_job_pos()

		self:count_timer("snowclearer:search")
		self:count_timer("snowclearer:change_dir")
		self:handle_obstacles()
		if self:timer_exceeded("snowclearer:search",100) then


  

			local dobj = self:get_nearest_wounded_animal(10)
			if dobj ~= nil then
				ani_pos = dobj:get_pos()
				local destination = func.find_adjacent_clear(ani_pos)
				self:go_to(destination)

				destination = func.find_adjacent_clear(dobj:get_pos())				
				local distance = vector.distance(self.object:get_pos(), destination)

				if distance < 2 then
					--print("Found a wounded animal")
					local tophp = dobj:get_hp()
					--print("get_tophp = ", tophp) -- returns 12 for sheep which is their max

					local currhp = dobj:get_luaentity().health
					--print("get_currhp = ", currhp) -- returns 12 for sheep which is their max

					if currhp ~= tophp then 
						dobj:get_luaentity().health = currhp + 1;
						self:delay(50)
					end
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
		elseif self:timer_exceeded("snowclearer:change_dir",200) then
--			if self:timer_exceeded("snowclearer:change_dir",200) then
			self:count_timer("snowclearer:search")
			self:change_direction_randomly()
		end
	end,
})
