local func = simple_working_villages.require("jobs/util")
local function find_fire(p) return minetest.get_node(p).name == "default:snow" end
local searching_range = {x = 10, y = 3, z = 10}
local use_vh1 = minetest.get_modpath("visual_harm_1ndicators")

simple_working_villages.register_job("simple_working_villages:job_snowclearer", {
	description      = "snowclearer (simple_working_villages)",
	long_description = "I clear away snow you know.\
My job is for testing not for harvesting.\
I must confess this job seems useless.\
I'm doing anyway, clearing the snow away.",
	inventory_image  = "default_paper.png^memorandum_letters.png",
	jobfunc = function(self)
		if use_vh1 then VH1.update_bar(self.object, self.object:get_hp()) end
		self:handle_night()
		self:handle_job_pos()

		self:count_timer("snowclearer:search")
		self:count_timer("snowclearer:change_dir")
		self:handle_obstacles()
		if self:timer_exceeded("snowclearer:search",40) then
			local target = func.search_surrounding(self.object:get_pos(), find_fire, searching_range)
			if target ~= nil then



--				local destination = func.find_adjacent_clear(target)
--				if destination==false then
--					print("failure: no adjacent walkable found")
--					destination = target
--				end
				self:set_displayed_action("Clearing Snow")
				self:go_to(target)
				self:dig(target,true)
			end
			self:set_displayed_action("looking for Snow to clear")
		elseif self:timer_exceeded("snowclearer:change_dir",200) then
			self:count_timer("snowclearer:search")
			self:change_direction_randomly()
		end
	end,
})
