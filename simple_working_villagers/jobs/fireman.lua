local func = simple_working_villages.require("jobs/util")
local function find_fire(p) return minetest.get_node(p).name == "fire:basic_flame" end
local function find_pfire(p) return minetest.get_node(p).name == "fire:permanant_flame" end
local searching_range = {x = 50, y = 20, z = 50}
local use_vh1 = minetest.get_modpath("visual_harm_1ndicators")


local found_fire_target = nil
local is_searching = false


simple_working_villages.register_job("simple_working_villages:job_fireman", {
	description      = "fireman (simple_working_villages)",
	long_description = "I fight fires.\
I must confess I love my job.\
Keeping everyone safe.",
	inventory_image  = "default_paper.png^memorandum_letters.png",
	jobfunc = function(self)
		if use_vh1 then VH1.update_bar(self.object, self.object:get_hp()) end

-- ONCE ONLY ON CREATE
		if self.job_data["isstarted"] == nil then
			self.job_data["isstarted"] = true		-- to make sure this only runs once
            self.pos_data["job_pos"] = self.object:get_pos() 
        end




		self:handle_night()
		self:handle_job_pos()
		self:handle_obstacles(false)
		self:buried_check()
		if found_fire_target ~= nil then 
			self:set_displayed_action("fighting a fire")
			local destination = func.get_closest_clear_spot(self.object:get_pos(),found_fire_target)	
			if destination == false or destination == nil then
				destination = found_fire_target
			end
			local gotores = self:go_to(destination)
			if gotores == false then
			elseif gotores == nil then
				found_fire_target = nil
				destination = nil
			else
				if self:dig(found_fire_target,true) then
					found_fire_target = nil
					destination = nil
				else
					found_fire_target = nil
					destination = nil
				end
			end
		else
			self:set_displayed_action("looking for fires")
			self:count_timer("fireman:search")
			if self:timer_exceeded("fireman:search",10) then
				found_fire_target = func.search_surrounding(self.object:get_pos(), find_fire, searching_range)
				if found_fire_target == nil then
					self:set_displayed_action("looking for fires") 
				end
			end
		end
	end,
})
























