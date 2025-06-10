local func = simple_working_villages.require("jobs/util")
local build = simple_working_villages.require("building")
local co_command = simple_working_villages.require("job_coroutines").commands
local use_vh1 = minetest.get_modpath("visual_harm_1ndicators")
local pathfinder = simple_working_villages.require("pathfinder")


-- TODO JOB PLAN OF THE NEW TOWN
--buildingplot_sml_wood_house1_N(15x20).we
--building_plot_start.we
-- workshop is 17 east of job


-- set to check for a game load start
local lumberjacka_new_start = true

local lumberjack_tending_orchard = false


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

local lumberjacka_lumberjacka = nil		-- tells if there is a builder on hand


local lumberjacka_marker = nil
--local lumberjacka_lumberjacka_job = "simple_working_villages:job_builder_a"
--local lumberjacka_lumberjacka_npc = "simple_working_villages:villager_male_builder_a"


--local lumberjacka_marker = "simple_working_villages:building_marker"
local lumberjacka_is_morning = true		-- tells if it is the start of the day
local lumberjacka_lumberjacka = nil		-- tells if there is a builder on hand
local lumberjacka_building_count = 0		-- current town building job number
local lumberjacka_job_status = 0	-- current status of current building job
					-- 0 = no building ready 
					-- 1 = building started
					-- 2 = building is finished
					-- 3 = finish and moveon
local lumberjacka_path_data = nil	-- the mayors private path_data
local lumberjacka_searching_range = {x = 10, y = 1, z = 10}
local lumberjacka_searching_distance = 100
local lumberjacka_found_plant_target = nil
local lumberjacka_builder_here = false
local lumberjacka_lumberjacka_message = nil
local lumberjacka_is_building = false



-- TODO MESSAGING MESSAGES TO BE UPDATED

local lumberjacka_callingmessage = 	{ 
			msg = "Calling Lumberjack A",
			}
local lumberjacka_callingreply = 	{ 
			msg = "Lumberjack A OK",
			}
local lumberjacka_jobreply = 	{ 
			msg = "Lumberjack Finished",
			}
local lumberjacka_comemessage = 	{ 
			msg = "Lumberjack Come Here",
			pos = "",
			}
local lumberjacka_chopmessage = 	{ 
			msg = "Lumberjack chop this",
			pos = "",
			}
local lumberjacka_moveinmessage = 	{ 
			msg = "Lumberjack Movein Here",
			}
local lumberjacka_plantorchardmessage = 	{ 
			msg = "Lumberjack Plant Orchard",
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
	if self.pos_data.home_pos == nil then --or self.pos_data.home_pos == '' then
		return get_job_position(self)
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

local function look_at_position(in_self,in_pos)
	local direction = vector.subtract(in_pos, in_self.object:get_pos())
	direction.y = 0
	in_self:set_yaw_by_direction(direction)
end

local function plan_to_next_to(mypos,mydest,self)
--	print("MYPOS=", mypos)
--	print("MYDEST=", mydest)
	local lumberjacka_myd = mydest
	lumberjacka_path_data = pathfinder.plot_movement_to_pos(mypos, lumberjacka_myd, false)
	if lumberjacka_path_data == nil then
		-- TODO should indicate who cannot find a path
		print(" No Path Found to ", lumberjacka_myd)
		self.job_data["pathdata"] = {}
		self.job_data["pathstep"] = -1
		return false
	elseif lumberjacka_path_data == false then
		print(" IT SEEMS PATHFINDER IS BUSY-- I WILL HAVE TO WAIT MY TURN")
		self.job_data["pathdata"] = {}
		self.job_data["pathstep"] = -1
		return nil 
	else
--		print("          PATHFINDER PLANNED OK")
--		print("          PATHDATA: ",  lumberjacka_path_data)
		self.job_data["pathdata"] = lumberjacka_path_data
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
			print("AUTOGO NO DESTINATION")
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
		local goonres = go_on_path(self,isrunning)
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


local function check_my_jobpos(self)
	-- need to check job_pos
	print("Checking my JOBPOS")				
	local current_job = get_from_joblist(self,1)
	if get_job_position(self) == nil  then
		-- no jobpos found
		self:set_animation(simple_working_villages.animation_frames.MINE)
		local notify_job = {
			["name"] = "notify",
			["status"] = 0,
			["message"] = " in need of a JOBPOS to start the new town center\n"
		}
		add_to_joblist(self,notify_job)
	else
		-- found a jobpos
		print("The Town Center is at ", get_job_position(self))	
		-- TODO should not really do this here
		if self.pos_data.home_pos == nil then
			print("SETTING START HOME AND BED LOC")
			self.pos_data.home_pos = vector.add(get_job_position(self),{x=-6,y=0,z=0})
			self.pos_data.bed_pos = vector.add(get_job_position(self),{x=-4,y=0,z=0})

		end
		rem_from_joblist(self)
	end
end



local function do_morning_routine(self)
	--print("DO CATCHUP ROUTINE")
	local current_job = get_from_joblist(self,1)
	if current_job.status == 0 then
		--print("ADDING JOBS TO LIST")

		-- wait for instructions

		-- go to campfire

		-- go to Job

		-- finish job

--		current_job.status = 1
--		rem_from_joblist(self)
--		add_to_joblist(self,current_job)
--		local cbuilds_job = {
--			["name"] = "checkbuilds",
--			["status"] = 0
--		}
--		add_to_joblist(self,cbuilds_job)

--		if get_job_position() ~= nil then
--			local cgoto_job = {
--				["name"] = "gotohere",
--				["dest"] = get_job_position(self),
--				["status"] = 0
--			}
--			add_to_joblist(self,cgoto_job)
--		end

----		local cjobpos_job = {
--			["name"] = "checkjobpos",
--			["status"] = 0
--		}
--		add_to_joblist(self,cjobpos_job)
--
--		local cname_job = {
--			["name"] = "checkname",
--			["status"] = 0
--		}
--		add_to_joblist(self,cname_job)

	elseif current_job.status == 1 then
		--should be uptodate
		print("SHOULD BE UPTO DATE WITH MORNING ROUTINE ")				
		rem_from_joblist(self)

	end
end


local function wait_for_lumberjacka_ok()
	local current_job = get_from_joblist(self,1)
	rem_from_joblist(self)
	print("DO wait_for_lumberjacka_ok JOB ", current_job.status)				
	if current_job.status > 0 then
		-- keep checking
		local themessage = nil
		if func.get_builder_a_message() ~= nil then 
			themessage = func.get_builder_a_message()
			if themessage.msg == lumberjacka_callingreply.msg then
				return true
			elseif themessage.msg == lumberjacka_jobreply.msg then
				return true	
			else
				current_job.status = current_job.status - 1
				add_to_joblist(self,current_job)
			end
		end 
	else
		-- no answer from builder
		local notify_job = {
			["name"] = "notify",
			["status"] = 0,
			["message"] = " a little worried\nThere is no Answer from the builder !!\nCould you check on him for me?\n"
		}
		add_to_joblist(self,notify_job)
	end
end

-- TODO not needed now ? 
local wfba_timeout = 800
local function wait_for_lumberjacka_finished()
	local answer = false
	if wfba_timeout == 0 then 
		return false 
	end
	if func.get_builder_a_message() ~= nil then 
		local themessage = nil
		themessage = func.get_builder_a_message()
		if themessage.msg == lumberjacka_jobreply.msg then
			func.set_builder_a_message(nil)
			return true
		else
		wfba_timeout = wfba_timeout - 1
		end
	end
	return nil
end


local function lumberjacka_plantonextto(mypos,mydest)
	local lumberjacka_myd = func.get_closest_clear_spot(mypos,mydest)	
	if lumberjacka_myd == false or lumberjacka_myd == nil then
		lumberjacka_myd = mydest
	end
	lumberjacka_path_data = pathfinder.plot_movement_to_pos(mypos, lumberjacka_myd, false)
	if lumberjacka_path_data == nil then
		-- TODO should indicate who cannot find a path
		return nil
	elseif lumberjacka_path_data == false then
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
			lumberjacka_plantonextto(curr_loc,epos)
			self:go_to_the(lumberjacka_path_data)
		else
			return true
		end
		ma_tries = ma_tries - 1
		thedist = vector.distance(spos,epos)
	end
	return false
end



local function check_for_buildings(self)

	local current_job = get_from_joblist(self,1)
	print("DUMP CHECK BUILDINGS JOB ", dump(current_job))
	if current_job["status"] == 0 then
		-- begin
		current_job.status = 1
		rem_from_joblist(self)
		add_to_joblist(self,current_job)
		lumberjacka_building_count = 1
		print("MAYORA: OPENING BUILDING BLUEPRINTS : ", lumberjacka_building_count)
		if lumberjacka_town_markers[lumberjacka_building_count] == nil then
			print("MAYORA: I CAN NOT FIND THE TOWN PLAN START: ", lumberjacka_step)
			rem_from_joblist(self)
			return false
		end
		return nil

	elseif current_job["status"] == 1 then
		print("MAYORA: FINDING BLUEPRINT : ", lumberjacka_building_count)
		if lumberjacka_town_markers[lumberjacka_building_count] == nil then 
			rem_from_joblist(self)
			local notify_job = {
				["name"] = "notify",
				["status"] = 0,
				["message"] = "There is no plan for the next building\n"
			}
			add_to_joblist(self,notify_job)
			return false
		end
		local mpos = self.object:get_pos() -- my position
		local jpos = get_job_position(self)
		local bma_loc = vector.add(jpos,lumberjacka_town_markers[lumberjacka_building_count])
		current_job.status = 2
		rem_from_joblist(self)
		add_to_joblist(self,current_job)
		local waitfor_job = {
			["name"] = "waitfor",
			["status"] = 100
		}
		add_to_joblist(self,waitfor_job)
		-- add gotohere
		local goto_job = {
			["name"] = "gotohere",
			["dest"] = bma_loc,
			["status"] = 0
		}
		add_to_joblist(self,goto_job)

	elseif current_job["status"] == 2 then
		local mpos = self.object:get_pos() -- my position
		local jpos = get_job_position(self)
		local bma_loc = vector.add(jpos,lumberjacka_town_markers[lumberjacka_building_count])
		self:set_yaw_by_direction(bma_loc)

		if minetest.get_node(bma_loc).name == lumberjacka_marker then
			local lumberjacka_meta = minetest.get_meta(bma_loc)
			print("BUILD", lumberjacka_building_count, " STATE = ", lumberjacka_meta:get_string("state"))
			if lumberjacka_meta:get_string("state") == "finished" then
				-- this building has been built by the builder and awaits signing off
				rem_from_joblist(self)
				local signoff_job = {
					["name"] = "signoffbuild",
					["status"] = 0
				}
				add_to_joblist(self,signoff_job)
				return true
			elseif lumberjacka_meta:get_string("state") == "built" then
				-- this building is finished and signed off for use - CHECK NEXT
				lumberjacka_building_count = lumberjacka_building_count + 1
				current_job.status = 1
				rem_from_joblist(self)
				add_to_joblist(self,current_job)
				return nil
			elseif lumberjacka_meta:get_string("state") == "begun" then
				-- this building is begun -- so continue
				rem_from_joblist(self)
				local continuebuild_job = {
					["name"] = "continuebuild",
					["status"] = 0
				}
				add_to_joblist(self,continuebuild_job)
				return true
			elseif lumberjacka_meta:get_string("state") == "unplanned" then
				-- this building is unplanned  -- setup error ?
				rem_from_joblist(self)
				local continuebuild_job = {
					["name"] = "continuebuild",
					["status"] = 0
				}
				add_to_joblist(self,continuebuild_job)
				return true

			end
		else
			-- this building is planned by not started
			rem_from_joblist(self)
			local startbuild_job = {
				["name"] = "startbuild",
				["status"] = 0
			}
			add_to_joblist(self,startbuild_job)
			return true
		end	
	end
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



local function signoff_building(self)

	-- sign off the building as finished
	local current_job = get_from_joblist(self,1)
	print("DUMP CHECK BUILDINGS JOB ", dump(current_job))
	local mybl = vector.add(get_job_position(self),lumberjacka_town_locations[lumberjacka_building_count])
	local myml = vector.add(get_job_position(self),lumberjacka_town_markers[lumberjacka_building_count])


	-- should go around the site and "check" it is ok to sign off


	if current_job["status"] == 0 then
		-- go and have a little look at the build
		current_job.status = 1
		rem_from_joblist(self)
		add_to_joblist(self,current_job)
		check_build_site()

	elseif current_job["status"] == 1 then
		-- go back to the building marker
		current_job.status = 2
		rem_from_joblist(self)
		add_to_joblist(self,current_job)
		local goto_job = {
			["name"] = "gotohere",
			["dest"] = myml,
			["status"] = 0
		}
		add_to_joblist(self,goto_job)

	elseif current_job["status"] == 2 then
		-- finish and remove job
		rem_from_joblist(self)
		local lumberjacka_meta = minetest.get_meta(myml)

		if lumberjacka_meta:get_string("state") == "finished" then

			lumberjacka_meta:set_string("state","built")
			--local temps = 
			lumberjacka_meta:set_string("house_label", lumberjacka_town_names[lumberjacka_building_count])
			lumberjacka_meta:set_string("formspec",simple_working_villages.buildings.get_formspec(lumberjacka_meta))
	lumberjacka_meta:set_string("owner", self.owner_name)
	lumberjacka_meta:set_string("infotext", lumberjacka_town_names[lumberjacka_building_count])

			lumberjacka_job_status = 3
		end
		local cbuilds_job = {
			["name"] = "checkbuilds",
			["status"] = 0
		}
		add_to_joblist(self,cbuilds_job)

	-- TODO check here for special instructions


		if lumberjacka_special_action_jobs[lumberjacka_building_count] ~=	nil then	

			special_job = lumberjacka_special_action_jobs[lumberjacka_building_count]
			add_to_joblist(self,special_job)
--		if lumberjacka_building_count == 1 then 
--				local movein1_job = {
--					["name"] = "movein1",
--					["status"] = 0,
--					["bedaloc"] = { x = 9, y = 0, z = 6 },
--					["bedbloc"] = { x = 13, y = 0, z = 1 },
--					["chestaloc"] = { x = 15, y = 0, z = 7 },
--					["chestbloc"] = { x = 15, y = 0, z = 1 },
--					["homealoc"] = { x = -5, y = 0, z = 3 },
--					["homebloc"] = { x = 11, y = 0, z = 3 },
--					["fireloc"] = { x = 9, y = 0, z = 2 }
--				}				
		end
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
		-- if trees found = call lumberjack to remove trees in area
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




local function check_lumberjacka_message(self)

	--print("lumberjack checking messages")
	local themessage = nil
	if func.get_lumberjack_a_message() ~= nil then 
		-- there is a message
		themessage = func.get_lumberjack_a_message()

		--print("LUMBERJACK: GOT MESSAGE = ", dump(themessage))

		if themessage.msg == lumberjacka_callingmessage.msg then
			-- I must answer the phone
			print("LUMBERJACKA: IS ANSWERING THE PHONE")
			func.set_lumberjack_a_message(lumberjacka_callingreply)
		end

		if themessage.msg == lumberjacka_comemessage.msg then

			print("LUMBERJACKA: IS BEING CALLED OVER")
			lumberjacka_commanddestination = themessage.pos	
			func.set_lumberjack_a_message(lumberjacka_callingreply)

			local goto_job = {
				["name"] = "gotohere",
				["dest"] = themessage.pos,
				["status"] = 0
			}
			add_to_joblist(self,goto_job)
	

--			while func.get_builder_a_message().msg == lumberjacka_callingreply	do
				-- wait for message to be recieved
--				coroutine.yield()
--			end

		end


	
		if themessage.msg == lumberjacka_chopmessage.msg then
			-- I must answer the phone
			print("LUMBERJACKA: IS BEING TOLD TO CHOP A TREE")
			lumberjacka_marker = vector.round(themessage.pos)	
			--func.set_builder_a_message(lumberjacka_callingreply)
			func.set_lumberjack_a_message(lumberjacka_callingreply)

			--add_to_joblist(self,b_job)
			local build_job = {
				["name"] = "chopthis",
				--["buildpos"] = themessage.pos,
				["status"] = 0
			}
			add_to_joblist(self,build_job)
--			while func.get_builder_a_message().msg == lumberjacka_callingreply	do
				-- wait for message to be recieved
--				coroutine.yield()
--			end

		end


		if themessage.msg == lumberjacka_moveinmessage.msg then
			-- I must answer the phone
			print("LUMBERJACKA: IS BEING TOLD TO MOVEIN")

			local data = { }

			--self.pos_data.food_pos = vector.round(themessage.food_pos) or nil
			--self.pos_data.storage_pos = vector.round(themessage.storage_pos) or nil
			--self.pos_data.job_pos = vector.round(themessage.job_pos) or nil
			--self.pos_data.tools_pos = vector.round(themessage.tools_pos) or nil
			self.pos_data.chest_pos  =  vector.round(themessage.chest_pos) or nil
			self.pos_data.bed_pos  = vector.round(themessage.bed_pos) or nil
			self.pos_data.home_pos = vector.round(themessage.home_pos) or nil

            print("LUMBERJACKA: CHESTPOS = " , self.pos_data.chest_pos)
			print("LUMBERJACKA: BEDPOS = ", self.pos_data.bed_pos)
			print("LUMBERJACKA: HOMEPOS = ", self.pos_data.home_pos)
			
			func.set_lumberjack_a_message(lumberjacka_callingreply)

			self.job_data.manipulated_chest = false;
			self:handle_chest(nil, nil)				
			self:delay(100)

		end




		if themessage.msg == lumberjacka_plantorchardmessage.msg then
			-- I must answer the phone
			print("LUMBERJACKA: IS BEING TOLD TO PLANT ORCHARD")
			if lumberjack_tending_orchard == false then
				local plantorchard_job = themessage
				plantorchard_job["name"] = "plantorchard"
				add_to_joblist(self,plantorchard_job)
				lumberjack_tending_orchard = true
			end
			func.set_lumberjack_a_message(lumberjacka_callingreply)


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


local function find_building(p)
	if minetest.get_node(p).name ~= "simple_working_villages:building_marker" then
		return false
	end
	local lumberjacka_meta = minetest.get_meta(p)
	if lumberjacka_meta:get_string("state") ~= "begun" then
		return false
	end
	local lumberjacka_build_pos = simple_working_villages.buildings.get_build_pos(lumberjacka_meta)
	if lumberjacka_build_pos == nil then
		return false
	end
	if simple_working_villages.buildings.get(lumberjacka_build_pos)==nil then
		return false
	end
	return true
end


local function been_punched(self)

print("This is where I handle the ON PUNCH EVENT !!")

--self:have_i_been_attacked()


end



local function check_build_item(self,initem)




				-- TODO TRY BEDTOP REPLACEMENT
				if initem:find("beds:bed_top") then
					local lumberjacka_inv = self:get_inventory()
					if lumberjacka_inv:room_for_item("main", ItemStack(initem)) then
						lumberjacka_inv:add_item("main", ItemStack(initem))
					else
						local msg = "lumberjacka at " .. minetest.pos_to_string(self.object:get_pos()) ..
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
				if initem:find("beds:bed_bottom") then
					local lumberjacka_inv = self:get_inventory()
					if lumberjacka_inv:room_for_item("main", ItemStack(initem)) then
						lumberjacka_inv:add_item("main", ItemStack(initem))
					else
						local msg = "lumberjacka at " .. minetest.pos_to_string(self.object:get_pos()) ..
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
				if (initem=="homedecor:book_open_blue") or (initem=="homedecor:book_open_red") or (initem=="homedecor:book_open_grey") or (initem=="homedecor:book_open_green") or (initem=="homedecor:book_open_violet") then
					if self:has_item_in_main(function (name) return name == "homedecor:book_red" end) then
						local inv = self:get_inventory()
					  	if inv:room_for_item("main", ItemStack(initem)) then
							self:replace_item_from_main(ItemStack("homedecor:book_red"),ItemStack(initem))
						else
							local msg = "lumberjacka at " .. minetest.pos_to_string(self.object:get_pos()) ..
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
							local msg = "lumberjacka at " .. minetest.pos_to_string(self.object:get_pos()) ..
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
							local msg = "lumberjacka at " .. minetest.pos_to_string(self.object:get_pos()) ..
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
					
					lumberjacka_nnode.param1 = 0
					
				end


end



local build_node = nil
local build_nodenode = nil



local function is_sapling_spot(pos)
	-- FIXME: need a player name if villagers can own a protected area
	if minetest.is_protected(pos, "") then return false end
	if simple_working_villages.failed_pos_test(pos) then return false end
	local lpos = vector.add(pos, {x = 0, y = -1, z = 0})
	local lnode = minetest.get_node(lpos)
	if minetest.get_item_group(lnode.name, "soil") == 0 then return false end
	local light_level = minetest.get_node_light(pos)
	if light_level <= 12 then return false end
	-- A sapling needs room to grow. Require a volume of air around the spot.
	for x = -1,1 do
		for z = -1,1 do
			for y = 0,2 do
				lpos = vector.add(pos, {x=x, y=y, z=z})
				lnode = minetest.get_node(lpos)
				if lnode.name ~= "air" then return false end
			end
		end
	end
	return true
end


local function is_sapling(n)
	local name
	if type(n) == "table" then
		name = n.name
	else
		name = n
	end
	if minetest.get_item_group(name, "sapling") > 0 then
		return true
	end
	return false
end


local function find_tree(p)
	local adj_node = minetest.get_node(p)
	if minetest.get_item_group(adj_node.name, "tree") > 0 then
		-- FIXME: need a player name if villagers can own a protected area
		if minetest.is_protected(p, "") then return false end
		if simple_working_villages.failed_pos_test(p) then return false end
		return true
	end
	return false
end

local function get_tree_height(self,pos)

--	print("Tree Measure inPOS = ", pos)
	local tpos = vector.new(pos)
--	print("Tree TPOS = ", tpos)
--	local current_job = get_from_joblist(self,1)
--	rem_from_joblist(self)

	local found_tree = minetest.get_node(pos).name
--	print("I am Looking at a ", found_tree)

	local cheight = 0
	local atpos = minetest.get_node(tpos).name

	while atpos == found_tree do
		cheight = cheight + 1
		
		tpos = vector.new{ x= pos.x, y= (pos.y + cheight), z= pos.z }
		atpos = minetest.get_node(tpos).name
--		print("CHEIGHT : ", cheight)
--		print("TPOS : ", dump(tpos))
--		print("ATPOS : ", atpos)
						coroutine.yield()

	end

--	print("The Tree seems to be ", cheight, " blocks tall")
	return cheight
end

local tree_types = {
	[1] = "default:pine_tree",
	[2] = "default:aspen_tree",
	[3] = "default:tree",
}

local treetypefound = nil

local function savefoundtree(self,pos)
	for key,val in pairs(tree_types) do
--		print("IN LOC = ", minetest.get_node(pos).name)
		if minetest.get_node(pos).name == val then
--			print("tree part found")
--			print("I THINK I HAVE FOUND A TREE")
			treetypefound = minetest.get_node(pos).name
			return true
		end
	end
--	treetypefound = nil
	return false
end

local function chop_this(self)

	--minetest.get_node(tpos).name

	local current_job = get_from_joblist(self,1)
	rem_from_joblist(self)
	local treedest = vector.add(lumberjacka_marker, vector.new{ x=0, y=0, z=1})
	--local theight = 0
--	print("LUMBERJACK: Enter chop_this")
--	print("lumberjack tree marker location = ", lumberjacka_marker)
--	print("lumberjack treedest = ", treedest)


	if current_job.status == 0 then
		-- go to north of trees location 

		-- save the type of tree found
		savefoundtree(self,lumberjacka_marker)
--		print("LUMBERJACK: Going to TREE JOB location")
--		print("lumberjack tree marker location = ", lumberjacka_marker)
--		print("lumberjack treedest = ", treedest)
		local goto_job = {
			["name"] = "gotohere",
			["dest"] = treedest,
			["status"] = 0
		}
		current_job["height"] = 0
		current_job.status = 1
		add_to_joblist(self,current_job)
		add_to_joblist(self,goto_job)

	elseif current_job.status == 1 then
		-- check the tree height
--		print("LUMBERJACK: Checking Tree height")
--		print("DUMP JOB: ", dump(current_job))
		current_job["height"] = get_tree_height(self,lumberjacka_marker)
--		print("The Tree Trunk seems to be ", current_job["height"], " blocks tall")
		current_job.status = 2
		add_to_joblist(self,current_job)
--		print("DUMP JOB: ", dump(current_job))
		
	elseif current_job.status == 2 then
		-- build ladder up to the top

		-- TODO include height
--		print("LUMBERJACK: Building ladder to top")
--		print("DUMP JOB: ", dump(current_job))
		
		local lnode = {
			["name"] = "default:ladder_wood",
			["param2"] = 5
		}


		-- FIXME the following needs to be correctly added to the job stack
		-- FIXME needs a goto stage to get close to place point

		-- TODO need to slow this chap down, maybe configurable in Register.lua

		-- TODO may increase to 3 -- short apple trees will be chopped from the ground




		if current_job["height"] > 3 then

			-- remember the length of the ladder
			if current_job["lcount"] == nil then 
				current_job["lcount"] = 0
				
			end


			if current_job["lcount"] > current_job["height"]-2 then
--				print(" Ladder is finished ? ")
				current_job.status = 3
				add_to_joblist(self,current_job)
			else

				local placeloc = {
					["x"] =	treedest.x,
					["y"] =	treedest.y + current_job["lcount"],
					["z"] =	treedest.z,
				}
--				print("PLACELOC" , current_job["lcount"], " = ", placeloc)

--				print("Lumberjack:found ", minetest.get_node(placeloc).name, " where my ladder needs to go at ", placeloc)
				if minetest.get_node(placeloc).name ~= "air" then
					-- while for blueberry bushs pick then chop
--					print("Removing a node thats in the way of my ladder")
					self:dig(placeloc,false)
					coroutine.yield()
				end
				local function is_material(name)
					return name == lnode.name
				end







				local wield_stack = self:get_wield_item_stack()
				if is_material(wield_stack:get_name()) or self:has_item_in_main(is_material) then
					if minetest.get_node(placeloc).name == "air" then
						self:place(lnode,placeloc)
						coroutine.yield()
--						print("Tying to place node")
					else
						print("LUMBERJACK: THERE WAS A PROBLEM, DID NOT PLACE LADDER")
					end

				else




					local msg = "LUMBERJACK at " .. minetest.pos_to_string(vector.round(self.object:get_pos())) .. " is going home to look for " .. lnode.name
					local smsg = "I am going home to look for a " .. lnode.name
					if self.owner_name then
						minetest.chat_send_player(self.owner_name,msg)
					else
						print(msg)
					end
						current_job.status = 0
					self:set_state_info(smsg)
						local checkforitem_job = {
							["name"] = "checkforitem",
							["status"] = 0,
							["item"] = lnode.name
						}
						rem_from_joblist(self)
						add_to_joblist(self,current_job)
						add_to_joblist(self,checkforitem_job)


                    return
--					coroutine.yield(co_command.pause,"waiting for materials")






				end



--					local msg = "lumberjacka at " .. minetest.pos_to_string(self.object:get_pos()) .. " doesn't have " .. lnode.name
--					if self.owner_name then
--						minetest.chat_send_player(self.owner_name,msg)
--					else
--						print(msg)
--					end
--					self:set_state_info(("I am currently waiting for somebody to give me some %s."):format(lnode.name))
--					coroutine.yield(co_command.pause,"waiting for materials")
--				end

				-- should try to climb the tree to placeloc
				current_job["lcount"] = current_job["lcount"] + 1


				local gotoloc = {
					["x"] = placeloc.x,
					["y"] = placeloc.y -3,
					["z"] = placeloc.z
				}

				local goto_job = {
					["name"] = "gotohere",
					["dest"] = gotoloc,
					["status"] = 0
				}
				add_to_joblist(self,current_job)
				add_to_joblist(self,goto_job)

				--auto_go(self,false)
				

			end

		else 
			-- no ladder needed ?
			current_job.status = 3
			add_to_joblist(self,current_job)
		end

	elseif current_job.status == 3 then
		-- chop the tree from the top
--		print("LUMBERJACK: Going to the top of the tree")
--		print("DUMP JOB: ", dump(current_job))

		if current_job["height"] then
			treedest.y = treedest.y + ( current_job["height"] - 3 )
		end

		local goto_job = {
			["name"] = "gotohere",
			["dest"] = treedest,
			["status"] = 0
		}

		current_job.status = 4
		add_to_joblist(self,current_job)
		add_to_joblist(self,goto_job)


	elseif current_job.status == 4 then
		-- check for apple tree branches
--		print("LUMBERJACK: Chopping the top of the tree")
--		print("DUMP JOB: ", dump(current_job))

--		TODO enclose in while 

		local loc_ne = vector.add(lumberjacka_marker, vector.new{ x=1, y=current_job["height"], z=1})
		local loc_nw = vector.add(lumberjacka_marker, vector.new{ x=-1, y=current_job["height"], z=1})
		local loc_se = vector.add(lumberjacka_marker, vector.new{ x=1, y=current_job["height"], z=-1})
		local loc_sw = vector.add(lumberjacka_marker, vector.new{ x=-1, y=current_job["height"], z=-1})
		local loc_top = vector.add(lumberjacka_marker, vector.new{ x=0, y=current_job["height"], z=0})
		local loc_lad = vector.add(treedest, vector.new{ x=0, y=current_job["height"], z=0})

--		print("LOC_NE = ", loc_ne)
--		print("FOUND IN LOC NE = ", minetest.get_node(loc_ne).name)

		if minetest.get_node(loc_lad).name == "default:ladder_wood" then
--			print("Removing the top of my ladder")
			self:dig(loc_lad,false)
			coroutine.yield()
		end


		if minetest.get_node(loc_ne).name == treetypefound then
--			print("Removing the NE branch of a tree")
			self:dig(loc_ne,false)
			coroutine.yield()
		end

		if minetest.get_node(loc_nw).name == treetypefound then
--			print("Removing the NW branch of a tree")
			self:dig(loc_nw,false)
			coroutine.yield()
		end

		if minetest.get_node(loc_se).name == treetypefound then
--			print("Removing the SE branch of a tree")
			self:dig(loc_se,false)
			coroutine.yield()
		end

		if minetest.get_node(loc_sw).name == treetypefound then
--			print("Removing the SW branch of a tree")
			self:dig(loc_sw,false)
			coroutine.yield()
		end

		if minetest.get_node(loc_top).name == treetypefound then
--			print("Removing the main trunk of a tree")
			self:dig(loc_top,false)
			coroutine.yield()
		end



		if savefoundtree(self,lumberjacka_marker) == true then
--			print("the tree is still there -- lower the height")
			current_job["height"] = current_job["height"] - 1

			if current_job["height"] > -1 then
				current_job.status = 3
				add_to_joblist(self,current_job)
			else
				current_job.status = 5
				add_to_joblist(self,current_job)
			end	
		else
			-- the tree is gone
			current_job.status = 5
			add_to_joblist(self,current_job)
		end


		--current_job["height"] = 0

		--current_job.status = 1
		--add_to_joblist(self,current_job)
		--add_to_joblist(self,goto_job)	


		--current_job.status = 4
		--add_to_joblist(self,current_job)
--		print("HAVE I MANAGED TO PLACE A LADDER ???")

	elseif current_job.status == 5 then
		-- should wait for the tree to disapate
--		print("Waiting for Tree to drop Saplings")
		current_job.status = 6
		add_to_joblist(self,current_job)

		local waitfor_job = {
			["name"] = "waitfor",
			["status"] = 500
		}
		add_to_joblist(self,waitfor_job)



	elseif current_job.status == 6 then

--			
		-- collect dropped saplings for replanting
		-- TODO FIXME do correctly jo left just to keep a job in the que
--		print("Collecting Saplings")
		
		if self:collect_nearest_item_by_condition(is_sapling, lumberjacka_searching_range) == false then
--			print(" no more saplings found ")
			current_job.status = 7
			add_to_joblist(self,current_job)
		else
--			print(" another sapling found ")
			current_job.status = 6
			add_to_joblist(self,current_job)
		end
--		current_job.status = 6
--		add_to_joblist(self,current_job)
		local waitfor_job = {
			["name"] = "waitfor",
			["status"] = 20
		}
		add_to_joblist(self,waitfor_job)


	elseif current_job.status == 7 then

--		print("Finished Cutting Tree Down")
		--lumberjacka_marker = nil
	end
	



end


-- TODO

local function plant_orchard(self)

	local current_job = get_from_joblist(self,1)

	if current_job.status == 0 then
		current_job.status = 1

		current_job["erow"] = 1
		current_job["nrow"] = 1

		rem_from_joblist(self)
		add_to_joblist(self,current_job)
		print("LUMBERJACK: Going to Orchard")



	elseif current_job.status == 1 then
--		print("LUMBERJACK: Check Next position is within orchard")
--		print("DUMP CJOB:" , dump(current_job))

		if current_job["erow"] * 8 > current_job.x then
			-- too far try next nrow 
			current_job["erow"] = 1
			current_job["nrow"] = current_job["nrow"] + 1
			current_job.status = 1
		rem_from_joblist(self)
			add_to_joblist(self,current_job)
		else

			if current_job["nrow"] * 8 > current_job.x then
				-- we have finished the orchard and left it 
				-- could go home here i guess
				
				local goto_home = {
					["name"] = "gotohome",
					["status"] = 0
				}
				add_to_joblist(self,goto_home)
			else
				-- seems the placement is ok
				current_job.status = 2
		rem_from_joblist(self)
				add_to_joblist(self,current_job)
			end

		end
		


	elseif current_job.status == 2 then
		print("LUMBERJACK: POSITION check it for Tree or Sapling")
--		print("DUMP CJOB:" , dump(current_job))

		local locx = (current_job["buildpos"].x + (current_job["erow"] * 8))-1
		local locz = (current_job["buildpos"].z + (current_job["nrow"] * 8))-1
		local locy = current_job["buildpos"].y
		
--		print("LUMBERJACK: PLACEMENTLOC :",locx,locy,locz)
		local locp = vector.new{ x = locx, y= locy, z= locz}

		-- check for tree
		if minetest.get_node(locp).name == "default:tree" then
			-- needs to be cut down
			current_job.status = 3
		rem_from_joblist(self)
			add_to_joblist(self,current_job)


		-- else check for sapling
		elseif minetest.get_node(locp).name == "default:sapling" then
			-- alls ok -- waiting for this tree to grow, can go to next location
			current_job["erow"] = current_job["erow"] + 1
			current_job.status = 1
		rem_from_joblist(self)
			add_to_joblist(self,current_job)

		else
			-- plant sapling
			-- TODO FIXME This is a fix to clear the orchard
			--current_job["erow"] = current_job["erow"] + 1
			current_job.status = 4 --1 -- should be 4
		rem_from_joblist(self)
			add_to_joblist(self,current_job)
		end


	elseif current_job.status == 3 then

		print("LUMBERJACK: Cutting down tree ")
--		print("DUMP CJOB:" , dump(current_job))
		
		local locx = (current_job["buildpos"].x + (current_job["erow"] * 8))-1
		local locz = (current_job["buildpos"].z + (current_job["nrow"] * 8))-1
		local locy = current_job["buildpos"].y
		local locp = vector.new{ x = locx, y= locy, z= locz}

			-- TODO FIXME This is a fix to clear the orchard
			--current_job["erow"] = current_job["erow"] + 1
			current_job.status = 4 --1 -- should be 4
		rem_from_joblist(self)
		add_to_joblist(self,current_job)

			lumberjacka_marker = vector.round(locp)	
			--add_to_joblist(self,b_job)
			local build_job = {
				["name"] = "chopthis",
				--["buildpos"] = themessage.pos,
				["status"] = 0
			}
			add_to_joblist(self,build_job)



	elseif current_job.status == 4 then
		current_job.status = 5
		rem_from_joblist(self)
		add_to_joblist(self,current_job)
		print("LUMBERJACK: MOVING TO POSITION")
--		print("DUMP CJOB:" , dump(current_job))
		

		local locx = (current_job["buildpos"].x + (current_job["erow"] * 8))-1
		local locz = (current_job["buildpos"].z + (current_job["nrow"] * 8))-1
		local locy = current_job["buildpos"].y
		local locp = vector.new{ x = locx, y= locy, z= locz}


		local mypos = self.object:get_pos()

		local goto_jobb = {
			["name"] = "gotohere",
			["dest"] = func.get_closest_clear_spot(mypos,locp),
			["status"] = 0
		}
		add_to_joblist(self,goto_jobb)



	elseif current_job.status == 5 then

		local locx = (current_job["buildpos"].x + (current_job["erow"] * 8))-1
		local locz = (current_job["buildpos"].z + (current_job["nrow"] * 8))-1
		local locy = current_job["buildpos"].y
		local locp = vector.new{ x = locx, y= locy, z= locz}

		print("LUMBERJACK: Planting Sapling and moving on")
--		print("DUMP CJOB:" , dump(current_job))

				local lnode = {
					["name"] = "default:sapling",
				}
				if minetest.get_node(locp).name ~= "air" then
					-- while for blueberry bushs pick then chop
--					print("Removing a node thats in the way of my sapling")
					self:dig(locp,false)
					coroutine.yield()
				end
				local function is_material(name)
					return name == lnode.name
				end







                -- TODO UPDATE :: goto chest for item








				local wield_stack = self:get_wield_item_stack()
				if is_material(wield_stack:get_name()) or self:has_item_in_main(is_material) then
					if minetest.get_node(locp).name == "air" then
						self:place(lnode,locp)
						coroutine.yield()
--						print("Tying to place node")
					else
--						print("AIR NOT FOUND, DID NOT PLACE NODE")
					end

				else
					local msg = "lumberjacka at " .. minetest.pos_to_string(self.object:get_pos()) .. " doesn't have " .. lnode.name
					if self.owner_name then
						minetest.chat_send_player(self.owner_name,msg)
					else
						print(msg)
					end
					self:set_state_info(("I am currently waiting for somebody to give me some %s."):format(lnode.name))
					coroutine.yield(co_command.pause,"waiting for materials")
				end

		current_job.status = 1
		current_job["erow"] = current_job["erow"] + 1
		rem_from_joblist(self)
		add_to_joblist(self,current_job)

		

	elseif current_job.status == 6 then
		current_job.status = 7
		rem_from_joblist(self)
		add_to_joblist(self,current_job)
--		print("LUMBERJACK: ")
--		print("DUMP CJOB:" , dump(current_job))
		

	elseif current_job.status == 7 then
		current_job.status = 7
		--add_to_joblist(self,current_job)
--		print("LUMBERJACK: STAGE 7 DROPPING JOB")
--		print("DUMP CJOB:" , dump(current_job))
		

	end





--	local xpos = cjob.buildpos.x + cjob.x 
--	local ypos = cjob.buildpos.y + cjob.y 
--	local zpos = cjob.buildpos.z + cjob.z 

--	local bcount = 1
--	found_beds = { }


--  	for iy = cjob.buildpos.y, ypos  do 
--	    	for iz = cjob.buildpos.z, zpos  do 
--			for ix = cjob.buildpos.x, xpos  do 
--
--				local testloc = vector.new{ x= ix, y= iy, z= iz}
				--print("Testing a ", minetest.get_node(testloc).name, " at ", testloc)

--				if minetest.get_node(testloc).name == "beds:bed_bottom" then
					--local sloc = minetest.pos_to_string(testloc)
					--print("Found a ", minetest.get_node(testloc).name, " at ", testloc)
--					found_beds[bcount] = testloc
--					bcount = bcount + 1
--				end

--			end
--		end
--	end







end

local function check_inventory_for_space(self)
	local buildera_inv = self:get_inventory()
	--print("DUMP LUMBERJACK INVENTORY: ", dump(buildera_inv))
	if buildera_inv:room_for_item("main", "default:unknown") then
		return true
	else
		return false
	end
end


local function put_func()
  return true;
end





local function check_for_item(self)

	local current_job = get_from_joblist(self,1)

    print("Lumberjack: check_for_item")
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


        -- TODO FIXME : Dirty fix for wall torch

            if current_job.item == "default:torch_wall" then
                current_job.item = "default:torch"
            end

			print("Lumberjack is going to his chest to look for a ", current_job.item)




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
		print("Lumberjack is opening the chest to look for ", current_job.item)
		local inv = core.get_inventory({ type="node", pos=self.pos_data.chest_pos })
		if inv:is_empty("main") then

			print("Lumberjack: The chest is EMPTY ", current_job.item)
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





--local curre
local function check_time(self)
--	print("")
--	print("LUMBERJACK: Getting TIME")


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

--	print(hour,":", min)
--	print("Day:", days_of_week[the_day])	

-- 0.041666667 = per 1 hour
-- 0.25 = 6AM
-- 0.75 = 9PM
--	wakeup_time = 0.2
--	work_time = 0.24
--	stop_time = 0.76
--	bed_time = 0.805


	-- TODO will have rethink this with the nightworkers

--	print("LUMBERJACK: TOD = ", tod)
--	print("LUMBERJACK: wakeup_time = ", self.wakeup_time)
--	print("LUMBERJACK: work_time = ", self.work_time)
--	print("LUMBERJACK: stop_time = ", self.stop_time)
--	print("LUMBERJACK: bed_time = ", self.bed_time)


--	print("LUMBERJACK: JOBACTION:", self.job_data["jobaction"])
		if get_size_joblist(self) > 0 then 
			for i = 1, get_size_joblist(self) do
			local cjob = get_from_joblist(self,i)
--			print("MAYOR JOB", i, " = ", cjob.name)
			end
		end	if tod > self.bed_time then --and tod < self.wakeup_time then

		-- go to bed time
--		print("LUMBERJACK: Testing bedtime")
		if self.job_data["jobaction"] == 1 then
--			print("LUMBERJACK: BED TIME HAS BEEN SET")
		else
--			print("LUMBERJACK: NOW SETTING BED TIME")
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
--		print("LUMBERJACK: Testing hometime")
		if self.job_data["jobaction"] ~= 2 then
--			print("LUMBERJACK: SETTING HOME TIME")
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
--		print("LUMBERJACK: Testing worktime")
		if self.job_data["jobaction"] ~= 3 then
--			print("LUMBERJACK: SETTING WORK TIME")
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
--		print("LUMBERJACK: Testing uptime")
		if self.job_data["jobaction"] ~= 4 then
--			print("LUMBERJACK: SETTING GETTING UP")
			local uptime_job = {
				["name"] = "uptime",
				["status"] = 0
			}
--			rem_from_joblist(self)
			add_to_joblist(self,uptime_job)
			self.job_data["jobaction"] = 4
		end
	else 
--		print("LUMBERJACK: Testing endbedtime")
		if self.job_data["jobaction"] ~= 1 then
--			print("LUMBERJACK: SETTING ENDBED TIME")
			local bedtime_job = {
				["name"] = "bedtime",
				["status"] = 0
			}
--			rem_from_joblist(self)
			add_to_joblist(self,bedtime_job)
			self.job_data["jobaction"] = 1
		end

	end
	
--			print("")




end


local function on_game_load(self)

			print("LUMBERJACK: STARTING")
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

			local nothing_job = {
				name = "nothing",
				status = 0
				}
			add_to_joblist(self,nothing_job)

--			local newjob = {
--				name = "checkbuilds",
--				status = 0
--				}
--			add_to_joblist(self,newjob)

--[[			local mybl = vector.add(get_job_position(self),lumberjacka_new_start_town_locations[1])
			local myml = vector.add(get_job_position(self),lumberjacka_new_start_town_markers[1])
			local lumberjacka_new_start_meta = minetest.get_meta(myml)

			local special_job = {
				["name"] = "movein1",
				["status"] = 0,
				["buildpos"] = mybl,
				["x"] = lumberjacka_new_start_meta:get_int("maxx"),
				["y"] = lumberjacka_new_start_meta:get_int("maxy"),
				["z"] = lumberjacka_new_start_meta:get_int("maxz"),
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


			lumberjacka_new_start = false

end




local function do_uptime(self)
print("LUMBERJACK: DO UPTIME")
-- get up, go to home, sit down 

	lumberjack_tending_orchard = false
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
print("LUMBERJACK: DO WORKTIME")
--	local dest = get_job_position(self)
--	local goto_job = {
--		["name"] = "gotohere",
--		["dest"] = dest,
--		["status"] = 0
--	}

--	local cbuilds_job = {
--		["name"] = "checkbuilds",
--		["status"] = 0
--	}
--

	rem_from_joblist(self)
--	add_to_joblist(self,cbuilds_job)

--	add_to_joblist(self,goto_job)

	--dositups
	-- do work if there is anything to do 
	-- or was working before continue
	-- should just stay put
	self:set_displayed_action("Ready for Work")

end

local function do_hometime(self)
print("LUMBERJACK: DO HOMETIME")
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
print("LUMBERJACK: DO BEDTIME")

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


















local slow_update_count = 100
local under_attack = false










simple_working_villages.register_job("simple_working_villages:job_lumberjack_a", {
	description      = "LumberJack A (simple_working_villages)",
	long_description = "I look for any Tree trunks around and chop them down.\
I might also chop down a house. Don't get angry please I'm not the best at my job.\
When I find a sappling I'll plant it on some soil near a bright place so a new tree can grow from it.",
	inventory_image  = "default_paper.png^working_villages_woodcutter.png",
	jobfunc = function(self)

		if use_vh1 then VH1.update_bar(self.object, self.object:get_hp()) end




-- ONCE ONLY ON CREATE
		if self.job_data["isstarted"] == nil then
			self.job_data["isstarted"] = true		-- to make sure this only runs once
            self.pos_data["job_pos"] = self.object:get_pos() 
        end




-- ONLY ON GAME LOAD AND CONTINUE
		if lumberjacka_new_start then
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


		--print("should check messages")
		check_lumberjacka_message(self)




		if check_inventory_for_space(self) == false then
			--self:handle_chest(nil, nil)
			print("INVENTORY SPACE FULL")
			self.job_data.manipulated_chest = false;
			self:handle_chest(nil, put_func)
		else
			--print("INVENTORY SPACE OK")
		end


 --print("walk speed = ", self.walk_speed)


		local current_job = get_from_joblist(self,1)

		if current_job.name == "morning" then 				--lookdirection job
			do_morning_routine(self)				

		elseif current_job.name == "nothing" then
			--print("Doing Nothing")

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

		elseif current_job.name == "checkforitem" then
			check_for_item(self)

--		elseif current_job.name == "checkmybed" then
--			check_my_bed(self)

		elseif current_job.name == "sitdown" then
			sit_down(self)

		elseif current_job.name == "laydown" then
			lay_down(self)

		elseif current_job.name == "dositups" then
			do_situps(self)

--		elseif current_job.name == "walknorth" then
--			walk_north(self)

		elseif current_job.name == "beenpunched" then
			been_punched(self)

--		elseif current_job.name == "hirebuilder" then
--			hire_a_builder(self)

--		elseif current_job.name == "waitforbuildok" then
--			wait_for_lumberjacka_ok(self)

--		elseif current_job.name == "waitforbuildfinished" then
--			waitforbuildtofinish(self)

		elseif current_job.name == "gotohome" then
			goto_myhome(self)

--		elseif current_job.name == "movein1" then
--			move_in_1(self)

		elseif current_job.name == "plantorchard" then 
			plant_orchard(self)

		elseif current_job.name == "checkname" then
			check_my_name(self)

		elseif current_job.name == "chopthis" then
			chop_this(self)

--		elseif current_job.name == "startbuild" then
--			start_building(self)

--		elseif current_job.name == "continuebuild" then
--			continue_building(self)

--		elseif current_job.name == "signoffbuild" then	
--			signoff_building(self)

		elseif current_job.name == "checkjobpos" then
			check_my_jobpos(self)

--		elseif current_job.name == "phonebuilderbuild" then
--			continue_building(self)

		elseif current_job.name == "waitfor" then
			wait_for_time(self) 

--		elseif current_job.name == "checkbuildsite" then 
--			check_build_site(self) 

--		elseif current_job.name == "checkbuilds" then
--			check_for_buildings(self)
			--print("UP TO CHECK BUILDS")
			--check_for_buildings(self)
			--coroutine.yield(co_command.pause,"Check Builds\n")
		elseif current_job.name == "gotohere" then
			auto_go(self,false)

		else
			-- ERROR HERE = UNKNOWN JOB
			print("DUMP UNKNOWN JOB = ", dump(current_job.name))
			coroutine.yield(co_command.pause,"ERROR FOUND A JOB I DO NOT KNOW\n")
		end

end
})
