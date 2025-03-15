local func = working_villages.require("jobs/util")
local function find_snow(p) return minetest.get_node(p).name == "fire:basic_flame" end
local searching_range = {x = 50, y = 20, z = 50}
local use_vh1 = minetest.get_modpath("visual_harm_1ndicators")

working_villages.register_job("working_villages:job_fireman", {
	description      = "fireman (working_villages)",
	long_description = "I fight fires.\
My job is for testing.\
I must confess I love my job.\
Keeping everyone safe.",
	inventory_image  = "default_paper.png^memorandum_letters.png",
	jobfunc = function(self)
		if use_vh1 then VH1.update_bar(self.object, self.health) end
		self:handle_night()
		self:handle_job_pos()

		self:count_timer("fireman:search")
		self:count_timer("fireman:change_dir")
		self:handle_obstacles()
		if self:timer_exceeded("fireman:search",20) then
			local target = func.search_surrounding(self.object:get_pos(), find_snow, searching_range)
			if target ~= nil then
--				local destination = func.find_adjacent_clear(target)
--				if destination==false then
--					print("failure: no adjacent walkable found")
--					destination = target
--				end
				self:set_displayed_action("fighting a fire")
				self:go_to(target)
				self:dig(target,true)
			end
			self:set_displayed_action("looking for fires")
		elseif self:timer_exceeded("fireman:change_dir",50) then
			self:count_timer("fireman:search")
			self:change_direction_randomly()
		end
	end,
})
