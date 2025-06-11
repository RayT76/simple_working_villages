local func = simple_working_villages.require("jobs/util")
local build = simple_working_villages.require("building")
local co_command = simple_working_villages.require("job_coroutines").commands
local use_vh1 = minetest.get_modpath("visual_harm_1ndicators")
local pathfinder = simple_working_villages.require("pathfinder")


-- set to check for a game load start
local medic_new_start = true
local medic_last_animation = "STAND"


local function get_size_joblist(self)
	-- returns the size of the job list
	local retsize = 1
--	print("MAYOR_A: GET JOBLIST SIZE")
	if self.job_data["joblist"] == nil then
		return 0
	else
		local jlist = self.job_data["joblist"]
		while jlist[retsize] ~= nil do	
			retsize = retsize +1
		end
		return retsize - 1
	end
end


local function add_to_joblist(self,in_job)
	-- adds a job to the job list
--	print("ADDING JOB")
	local lsize = get_size_joblist(self)
--	print("JOB SIZE = ", lsize)
	while lsize > 0 do
--		print("INCREMENTING JOB LIST")
		self.job_data["joblist"][lsize + 1] = self.job_data.joblist[lsize] 	
		lsize = lsize - 1
	end
--	print("SETTING JOB 1")
	self.job_data["joblist"][1] = in_job
	return get_size_joblist(self)
end

local function rem_from_joblist(self)
	-- removes the first job from the job list
	local retsize = 2
	while self.job_data.joblist[retsize] ~= nil do
		self.job_data.joblist[retsize - 1] = self.job_data.joblist[retsize] 	
		retsize = retsize +1
	end
	-- remove last job
	self.job_data.joblist[get_size_joblist(self)] = nil
	return get_size_joblist(self)
end
	
local function get_from_joblist(self,jobnum)
	return self.job_data.joblist[jobnum]
end

local function is_in_joblist(self,in_ja)
	local retsize = 1
	while self.job_data.joblist[retsize] ~= nil do
		if get_from_joblist(self,jobnum).name == in_ja then
			return retsize
		end
		retsize = retsize +1
	end
	return false
end

local function reset_joblist(self)

	self.job_data["joblist"] = {}			-- list to hold current job list
	local nothing_job = {
		name = "nothing",
		status = 0
		}
	add_to_joblist(self,nothing_job)

end



-- TODO OLD VARIABLES TO BE UPDATED / REPLACED OR DELETED

local medic_marker = nil



local medic_path_data = nil	-- the builders private path_data


local medic_searching_range = {x = 20, y = 5, z = 20}
local medic_searching_distance = 500
local medic_is_building = false



-- TODO MESSAGING MESSAGES TO BE UPDATED

local medic_callingmessage = 	{ 
			msg = "Calling Builder A",
			}
local medic_callingreply = 	{ 
			msg = "Builder A OK",
			}
local medic_jobreply = 	{ 
			msg = "Builder Finished",
			}
local medic_comemessage = 	{ 
			msg = "Come Here",
			pos = "",
			}
local medic_buildmessage = 	{ 
			msg = "Build This",
			pos = "",
			}
local medic_moveinmessage = 	{ 
			msg = "Movein Here",
			}


-- TODO NEW FUNCTIONS HERE


local function get_job_position(self)
	--return minetest.string_to_pos(self.pos_data.job_pos)
	if self.pos_data.job_pos == nil then --or self.pos_data.job_pos == '' then
		return nil
	else
		local newjp = vector.new(self.pos_data.job_pos.x,self.pos_data.job_pos.y,self.pos_data.job_pos.z)
--		print("JOBPOS = ", newjp)
		return newjp
	end
end

local function get_home_position(self)
	--return minetest.string_to_pos(self.pos_data.job_pos)
	if self.pos_data.home_pos == nil or self.pos_data.home_pos == '' then
		return nil
	else
		local newhp = vector.new(self.pos_data.home_pos.x,self.pos_data.home_pos.y,self.pos_data.home_pos.z)
--		print("JOBPOS = ", newjp)
		return newhp
	end
end

local function get_players_location(in_player_name)
	-- TODO could make this one var and one line ?
	local tobject = core.get_player_by_name(in_player_name)
	local tpos    = tobject:get_pos()
	return tpos
end

local function look_at_position(self,in_pos)
	local direction = vector.subtract(in_pos, self.object:get_pos())
	direction.y = 0
	self:set_yaw_by_direction(direction)
end

local function plan_to_next_to(mypos,mydest,self)
--	print("MYPOS=", mypos)
--	print("MYDEST=", mydest)
	local medic_myd = mydest
	medic_path_data = pathfinder.plot_movement_to_pos(mypos, medic_myd, false)
	if medic_path_data == nil then
		-- TODO should indicate who cannot find a path
		print(" No Path Found to ", medic_myd)
		self.job_data["pathdata"] = {}
		self.job_data["pathstep"] = -1
		return false
	elseif medic_path_data == false then
		print(" IT SEEMS PATHFINDER IS BUSY-- I WILL HAVE TO WAIT MY TURN")
		self.job_data["pathdata"] = {}
		self.job_data["pathstep"] = -1
		return nil 
	else
--		print("          PATHFINDER PLANNED OK")
--		print("          PATHDATA: ",  medic_path_data)
		self.job_data["pathdata"] = medic_path_data
		self.job_data["pathstep"] = 1
		return true
		
	end
end

local function go_on_path(self, isrunning)
	local pdata = self.job_data["pathdata"]
	local pdest = pdata[self.job_data["pathstep"]]
--	print("GOON PATH pstep=", self.job_data["pathstep"], " pdest=", pdest)
	if pdest ~= nil then 
		-- carry on the path
		if self:go_on_the_path(pdest,isrunning) == true then
			-- got there
			self.job_data["pathstep"] = self.job_data["pathstep"] + 1
			return nil
		else
			return nil
		end
	else
--		print("End of the path")
		return true
	end
end



local function get_close_objects(self,distance)
	local mypos = self.object:get_pos()
	local all_objects = minetest.get_objects_inside_radius(mypos, distance)
	return all_objects
end

local function plot_around(self,loc)

	local mloc = self.object:get_pos()
	print("PLOTTING AROUND ", loc, " FROM ", mloc)	
	
	local varx = math.round(loc.x - mloc.x)
	local varz = math.round(loc.z - mloc.z)
	print("X = ", varx, " Z = ", varz)	
	local nloc = {}

	if varx == 1 and varz == 1 then 
		nloc = vector.new{ x = mloc.x, y = mloc.y, z = mloc.z + 2 }
	elseif varx == 1 and varz == 0 then 
		nloc = vector.new{ x = mloc.x+2, y = mloc.y, z = mloc.z + 2 }
	elseif varx == 1 and varz == -1 then 
		nloc = vector.new{ x = mloc.x +2, y = mloc.y, z = mloc.z}
	elseif varx == 0 and varz == 1 then 
		nloc = vector.new{ x = mloc.x + 2, y = mloc.y, z = mloc.z+2 }
	elseif varx == 0 and varz == -1 then 
		nloc = vector.new{ x = mloc.x + 2, y = mloc.y, z = mloc.z-2 }
	elseif varx == -1 and varz == 1 then 
		nloc = vector.new{ x = mloc.x, y = mloc.y, z = mloc.z + 2 }
	elseif varx == -1 and varz == 0 then 
		nloc = vector.new{ x = mloc.x-2, y = mloc.y, z = mloc.z - 2 }
	elseif varx == -1 and varz == -1 then 
		nloc = vector.new{ x = mloc.x - 2, y = mloc.y, z = mloc.z }
	else
	print("ERROR PLOTTING AROUND ", loc, " FROM ", mloc)	
	end

	local goto_job = {
		["name"] = "gotohere",
		["dest"] = nloc,
		["status"] = 0
	}
	add_to_joblist(self,goto_job)

end



local function check_for_blocking_luaentitys(self)

	local object = nil
	local all_objs = get_close_objects(self,5)
	
	local mpos = vector.round(self.object:get_pos())
	local fpos = vector.round(self:get_front())

--	print("checking for blocking entitys at ", fpos, " and ", mpos)

	for _, object in pairs(all_objs) do
		if object:get_luaentity() then
			local opos = vector.round(object:get_pos())

			if fpos.x == opos.x and fpos.z == opos.z then 

				local luae = object:get_luaentity()
				local ent = func.get_entity(luae.name)
				if ent ~= nil then 
					if ent.block ~= nil then 
						print("THERE IS A ", luae.name, " IN THE WAY")
						return opos
					end
				end
			end
		end
	end
	return nil
end


local function auto_go(self, isrunning)
--print("DUMPJ:", dump(self.job_data["joblist"]))

	local current_job = get_from_joblist(self,1)
--	print("DUMP AUTOGO JOB ", dump(current_job))
	local mypos = self.object:get_pos()
	local mydest = current_job["dest"]
	local mystatus = current_job["status"]
	if mystatus == 0 then
--		print("AUTOGO STARTED LOOKING FOR PATH")
		if current_job.dest == nil then
			print("FARMER: AUTOGO NO DESTINATION ", mydest)
			rem_from_joblist(self)
			return false
		end
--		local adjdst = {
--			x = mydest.x,
--			y = mypos.y,
--			z = mydest.z
--		}
		--local tdist = vector.distance(mypos,adjdst)	
		local tdist = vector.distance(mypos,mydest)	
		if tdist < 1 then 
			rem_from_joblist(self)
--			print("ALREADY THERE")
			return true
		end
		-- TODO needs 3 types of goto function
		-- 1 = go to exact square
		-- 2 = go to square next to
		-- 3 = go to clostest you can within reason
		local pathres = plan_to_next_to(mypos,mydest,self)
		if pathres == true then
--			print("PATH FOUND GOING ON ROUTE")
--	print("DUMP_PATHDATA:", dump(self.job_data["pathdata"]))
			self:set_animation(simple_working_villages.animation_frames.WALK)
			current_job["status"] = 1
			current_job["currloc"] = vector.round(mypos)
			current_job["count"] = 0
			rem_from_joblist(self)
			add_to_joblist(self,current_job)
			self:set_animation(simple_working_villages.animation_frames.WALK)
			return nil
		elseif pathres == false then
			print("NO PATH FOUND")
			rem_from_joblist(self)
			return false
		elseif pathres == nil then
			print("PATHFINDER BUSY ? wait for it")
			return nil
		end



	elseif mystatus == 1 then
--		print("AUTOGO GOING")
		self:handle_goto_obstacles(true)
		local cani = self:get_animation()
		if cani ~= nil and cani ~= "WALK" then
			self:set_animation(simple_working_villages.animation_frames.WALK)
		end

		if current_job["currloc"] == nil then
--			print("CURRLOC == NIL ?")
		 	current_job["currloc"] = vector.round(mypos)
		 	current_job["count"] = 0
			rem_from_joblist(self)
			add_to_joblist(self,current_job)
		else

			--print("CURRCOUNT : ", current_job["count"])
			if current_job["currloc"] == vector.round(mypos) then
				current_job["count"] = current_job["count"] + 1
				rem_from_joblist(self)
				add_to_joblist(self,current_job)
			else
				current_job["currloc"] = vector.round(mypos)
			 	current_job["count"] = 0
			end
			if current_job["count"] > 200 then
--				print("TIMEOUT ON MOVECOUNT") 
			 	current_job["status"] = 0
			 	current_job["currloc"] = vector.round(mypos)
			 	current_job["count"] = 0
				rem_from_joblist(self)
				add_to_joblist(self,current_job)
				return nil
			end
		end
		local varb = check_for_blocking_luaentitys(self)
		if varb ~= nil then
			current_job["status"] = 0
			rem_from_joblist(self)
			add_to_joblist(self,current_job)
--			print("AUTOGO PLOTTING AROUND")
			plot_around(self,varb)
		end


--		FIXME TODO set to always run
--		local goonres = go_on_path(self,isrunning)
		local goonres = go_on_path(self,true)
		if goonres == true then
--			print("AUTOGO GOT TO DESTINATION")
			local tdist = vector.distance(mypos,mydest)
			self.object:set_velocity{x = 0, y = 0, z = 0}
			self:set_animation(simple_working_villages.animation_frames.STAND)
			rem_from_joblist(self)
			return true
		elseif goonres == false then
			print("NO NO PATH FOUND")
			rem_from_joblist(self)
			return false
		elseif goonres == nil then
--			print("AUTOGO GOONRES = nil")
			return nil
		end
	end
end	



















local function check_my_name(self)
	-- need to check my name
	print("Checking my NAME")
	local current_job = get_from_joblist(self,1)	
	if self.nametag == nil or self.nametag == '' then
		-- no name found
		self:set_animation(simple_working_villages.animation_frames.MINE)
		local notify_job = {
			["name"] = "notify",
			["status"] = 0,
			["message"] = " in need of a new name !!\nI don't like being called Oi.\nI like Mike if you fancy calling me that?\n"
		}
		add_to_joblist(self,notify_job)
	else
		-- found a name tag
		rem_from_joblist(self)
		print("I am called ", self.nametag)		
--		self:set_animation(simple_working_villages.animation_frames.STAND)
	end
end



local function medic_plantonextto(mypos,mydest)
	local medic_myd = func.get_closest_clear_spot(mypos,mydest)	
	if medic_myd == false or medic_myd == nil then
		medic_myd = mydest
	end
	medic_path_data = pathfinder.plot_movement_to_pos(mypos, medic_myd, false)
	if medic_path_data == nil then
		-- TODO should indicate who cannot find a path
		return nil
	elseif medic_path_data == false then
		return false 
	else
		return true
	end
end




local function go_to_here(spos,epos,self)
	local ma_tries = 5	
	while ma_tries > 0 do
		local curr_loc = self.object:get_pos()
		local thedist = vector.distance(curr_loc,epos)
		if thedist > 2 then
			medic_plantonextto(curr_loc,epos)
			self:go_to_the(medic_path_data)
		else
			return true
		end
		ma_tries = ma_tries - 1
		thedist = vector.distance(spos,epos)
	end
	return false
end



local function goto_myhome(self)
		rem_from_joblist(self)
		local hpos = get_home_position(self)

		local wait_job = {
			["name"] = "waitfor",
			["status"] = 100
		}
		add_to_joblist(self,wait_job)



		local goto_job = {
			["name"] = "gotohere",
			["dest"] = hpos,
			["status"] = 0
		}
		add_to_joblist(self,goto_job)
end


local function wait_for_time(self)
	local current_job = get_from_joblist(self,1)
	rem_from_joblist(self)
	if current_job["status"] > 0 then
		current_job.status = current_job.status - 1
		add_to_joblist(self,current_job)
	else
	end
end




local function look_for_tree(self)
	local current_job = get_from_joblist(self,1)
	rem_from_joblist(self)
	print("Look for a tree")


end

local function walk_north(self)
	local current_job = get_from_joblist(self,1)
	rem_from_joblist(self)
	print("I am going to Walk North for ", current_job.status, " blocks")

	local jdest = {x = 0, y = 0, z = current_job.status}
	local ndest = vector.add(get_job_position(self),jdest)
	
	local notify_job = {
		["name"] = "notify",
		["status"] = 0,
		["message"] = " has walked north for a while\n"
	}
	add_to_joblist(self,notify_job)

	local goto_job = {
		["name"] = "gotohere",
		["dest"] = ndest,
		["status"] = 0
	}
	add_to_joblist(self,goto_job)



end





local function check_build_site(self)

	-- TODO now its just take a walk around the perimiter and pretend all is good
	-- TODO later it should be to actually check the perimeter and enclosed area.. then either 
		-- if trees found = call FARMER to remove trees in area
		-- if high land found = call Groundsman to level land in area
		-- if a hole is found = call Miner to fill mine in area
		-- BUT more important issues a foot

	print("CHECKING BUILD SITE")
	local current_job = get_from_joblist(self,1)
	rem_from_joblist(self)
	print("DUMP JOB ", dump(current_job))

	local jpos = get_job_position(self)
	print("JOB POS ", jpos)
	local xpos = current_job["x"]
	local zpos = current_job["z"]

	local bpos = current_job["buildpos"]--vector.add(current_job["buildpos"],jpos)
	print("BUILD POS = ", bpos)

	local goto_jobe = {
		["name"] = "gotohere",
		["dest"] = bpos,
		["status"] = 0
	}
	add_to_joblist(self,goto_jobe)

	local posa = vector.new(bpos.x, bpos.y, bpos.z + zpos)
	local goto_joba = {
		["name"] = "gotohere",
		["dest"] = posa,
		["status"] = 0
	}
	add_to_joblist(self,goto_joba)

	local posb = vector.new(bpos.x + xpos, bpos.y, bpos.z + zpos)
	local goto_jobb = {
		["name"] = "gotohere",
		["dest"] = posb,
		["status"] = 0
	}
	add_to_joblist(self,goto_jobb)

	local posc = vector.new(bpos.x + xpos, bpos.y, bpos.z)
	local goto_jobc = {
		["name"] = "gotohere",
		["dest"] = posc,
		["status"] = 0
	}
	add_to_joblist(self,goto_jobc)


	local goto_jobd = {
		["name"] = "gotohere",
		["dest"] = bpos,
		["status"] = 0
	}
	add_to_joblist(self,goto_jobd)

end 




local function check_medic_message(self)

	--print("builder checking messages")
	local themessage = nil
	if func.get_medic_a_message() ~= nil then 
		-- there is a message
		themessage = func.get_medic_a_message()

		if themessage.msg == medic_callingmessage.msg then
			-- I must answer the phone
			print("medic IS ANSWERING THE PHONE")
			func.set_medic_a_message(medic_callingreply)
		end



		if themessage.msg == medic_comemessage.msg then
			-- I must answer the phone
			print("medic IS BEING CALLED OVER")
			medic_commanddestination = themessage.pos	
			func.st_medic_a_message(medic_callingreply)
		local goto_job = {
			["name"] = "gotohere",
			["dest"] = themessage.pos,
			["status"] = 0
		}
		add_to_joblist(self,goto_job)
		end






		if themessage.msg == medic_buildmessage.msg then
			print("medic IS BEING TOLD TO FARM")
				local plantorchard_job = themessage
				plantorchard_job["name"] = "buildthis"
				add_to_joblist(self,plantorchard_job)
			func.get_medic_a_message(medic_callingreply)
		end


			medic_marker = themessage.pos	

			--add_to_joblist(self,b_job)
--			local build_job = {
--				["name"] = "buildthis",
--				--["buildpos"] = themessage.pos,
--				["status"] = 0
--			}
--			add_to_joblist(self,build_job)
--		end








		if themessage.msg == medic_moveinmessage.msg then
			print("medic: IS BEING TOLD TO MOVEIN")
			if self.pos_data.chest_pos ~= vector.new(themessage.chest_pos) then
			--self.pos_data.food_pos = vector.new(themessage.food_pos) or nil
			--self.pos_data.storage_pos = vector.new(themessage.storage_pos) or nil
			--self.pos_data.job_pos = vector.new(themessage.job_pos) or nil
			--self.pos_data.tools_pos = vector.new(themessage.tools_pos) or nil
			self.pos_data.chest_pos  =  vector.new(themessage.chest_pos) or nil
			self.pos_data.bed_pos  = vector.new(themessage.bed_pos) or nil
			self.pos_data.home_pos = vector.new(themessage.home_pos) or nil

			print("Medic: Chest POS = ", self.pos_data.chest_pos)
			print("Medic: Bed POS = ", self.pos_data.bed_pos)
			print("Medic: Home POS = ", self.pos_data.home_pos)
			--print("medic:DUMP POSDATA", dump(self.pos_data))

			self.job_data.manipulated_chest = false;
			self:handle_chest(nil, nil)				

			
			--self:delay(100)
			end

			func.set_medic_a_message(medic_callingreply)

			local goto_home = {
				["name"] = "gotohome",
				["status"] = 0
			}
			add_to_joblist(self,goto_home)
		end

	else
		return false
	end
	return true

end








local function notify_me(self)

	local current_job = get_from_joblist(self,1)

	if current_job.status == 0 then		
		-- no jobpos found

		-- TODO go to home location and stand there waiting for user

		rem_from_joblist(self)
		current_job.status = 1
		add_to_joblist(self,current_job)
		self:set_animation(simple_working_villages.animation_frames.MINE)
	elseif current_job.status == 1 then		
		-- I want a JOBPOS from the boss
		look_at_position(self,get_players_location(self.owner_name))
		if vector.distance(self.object:get_pos(),get_players_location(self.owner_name)) < 3 then
			coroutine.yield(co_command.pause,current_job.message)
			rem_from_joblist(self)
		end
	end
end

local function move_in_1(self)
	local current_job = get_from_joblist(self,1)
	rem_from_joblist(self)

	print("MAYORA: I AM MOVING IN")
	
	local jpos = get_job_position(self)
	local cposa = vector.add(jpos,current_job.chestaloc)
	local bposa = vector.add(jpos,current_job.bedaloc)
	local hposa = vector.add(jpos,current_job.homealoc)

	local data = { } 
	self.pos_data.bed_pos = bposa
	self.pos_data.food_pos = vector.round(cposa) or nil
	self.pos_data.storage_pos = vector.round(cposa) or nil
	self.pos_data.job_pos = vector.round(self.pos_data.job_pos) or nil
	self.pos_data.tools_pos = vector.round(cposa) or nil
	self.pos_data.chest_pos  = vector.round(cposa) or nil
	self.pos_data.home_pos = vector.round(hposa) or nil
	--self.pos_data = data

	print("MAYORA: MOVING THE BUILDER IN")	
					
	--print("MAYORA: BEDA POS = ", bpos)
	--print("MAYORA: CHESTA POS = ", cpos)
	--print("MAYORA: HOMEA POS = ", hpos)
	local fpos = vector.add(jpos,current_job.fireloc)
	local bposb = vector.add(jpos,current_job.bedbloc)
	local cposb = vector.add(jpos,current_job.chestbloc)
	local hposb = vector.add(jpos,current_job.homebloc)
	--print("MAYORA: BEDB POS = ", bpos)
	--print("MAYORA: CHESTB POS = ", cpos)
	--print("MAYORA: HOMEB POS = ", hpos)

	medic_moveinmessage.bed_pos = bposb
	medic_moveinmessage.food_pos = cposb
	medic_moveinmessage.storage_pos = cposb
	medic_moveinmessage.job_pos = fpos
	medic_moveinmessage.tools_pos = cposb
	medic_moveinmessage.chest_pos = cposb
	medic_moveinmessage.home_pos = hposb
	--print("MAYORA: DUMP MESSAGE = ", dump(medic_moveinmessage))
	func.set_builder_a_message(medic_moveinmessage)

	local waitfor_joba = {
		["name"] = "waitfor",
		["status"] = 100
	}
	add_to_joblist(self,waitfor_job)

	local goto_joba = {
		["name"] = "gotohere",
		["dest"] = cposa,
		["status"] = 0
	}
	add_to_joblist(self,goto_joba)

	local waitfor_jobb = {
		["name"] = "waitfor",
		["status"] = 100
	}
	add_to_joblist(self,waitfor_job)

	local goto_jobb = {
		["name"] = "gotohere",
		["dest"] = bposa,
		["status"] = 0
	}
	add_to_joblist(self,goto_jobb)

	local waitforbuildok_job = {
		["name"] = "waitforbuildok",
		["status"] = 500
	}
	add_to_joblist(self,waitforbuildok_job)

end


local function find_building(p)
	if minetest.get_node(p).name ~= "simple_working_villages:building_marker" then
		return false
	end
	local medic_meta = minetest.get_meta(p)
	if medic_meta:get_string("state") ~= "begun" then
		return false
	end
	local medic_build_pos = simple_working_villages.buildings.get_build_pos(medic_meta)
	if medic_build_pos == nil then
		return false
	end
	if simple_working_villages.buildings.get(medic_build_pos)==nil then
		return false
	end
	return true
end


local function been_punched(self)

print("This is where I handle the ON PUNCH EVENT !!")

--self:have_i_been_attacked()





end



local function check_build_item(self,initem)



		--		print("CheckBuildItem=", initem)
				-- TODO TRY BEDTOP REPLACEMENT
				if initem:find("beds:bed_top") then
		--			print("I Need a Bed Top")
					local medic_inv = self:get_inventory()
					if medic_inv:room_for_item("main", ItemStack(initem)) then
		--				print("adding a bed top")
						medic_inv:add_item("main", ItemStack(initem))
					else
						local msg = "medic at " .. minetest.pos_to_string(self.object:get_pos()) ..
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


				-- TODO TRY BEDBOT REPLACEMENT
--				if initem:find("beds:bed_bottom") then
--					local medic_inv = self:get_inventory()
--					if medic_inv:room_for_item("main", ItemStack(initem)) then
--						medic_inv:add_item("main", ItemStack(initem))
--						--medic_inv:add_item("main", ItemStack(initem))"beds:bed_top"
--					else
--						local msg = "medic at " .. minetest.pos_to_string(self.object:get_pos()) ..
--							" doesn't have enough inventory space"
--						if self.owner_name then
--							minetest.chat_send_player(self.owner_name,msg)
--						else
--							print(msg)
--						end
--						-- should later be intelligent enough to use his own or any other chest
--						self:set_state_info("I am currently waiting to get some space in my inventory.")
--						return co_command.pause, "waiting for inventory space"
--					end
--				end



				-- TODO TRY OPENBOOK REPLACEMENT
				if (initem=="homedecor:book_open_blue") or (initem=="homedecor:book_open_red") or (initem=="homedecor:book_open_grey") or (initem=="homedecor:book_open_green") or (initem=="homedecor:book_open_violet") then
					if self:has_item_in_main(function (name) return name == "homedecor:book_red" end) then
						local inv = self:get_inventory()
					  	if inv:room_for_item("main", ItemStack(initem)) then
							self:replace_item_from_main(ItemStack("homedecor:book_red"),ItemStack(initem))
						else
							local msg = "medic at " .. minetest.pos_to_string(self.object:get_pos()) ..
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
				if (initem=="doors:door_wood_a") or (initem=="doors:door_wood_b") or (initem=="doors:door_wood_c") or (initem=="doors:door_wood_d") then
					if self:has_item_in_main(function (name) return name == "doors:door_wood" end) then
						local inv = self:get_inventory()
					  	if inv:room_for_item("main", ItemStack(initem)) then
							self:replace_item_from_main(ItemStack("doors:door_wood"),ItemStack(initem))
						else
							local msg = "medic at " .. minetest.pos_to_string(self.object:get_pos()) ..
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


				if initem=="default:torch_wall" then
					if self:has_item_in_main(function (name) return name == "default:torch" end) then
						local inv = self:get_inventory()
					  	if inv:room_for_item("main", ItemStack(initem)) then
							self:replace_item_from_main(ItemStack("default:torch"),ItemStack(initem))
						else
							local msg = "medic at " .. minetest.pos_to_string(self.object:get_pos()) ..
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


				if initem=="default:glass" then
					
					medic_nnode.param1 = 0
					
				end


end




-- limited support to two replant definitions
local farming_plants = {
	names = {
		["farming:artichoke_5"]={replant={"farming:artichoke"}},
		["farming:asparagus_5"]={replant={"farming:asparagus"}},
		["farming:barley_8"]={replant={"farming:seed_barley"}},
		["farming:beanpole_5"]={replant={"farming:beanpole","farming:beans"}},  -- untested
		["farming:beetroot_5"]={replant={"farming:beetroot"}},
		["farming:blackberry_4"]={replant={"farming:blackberry"}},
		["farming:blueberry_4"]={replant={"farming:blueberries"}},
		["farming:cabbage_6"]={replant={"farming:cabbage"}},
		["farming:carrot_8"]={replant={"farming:carrot"}},
		["farming:chili_8"]={replant={"farming:chili_pepper"}},
		["farming:cocoa_4"]={replant={"farming:cocoa_beans"}},
		["farming:coffee_5"]={replant={"farming:coffee_beans"}},
		["farming:corn_8"]={replant={"farming:corn"}},
		["farming:cotton_8"]={replant={"farming:seed_cotton"}},
		["farming:cucumber_4"]={replant={"farming:cucumber"}},
		["farming:eggplant_4"]={replant={"farming:eggplant"}},
		["farming:garlic_5"]={replant={"farming:garlic_clove"}},
		["farming:ginger_4"]={replant={"farming:ginger"}},
		["farming:grapes_8"]={replant={"farming:trellis","farming:grapes"}},  -- untested
		["farming:hemp_8"]={replant={"farming:seed_hemp"}}, -- cannot seen to replant
		["farming:lettuce_5"]={replant={"farming:lettuce"}},
		["farming:melon_8"]={replant={"farming:melon_slice"}}, -- cannot seen to replant
		["farming:mint_4"]={replant={"farming:seed_mint"}},
		["farming:oat_8"]={replant={"farming:seed_oat"}},
		["farming:onion_5"]={replant={"farming:onion"}},
		["farming:parsley_3"]={replant={"farming:parsley"}},
		["farming:pea_5"]={replant={"farming:pea_pod"}},
		["farming:pepper_7"]={replant={"farming:peppercorn"}}, -- cannot seen to replant
		["farming:pineapple_8"]={replant={"farming:pineapple_top"}},
		["farming:potato_4"]={replant={"farming:potato"}},
		["farming:pumpkin_8"]={replant={"farming:pumpkin_slice"}}, -- cannot seen to replant
		["farming:raspberry_4"]={replant={"farming:raspberries"}},
		["farming:rhubarb_4"]={replant={"farming:rhubarb"}},
		["farming:rice_8"]={replant={"farming:seed_rice"}},
		["farming:rye_8"]={replant={"farming:seed_rye"}},
		["farming:soy_7"]={replant={"farming:soy_pod"}},
		["farming:spinach_4"]={replant={"farming:spinach"}},
		["farming:sunflower_8"]={replant={"farming:seed_sunflower"}}, -- cannot seen to replant
		["farming:tomato_8"]={replant={"farming:tomato"}},
		["farming:vanilla_8"]={replant={"farming:vanilla"}},
		["farming:wheat_8"]={replant={"farming:seed_wheat"}},

		["ethereal:strawberry_8"]={replant={"ethereal:strawberry"}},

	},
}

local farming_demands = {
	["farming:beanpole"] = 99,
	["farming:trellis"] = 99,
}

function farming_plants.get_plant(item_name)
	-- check more priority definitions
	for key, value in pairs(farming_plants.names) do
		if item_name==key then
			return value
		end
	end
	return nil
end

function farming_plants.is_plant(item_name)
	local data = farming_plants.get_plant(item_name);
	if (not data) then
		return false;
	end
	return true;
end

local function find_plant_node(pos)
	local node = minetest.get_node(pos);
-- TODO rt : may have to rethink this.. some do not follow theaw
-- check here for wild or cultivated
	if (node.param2 == 0) then 
		return false;
	end;


	local data = farming_plants.get_plant(node.name);
	if (not data) then
		return false;
	end
	return true;
end



local cutter = {
  -- more priority definitions
	names = {
-- TODO pick up seeds for wheat oats barley
		["farming:weed"]={},
		["default:grass"]={},
		["default:grass_1"]={},
		["default:grass_2"]={},
		["default:grass_3"]={},
		["default:grass_4"]={},
		["default:grass_5"]={},
		["default:marram_grass_1"]={},
		["default:marram_grass_2"]={},
		["default:marram_grass_3"]={},
		["default:marram_grass_4"]={},
		["default:marram_grass_5"]={},
		["default:dry_shrub"]={},
	},
  -- less priority definitions
	groups = {

	},
}

function cutter.get_grass(item_name)
  -- check more priority definitions
	for key, value in pairs(cutter.names) do
		if item_name==key then
			return value
		end
	end
  -- check less priority definitions
	for key, value in pairs(cutter.groups) do
		if minetest.get_item_group(item_name, key) > 0 then
			return value;
		end
	end
	return nil
end

function cutter.is_grass(item_name)
  local data = cutter.get_grass(item_name);
  if (not data) then
    return false;
  end
  return true;
end










local farm_node = nil
local farm_nodenode = nil

local cutter_searching_distance = 50

local cutter_searching_range = {
                                x = cutter_searching_distance, 
                                y = 8, 
                                z = cutter_searching_distance}



local cutter_path_data = nil













local function find_grass_node(pos)
	local node = minetest.get_node(pos);
  local data = cutter.get_grass(node.name);
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


local found_npc_target = nil
local dobj = nil


local function farm_this(self)

-- TODO CHANGE THIS TO CUT GRASS ---

	local current_job = get_from_joblist(self,1)

	if current_job.status == 0 then
			self:set_displayed_action("Looking out for a injured NPC")
			dobj = self:get_nearest_wounded_npc(50)

			if dobj ~= nil then
				found_npc_target = dobj:get_pos()
				print("MEDIC:Found a wounded NPC at ", found_npc_target)
        		current_job.status = 1
	        	rem_from_joblist(self)
		        add_to_joblist(self,current_job)
        else

    		local waitjob1 = {
    			["name"] = "waitfor",
	    		["status"] = 80
		    }
            add_to_joblist(self,waitjob1)
        end





	elseif current_job.status == 1 then

		local destination = func.get_closest_clear_spot(self.object:get_pos(),found_npc_target)	
		local goto_here = {
			["name"] = "gotohere",
			["dest"] = destination,
			["status"] = 0
		}
		current_job.status = 2 --1 -- should be 4
		rem_from_joblist(self)
		add_to_joblist(self,current_job)
		add_to_joblist(self,goto_here)
		


	elseif current_job.status == 2 then

		local distance = vector.distance(self.object:get_pos(), dobj:get_pos())
		if distance < 2 then
            self:set_animation(simple_working_villages.animation_frames.MINE)
    		current_job.status = 3 
    		rem_from_joblist(self)
    		add_to_joblist(self,current_job)
        else
            self:set_animation(simple_working_villages.animation_frames.STAND)
    		current_job.status = 0 
    		rem_from_joblist(self)
    		add_to_joblist(self,current_job)
        end

	elseif current_job.status == 3 then

					local tophp = dobj:get_properties().hp_max
					local curhp = dobj:get_hp()
                    print("Top HP = ", tophp)
                    print("Cur HP = ", curhp)
				    if tophp ~= curhp then
                        dobj:set_hp(curhp + 1,{"Healed by medic"})
    		            current_job.status = 4 
    		            local waitjob1 = {
    			            ["name"] = "waitfor",
	    		            ["status"] = 80
		                }
    		            rem_from_joblist(self)
    		            add_to_joblist(self,current_job)
                        add_to_joblist(self,waitjob1)
					else
							print("MEDIC:I have healed the NPC")
							found_npc_target = nil
							destination = nil
							dobj = nil
					        self:set_animation(simple_working_villages.animation_frames.STAND)
					        current_job.status = 0 
    		                rem_from_joblist(self)
    		                add_to_joblist(self,current_job)
					end




    elseif current_job.status == 4 then


		local distance = vector.distance(self.object:get_pos(), dobj:get_pos())
		if distance < 2 then
    		current_job.status = 3 
    		rem_from_joblist(self)
    		add_to_joblist(self,current_job)
        else
            self:set_animation(simple_working_villages.animation_frames.STAND)
    		current_job.status = 0 
    		rem_from_joblist(self)
    		add_to_joblist(self,current_job)
        end




    		
	end

end



local function check_inventory_for_space(self)
					local medic_inv = self:get_inventory()
					--print("DUMP BUILDER INVENTORY: ", dump(medic_inv))
					if medic_inv:room_for_item("main", "dummy:unknown") then
						return true
					else
						return false
					end
end


local function put_func()
  return true;
end











local function stand_up(self)
	rem_from_joblist(self)
	self:set_animation(simple_working_villages.animation_frames.STAND)
end

local function sit_down(self)
	rem_from_joblist(self)
	self:set_animation(simple_working_villages.animation_frames.SIT)
end

local function lay_down(self)
	rem_from_joblist(self)
	self:set_animation(simple_working_villages.animation_frames.LAY)
end

local function do_situps(self)
	local current_job = get_from_joblist(self,1)
	if current_job.status > 0 then
		print("Do Situp")
		local waitjob1 = {
			["name"] = "waitfor",
			["status"] = 50
		}
		local sitjob = {
			["name"] = "sitdown",
			["status"] = 0
		}
		local waitjob2 = {
			["name"] = "waitfor",
			["status"] = 20
		}
		local layjob = {
			["name"] = "laydown",
			["status"] = 0
		}
		current_job.status = current_job.status - 1
		rem_from_joblist(self)
		add_to_joblist(self,current_job)
		add_to_joblist(self,waitjob2)
		add_to_joblist(self,layjob)
		add_to_joblist(self,waitjob1)
		add_to_joblist(self,sitjob)
	else
		local sitjob = {
			["name"] = "sitdown",
			["status"] = 0
		}
		rem_from_joblist(self)
		add_to_joblist(self,sitjob)
	end
end


local days_of_week = {
	[0] = "Sunday",
	[1] = "Monday",
	[2] = "Tuesday",
	[3] = "Wednesday",	
	[4] = "Thursday",	
	[5] = "Friday",	
	[6] = "Saturday",	
}	




local function check_time(self)

--	print("BUILDER: Checking TIME")
	local tod = minetest.get_timeofday()
	local gt = minetest.get_gametime()
	local dow = minetest.get_day_count()
--	print("TOD:", tod, " GT:", gt, " DOW:", dow)
	local the_day = math.fmod(dow,7)
--	print("TheDay:", the_day)
	local time_string = ""
	local hours = 24 * tod
	local hour = math.floor(hours)
	local mins = hours - hour
	local min = math.floor(mins * 60)


--	print("BUILDER:DEBUG:JOBACTION = ", self.job_data["jobaction"])

	if tod > self.bed_time then --and tod < self.wakeup_time then

		-- go to bed time
--		print("BUILDER: Testing bedtime")
		if self.job_data["jobaction"] == 1 then
--			print("BED TIME HAS BEEN SET")
		else
			print("NOW SETTING BED TIME")
			local bedtime_job = {
				["name"] = "bedtime",
				["status"] = 0
			}
--			rem_from_joblist(self)
			add_to_joblist(self,bedtime_job)
			self.job_data["jobaction"] = 1
		end

	elseif tod > self.stop_time then -- and tod < self.bed_time then
		-- get finish work time
--		print("BUILDER: Testing hometime")
		if self.job_data["jobaction"] ~= 2 then
			print("SETTING HOME TIME")
			local hometime_job = {
				["name"] = "hometime",
				["status"] = 0
			}
--			rem_from_joblist(self)
			add_to_joblist(self,hometime_job)
			self.job_data["jobaction"] = 2
		end

	elseif tod > self.work_time then -- and tod < self.stop_time then
		-- go to work time
--		print("BUILDER: Testing worktime")
		if self.job_data["jobaction"] ~= 3 then
			print("SETTING WORK TIME")
			local worktime_job = {
				["name"] = "worktime",
				["status"] = 0
			}
--			rem_from_joblist(self)
			add_to_joblist(self,worktime_job)
			self.job_data["jobaction"] = 3
		end

	elseif tod > self.wakeup_time then -- and tod < self.work_time then
		-- get out of bed time
--		print("BUILDER: Testing uptime")
		if self.job_data["jobaction"] ~= 4 then
			print("SETTING GETTING UP")
			local uptime_job = {
				["name"] = "uptime",
				["status"] = 0
			}
--			rem_from_joblist(self)
			add_to_joblist(self,uptime_job)
			self.job_data["jobaction"] = 4
		end
	else 
--		print("BUILDER: Testing endbedtime")
		if self.job_data["jobaction"] ~= 1 then
			print("SETTING ENDBED TIME")
			local bedtime_job = {
				["name"] = "bedtime",
				["status"] = 0
			}
--			rem_from_joblist(self)
			add_to_joblist(self,bedtime_job)
			self.job_data["jobaction"] = 1
		end

	end
	
		--	print("")




end


local function on_game_load(self)

			print("MEDIC: STARTING")
			-- check if I already have a bed and chest
--			local inv = self:get_inventory()
--			local stacks = inv:get_list("main")
--			local stack    = ItemStack("beds:bed_bottom")
--			local leftover = inv:add_item("main", stack)
--			local stack    = ItemStack("beds:bed_top")
--			local leftover = inv:add_item("main", stack)
--			print("LIST MAYORS INV")
--			local inv = self:get_inventory()
--			local stacks = inv:get_list("main")
--			for _, stack in ipairs(stacks) do
--				local itemname = stack:get_name()
--				local itemcount = stack:get_count()
--				print("STACK ITEM : ",itemname, itemcount)
--			end
--			self.job_data["joblist"] = {}			-- reset job list

			reset_joblist(self)
--			local nothing_job = {
--				name = "nothing",
--				status = 0
--				}
--			add_to_joblist(self,nothing_job)

--			local newjob = {
--				name = "checkbuilds",
--				status = 0
--				}
--			add_to_joblist(self,newjob)

--[[			local mybl = vector.add(get_job_position(self),medic_town_locations[1])
			local myml = vector.add(get_job_position(self),medic_town_markers[1])
			local medic_meta = minetest.get_meta(myml)

			local special_job = {
				["name"] = "movein1",
				["status"] = 0,
				["buildpos"] = mybl,
				["x"] = medic_meta:get_int("maxx"),
				["y"] = medic_meta:get_int("maxy"),
				["z"] = medic_meta:get_int("maxz"),
			}
			add_to_joblist(self,special_job)

			local cc_job = {
				name = "checkmychest",
				status = 0
			}		
			add_to_joblist(self,cc_job)

			local cb_job = {
				name = "checkmybed",
				status = 0
			}
			add_to_joblist(self,cb_job)

			local cjp_job = {
				name = "checkjobpos",
				status = 0
			}
			add_to_joblist(self,cjp_job)

			local situps_job = {
				name = "dositups",
				status = 0
				}
			add_to_joblist(self,situps_job)

			local homejob = {
				name = "gotohome",
				status = 0
				}
			add_to_joblist(self,homejob)
--]]


			medic_new_start = false

end




local function do_uptime(self)
print("BUILDER: DO UPTIME")
-- get up, go to home, sit down 

	local nothing_job = {
		name = "nothing",
		status = 0
	}
	local sitjob = {
		["name"] = "sitdown",
		["status"] = 0
	}
	local gotohome_job = {
		["name"] = "gotohome",
		["status"] = 0
	}
	local sitjobb = {
		["name"] = "sitdown",
		["status"] = 0
	}
	local waitjob = {
		["name"] = "waitfor",
		["status"] = 20
	}
			reset_joblist(self)
	add_to_joblist(self,sitjob)
	add_to_joblist(self,gotohome_job)
	add_to_joblist(self,waitjob)
	add_to_joblist(self,sitjob)

	self:set_displayed_action("getting up and getting ready for work")

end

local function do_worktime(self)
print("BUILDER: DO WORKTIME")
--	local dest = get_job_position(self)
--	local goto_job = {
--		["name"] = "gotohere",
--		["dest"] = dest,
--		["status"] = 0
--	}

	local cgrass_job = {
		["name"] = "cutgrass",
		["status"] = 0
	}

    

	rem_from_joblist(self)
	add_to_joblist(self,cgrass_job)

--	add_to_joblist(self,goto_job)

	--dositups
	-- do work if there is anything to do 
	-- or was working before continue
	-- should just stay put
	self:set_displayed_action("Ready for Work")

    


end

local function do_hometime(self)
print("BUILDER: DO HOMETIME")
-- go to home, sit down 

	self.object:set_velocity{x = 0, y = 0, z = 0}
	local sitjob = {
		["name"] = "sitdown",
		["status"] = 0
	}
	local gotohome_job = {
		["name"] = "gotohome",
		["status"] = 0
	}

	reset_joblist(self)
	add_to_joblist(self,sitjob)
	add_to_joblist(self,gotohome_job)
	self:set_displayed_action("relaxing after work")
end

local function do_bedtime(self)
	print("BUILDER: DO BEDTIME.")

	local current_job = get_from_joblist(self,1)
	print("CURRENT_JOB STATUS = ", current_job["status"])



--print("BUILDER:POS=")--, self.object:get_pos())
--print("DUMPJ:", dump(self.job_data["joblist"]))
	if current_job.status == 0 then

		if self.pos_data.bed_pos == nil then 
			print("BUILDER: DOES NOT KNOW WHERE TO SLEEP")
			current_job.status = 1
			reset_joblist(self)
			add_to_joblist(self,current_job)
		else
			--print("BUILDER BED POS = ", dump(self.pos_data.bed_pos))
			print("BUILDER: BED POS = ", self.pos_data.bed_pos)
			local dest = func.get_closest_clear_spot(self.object:get_pos(),self.pos_data.bed_pos)
			local dest = self.pos_data.bed_pos
			local gotobed_job = {
				["name"] = "gotohere",
				["dest"] = dest,
				["status"] = 0
			}
			current_job.status = 1
			reset_joblist(self)
			add_to_joblist(self,current_job)
			add_to_joblist(self,gotobed_job)
		end
	else
		--rem_from_joblist(self)
		print("Finishing BEDTIME")
		-- FIXME Unless set defaults to 0,0,0, and places NPC in ground


		self.object:set_velocity{x = 0, y = 0, z = 0}
		local bed_pos = vector.new(self.pos_data.bed_pos)
		local bed_top = func.find_adjacent_pos(bed_pos,
		function(p) return string.find(minetest.get_node(p).name,"_top") end)
		local bed_bottom = func.find_adjacent_pos(bed_pos,
		function(p) return string.find(minetest.get_node(p).name,"_bottom") end)

		if bed_top and bed_bottom then
			print("BUILDER:FOUND BED")
			self:set_yaw_by_direction(vector.subtract(bed_bottom, bed_top))
			bed_pos = vector.divide(vector.add(bed_top,bed_bottom),2)
			self.object:set_pos(bed_pos)

		else
			print("BUILDER:CANT FIND BED")
		end
		self:set_animation(simple_working_villages.animation_frames.LAY)
		self:set_state_info("Zzzzzzz...")
		self:set_displayed_action("sleeping")
		reset_joblist(self)
		
	end
end




local function check_for_item(self)

	local current_job = get_from_joblist(self,1)

	print("DUMPJOB:", dump(current_job))

	if self.pos_data.chest_pos == nil then
		-- first check I even have a chest
				
				local njob = {
					name = "notify",
					message = " in need of some " .. current_job["item"],
					status = 0
				}
				rem_from_joblist(self)
				add_to_joblist(self,njob)	
				return nil



	elseif current_job.status == 0 then
		-- goto my chest
			print("Builder is going to his chest to look for ", current_job.item)
			local dest = func.get_closest_clear_spot(self.object:get_pos(),self.pos_data.chest_pos)
			local gotochest_job = {
				["name"] = "gotohere",
				["dest"] = dest,
				["status"] = 0
			}
			current_job.status = 1
			rem_from_joblist(self)
				add_to_joblist(self,current_job)
			add_to_joblist(self,gotochest_job)


	elseif current_job.status == 1 then
		--look for item
		print("Builder is opening the chest to look for ", current_job.item)
		local inv = core.get_inventory({ type="node", pos=self.pos_data.chest_pos })
		if inv:is_empty("main") then

			print("Builder: The chest is EMPTY ", current_job.item)
			-- sit down and see if anyone notices ?? 	
		else

			local found = false
			local stacks = inv:get_list("main")
			for _, stack in ipairs(stacks) do

				if found == false then
					local itemname = stack:get_name()
					local itemcount = stack:get_count()
					print("STACK ITEM", _,": ",itemname, itemcount)

					if itemname == current_job.item then
						print("ITEM ", current_job.item, " FOUND !")
						found = true
						local myinv = self:get_inventory()
						
					
						if not inv:room_for_item("main", stack) then
							print("Not enough room!")
							local njob = {
								name = "notify",
								message = "I dont seem to have enough room in my bag ??? \nI don't know why\n",
								status = 0
							}
							--current_job.status = 1
							--rem_from_joblist(self)
							--add_to_joblist(self,current_job)
							add_to_joblist(self,njob)




						else

							local taken = inv:remove_item("main", stack)
							print("Took " .. taken:get_count())
							local leftover = myinv:add_item("main", taken)
							print("LEFTOVER=", leftover:get_count())
							rem_from_joblist(self)
						
						end
					end
				end


			end
			if found == false then
				local njob = {
					name = "notify",
					message = "I do not seem to have any ", current_job.item, " in my chest ??? \nCan you help me out ?\n",
					status = 0
				}
				add_to_joblist(self,njob)	
			end

		end



	end

end


















local slow_update_count = 100
local under_attack = false




simple_working_villages.register_job("simple_working_villages:job_medic", {
	description      = "medic (simple_working_villages)",
	long_description = "I fix people? and NPC's.\
I love people.",
	inventory_image  = "default_paper.png^working_villages_medic.png",
	jobfunc = function(self)


-- TODO ANIMATION TWEEKS
--print("OBJECT DUMP:", self.object:get_animation())
--	self.object:get_animation(frame_range, frame_speed, frame_blend, frame_loop)
--		set_animation(frame_range, frame_speed, frame_blend, frame_loop)
--		set_animation_frame_speed(frame_speed)
--function simple_working_villages.villager:get_animation()
--	if self.curr_animation == nil then 
--		return nil
--	end
--	if self.curr_animation.x == 0 and self.curr_animation.y == 79 then 
--		return "STAND"
--	elseif self.curr_animation.x == 162 and self.curr_animation.y == 166 then
--		return "LAY"
--	elseif self.curr_animation.x == 168 and self.curr_animation.y == 187 then
--		return "WALK"
--	elseif self.curr_animation.x == 189 and self.curr_animation.y == 198 then
--		return "MINE"
--	elseif self.curr_animation.x == 200 and self.curr_animation.y == 219 then
--		return "WALK_MINE"
--	elseif self.curr_animation.x == 81 and self.curr_animation.y == 160 then
--		return "SIT"
--	else
--		return nil
--	end
--end

				--print("BuilderPos:", dump(self.object:get_pos()))




		if use_vh1 then VH1.update_bar(self.object, self.object:get_hp()) end







-- ONLY ON GAME LOAD AND CONTINUE
		if medic_new_start == true then
            print("VET: ON GAME START")
			self.job_data["joblist"] = {}
			self.job_data["jobaction"] = 0		-- TODO Idea to use this as the main loop control
			on_game_load(self)
			check_time(self)
		end







-- SLOW UPDATE
		if slow_update_count < 1 then
		-- ignore slow updates if being attacked
			if under_attack == false then
			-- do slow update jobs
				check_time(self)


			end
			slow_update_count = 200
		else
			slow_update_count = slow_update_count -1
		end


















	--	self:handle_night()
--		if not self.job_data.manipulated_chest then 

--			self.job_data["subaction"] = 0
--		end

	--	self:handle_chest(nil, nil)
		self:handle_doors()	


		local is_hit = self:have_i_been_attacked()
		--print("IS HIT = ", is_hit)
		if is_hit ~= nil then 
			print("I WAS ATTACKED BY ", dump(is_hit.object))
			-- place job to handle attack

		end

		check_medic_message(self)







	--	print("NOW CHECKING INV")
		if check_inventory_for_space(self) == false then
			--self:handle_chest(nil, nil)
			self.job_data.manipulated_chest = false;
			self:handle_chest(nil, put_func)
		end




		--self:buried_check()

-- TODO TODO TODO replace these with job_list
-- print("JOBLIST=", dump(medic_joblist))

--for ijl = 1, get_size_joblist(self) do
--	print("BUILDERJOBS[", ijl, "]=", get_from_joblist(ijl).name)
--end

 --print("walk speed = ", self.walk_speed)

--print("medic JOBS = ", get_size_joblist(self))
if get_size_joblist(self) == 0 then 
			local njob = {
				name = "notify",
				message = "I have lost what I am doing ??? \nI don't know why\n",
				status = 0
				}
			add_to_joblist(self,njob)
end

--	print("BUILDER:JOBDUMP:", dump(self.job_data["joblist"]))


		local current_job = get_from_joblist(self,1)

		if current_job.name == "morning" then 				--lookdirection job
			do_morning_routine(self)				


		elseif current_job.name == "nothing" then
			--print("Doing Nothing")
			-- FIXME cheap fix to continue doing something instead of nothing
--			local cbuilds_job = {
--				["name"] = "checkbuilds",
--				["status"] = 0
--			}
--			add_to_joblist(self,cbuilds_job)



		elseif current_job.name == "checkforitem" then
			check_for_item(self)



		
		elseif current_job.name == "startup" then
			start_up(self)
		
		elseif current_job.name == "checkfortrees" then
			check_for_trees(self,dist)
		
		elseif current_job.name == "uptime" then
			do_uptime(self)
		
		elseif current_job.name == "worktime" then
			do_worktime(self)
		
		elseif current_job.name == "hometime" then
			do_hometime(self)
		
		elseif current_job.name == "bedtime" then
			do_bedtime(self)
		
		elseif current_job.name == "notify" then
			notify_me(self)

		elseif current_job.name == "sitdown" then
			sit_down(self)

		elseif current_job.name == "laydown" then
			lay_down(self)

		elseif current_job.name == "dositups" then
			do_situps(self)

		elseif current_job.name == "beenpunched" then
			been_punched(self)

		elseif current_job.name == "gotohome" then
			goto_myhome(self)

		elseif current_job.name == "checkname" then
			check_my_name(self)

		elseif current_job.name == "cutgrass" then
			farm_this(self)

		elseif current_job.name == "waitfor" then
			wait_for_time(self) 


			--print("UP TO CHECK BUILDS")
			--check_for_buildings(self)
			--coroutine.yield(co_command.pause,"Check Builds\n")
		elseif current_job.name == "gotohere" then
			--print("JOB:GOTOHERE")
			auto_go(self,false)

		else
			-- ERROR HERE = UNKNOWN JOB
			print("DUMP UNKNOWN JOB = ", dump(current_job.name))
			coroutine.yield(co_command.pause,"ERROR FOUND A JOB I DO NOT KNOW\n")
		end

end
})
