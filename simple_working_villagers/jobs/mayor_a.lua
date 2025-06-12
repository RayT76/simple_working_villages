local func = simple_working_villages.require("jobs/util")
local build = simple_working_villages.require("building")
local co_command = simple_working_villages.require("job_coroutines").commands
local use_vh1 = minetest.get_modpath("visual_harm_1ndicators")
local pathfinder = simple_working_villages.require("pathfinder")


local tree_types = {
	[1] = "default:pine_tree",
	[2] = "default:aspen_tree",
	[3] = "default:tree",
}



-- hired working village NPC data
local mayora_buildera_job = "simple_working_villages:job_builder_a"
local mayora_buildera_npc = "simple_working_villages:villager_male_builder_a"

-- this will be the newest format for each NPC
local mayora_buildera = {
    ["npc"] = "simple_working_villages:villager_male_builder_a",
    ["job"] = "simple_working_villages:job_builder_a",
}

local mayora_lumberjacka_job = "simple_working_villages:job_lumberjack_a"
local mayora_lumberjacka_npc = "simple_working_villages:villager_male_lumberjack_a"
local mayora_minera_job = "simple_working_villages:job_miner_a"
local mayora_minera_npc = "simple_working_villages:villager_male_miner_a"
local mayora_farmera_job = "simple_working_villages:job_farmer_a"
local mayora_farmera_npc = "simple_working_villages:villager_male_farmer_a"
local mayora_medica_job = "simple_working_villages:job_medic"
local mayora_medica_npc = "simple_working_villages:villager_male_medic"

local mayora_gardenera_npc = "simple_working_villages:villager_male_gardener_a"
local mayora_gardenera_job = "simple_working_villages:job_grass_cutter"

local mayora_veta_npc = "simple_working_villages:villager_male_vet"
local mayora_veta_job = "simple_working_villages:job_vet"

local mayora_firemana_npc = "simple_working_villages:villager_male_fireman"
local mayora_firemana_job = "simple_working_villages:job_fireman"








local mayora_start_bed_loc = vector.new{ x=10, y=0, z=20 }
local mayora_start_bedtop_loc = vector.new{ x=10, y=0, z=21 }
local mayora_start_chest_loc = vector.new{ x=11, y=0, z=21 }
local mayora_start_fire_loc = vector.new{ x=13, y=0, z=4 }


local drop_off_point_1 = vector.new{ x=16, y=0, z=4 }  --  ??????


local mayora_start_meet_loc = {
	[0] = vector.new{ x=-2, y=0, z=4 }, -- Mayor position North
	[1] = vector.new{ x=2, y=0, z=4 }, -- NWW

	[2] = vector.new{ x=4, y=0, z=2 }, -- SW
	[3] = vector.new{ x=4, y=0, z=0 }, -- S
	[4] = vector.new{ x=4, y=0, z=-2 }, -- SE

	[5] = vector.new{ x=-2, y=0, z=-4 }, -- E
	[6] = vector.new{ x=-0, y=0, z=-4 }, -- NE 
	[7] = vector.new{ x=2, y=0, z=-4 }, -- SW

	[8] = vector.new{ x=-4, y=0, z=2 }, -- 
	[9] = vector.new{ x=-4, y=0, z=0 }, -- 
	[10] = vector.new{ x=-4, y=0, z=-2 }, -- 


}



-- game locations for the mayors bed and chest
local mayora_bed_loc = nil
local mayora_chest_loc = nil
local mayora_fire_loc = nil




local mayora_marker = "simple_working_villages:building_marker"








-- TODO FIXME TOWN PLANS 

-- new variable "TYPE" to handle jobs like 

--  Task    =  ???
--  NewHire
--  Build
--  Movein


local town_data = {

    -- start off by placing town marker, bed and chest

    -- hire a builder, lumberjack and gardener

--	[0] = {
--        ["type"] = "hire",
--		["marker"] = { x = 0, y = 0, z = 0},
--		["npc"] = "Town Center Compound",
--		["job"] = "center_compound_1.we",
--		["location"] = { x = -2, y = 0, z = -2},
--		["clear"] = true
--	},

--	[0] = {
--        ["type"] = "movein",
--		["npc"] = "Town Center Compound",
--		["job"] = "center_compound_1.we",
--		["bednum"] = { x = 0, y = 0, z = 0},
--		["chestnum"] = { x = -2, y = 0, z = -2},
--		["meetloc?"] = true
--	},

	[1] = {
        ["type"] = "build",
		["name"] = "Town Center Compound",
		["scheme"] = "center_compound_1.we",
		["marker"] = { x = 0, y = 0, z = 0},
		["location"] = { x = -2, y = 0, z = -2},
		["clear"] = true
	},

	[2] = {
		["name"] = "Orchard",
		["scheme"] = "orchard_a.we",
		["marker"] = { x = 1, y = 0, z = 0},
		["location"] = { x = 36, y = 0, z = -2},
		["clear"] = true
	},

	[3] = {
		["name"] = "Orchard NorthFence",
		["scheme"] = "orchard_c.we",
		["marker"] = { x = 2, y = 0, z = 0},
		["location"] = { x = 37, y = 0, z = 36},
		--["location"] = { x = -20, y = -1, z = -2},
		["clear"] = true
	},

	[4] = {
		["name"] = "Orchard SouthFence",
		["scheme"] = "orchard_b.we",
		["marker"] = { x = 3, y = 0, z = 0},
		["location"] = { x = 37, y = 0, z = -2},
		--["location"] = { x = -20, y = -1, z = -2},
		["clear"] = true
	},

	[5] = { -- should be front fence to town center Compound
		["name"] = "Owners House",
		["scheme"] = "building_workshop_2.we",
		--["scheme"] = "building_owners_house_1E-1.we",
		["marker"] = { x = 4, y = 0, z = 0},
		["location"] = { x = -22, y = -1, z = -2},
		--["location"] = { x = -20, y = -1, z = -2},
		["clear"] = true
	},

	[6] = {
		["name"] = "Builders House",
		--["scheme"] = "building_wood_2.we",
		["scheme"] = "building_wood_1.we",
		--["scheme"] = "standard_plot_marker.we",
		["marker"] = { x = 5, y = 0, z = 0},
		["location"] = { x = -2, y = 0, z = -35},
		["clear"] = true
	},


	[7] = {
		["name"] = "LumberJacks Hut",
		["scheme"] = "building_wood_1.we",
		--["scheme"] = "standard_plot_marker.we",
		["marker"] = { x = 6, y = 0, z = 0},
		["location"] = { x = -22, y = 0, z = -35},
		["clear"] = true
	},

	[8] = {
		["name"] = "Farmers House",
		["scheme"] = "building_wood_1.we",
		--["scheme"] = "standard_plot_marker.we",
		["marker"] = { x = 7, y = 0, z = 0},
		["location"] = { x = -42, y = 0, z = -35},
		["clear"] = true
	},

	[9] = {
		["name"] = "Field1",
		["scheme"] = "building_field_1.we",
		--["scheme"] = "standard_plot_marker.we",
		["marker"] = { x = 8, y = 0, z = 0},
		["location"] = { x = 18, y = -1, z = -35},
		["clear"] = true
	},

	[10] = {
		["name"] = "Miners House",
		["scheme"] = "building_wood_1.we",
		--["scheme"] = "standard_plot_marker.we",
		["marker"] = { x = 0, y = 0, z = 1},
		["location"] = { x = 42, y = 0, z = -35},
		["clear"] = true
	},

	[11] = {
		["name"] = "PitMine",
		["scheme"] = "building_pitmine.we",
		--["scheme"] = "standard_plot_marker.we",
		["marker"] = { x = 1, y = 0, z = 1},
		["location"] = { x = 37, y = 0, z = 42},
		["clear"] = true
	},

	[12] = {
		["name"] = "WaterWell",
		["scheme"] = "building_well_1.we",
		--["scheme"] = "standard_plot_marker.we",
		["marker"] = { x = 2, y = 0, z = 1},
		["location"] = { x = 0, y = -1, z = 28},
		["clear"] = true
	},

	[13] = {   -- FIXME TODO
		["name"] = "Gdeners House test",
		--["scheme"] = "building_wood_1S.we",
		["scheme"] = "standard_plot_marker.we",
		["marker"] = { x = 3, y = 0, z = 1},
		["location"] = { x = 11, y = 0, z = 46},
		["clear"] = true
	},

	[14] = {
		["name"] = "Gardeners House",
		["scheme"] = "building_wood_1S.we",
		--["scheme"] = "standard_plot_marker.we",
		["marker"] = { x = 4, y = 0, z = 1},
		["location"] = { x = 11, y = 0, z = 46},
		["clear"] = true
	},

	[15] = {
		["name"] = "Builders Upgrade 1",
		["scheme"] = "building_wood_2.we",
		--["scheme"] = "building_owners_house_1E-1.we",
		--["scheme"] = "standard_plot_marker.we",
		["marker"] = { x = 5, y = 0, z = 1},
		["location"] = { x = -6, y = -1, z = -35},
		["clear"] = true
	},

	[16] = {
		["name"] = "Builders Upgrade 2",
		["scheme"] = "building_wood_3.we",
		--["scheme"] = "building_owners_house_1E-1.we",
		--["scheme"] = "standard_plot_marker.we",
		["marker"] = { x = 6, y = 0, z = 1},
		["location"] = { x = -6, y = -1, z = -35},
		["clear"] = true
	},

	[17] = {
		["name"] = "Medics House",
		["scheme"] = "building_wood_1S.we",
		--["scheme"] = "standard_plot_marker.we",
		["marker"] = { x = 7, y = 0, z = 1},
		["location"] = { x = -9, y = 0, z = 46},
		["clear"] = true
	},

	[18] = {
		["name"] = "Vets House",
		["scheme"] = "building_wood_1S.we",
		--["scheme"] = "standard_plot_marker.we",
		["marker"] = { x = 8, y = 0, z = 1},
		["location"] = { x = -29, y = 0, z = 46},
		["clear"] = true
	},

	[19] = {
		["name"] = "Firemans House",
		["scheme"] = "building_wood_1S.we",
		--["scheme"] = "standard_plot_marker.we",
		["marker"] = { x = 0, y = 0, z = 2},
		["location"] = { x = -49, y = 0, z = 46},
		["clear"] = true
	},

	[20] = { -- should be front fence to town center Compound
		["name"] = "Builders Upgrade 3",
		["scheme"] = "building_wood_4.we",
		--["scheme"] = "building_owners_house_1E-1.we",
		--["scheme"] = "standard_plot_marker.we",
		["marker"] = { x = 1, y = 0, z = 2},
		["location"] = { x = -6, y = 0, z = -35},
		["clear"] = true
	},

	[21] = { -- should be front fence to town center Compound
		["name"] = "Workshop markers",
		--["scheme"] = "building_workshop_2.we",
		["scheme"] = "standard_plot_marker.we",
		["marker"] = { x = 2, y = 0, z = 2},
		["location"] = { x = -22, y = -1, z = 23},
		["clear"] = true
	},





	[22] = {
		["name"] = "Lumberjacks Upgrade 1",
		["scheme"] = "building_wood_2.we",
		--["scheme"] = "building_owners_house_1E-1.we",
		--["scheme"] = "standard_plot_marker.we",
		["marker"] = { x = 3, y = 0, z = 2},
		["location"] = { x = -26, y = -1, z = -35},
		["clear"] = true
	},

	[23] = {
		["name"] = "Farmers Upgrade 1",
		["scheme"] = "building_wood_2.we",
		--["scheme"] = "building_owners_house_1E-1.we",
		--["scheme"] = "standard_plot_marker.we",
		["marker"] = { x = 4, y = 0, z = 2},
		["location"] = { x = -46, y = -1, z = -35},
		["clear"] = true
	},

	[24] = {
		["name"] = "Miners Upgrade 1",
		["scheme"] = "building_wood_2.we",
		--["scheme"] = "building_owners_house_1E-1.we",
		--["scheme"] = "standard_plot_marker.we",
		["marker"] = { x = 5, y = 0, z = 2},
		["location"] = { x = 38, y = -1, z = -35},
		["clear"] = true
	},



	[25] = {
		["name"] = "Lumberjacks Upgrade 2",
		["scheme"] = "building_wood_3.we",
		--["scheme"] = "building_owners_house_1E-1.we",
		--["scheme"] = "standard_plot_marker.we",
		["marker"] = { x = 6, y = 0, z = 2},
		["location"] = { x = -26, y = -1, z = -35},
		["clear"] = true
	},

	[26] = {
		["name"] = "Farmers Upgrade 2",
		["scheme"] = "building_wood_3.we",
		--["scheme"] = "building_owners_house_1E-1.we",
		--["scheme"] = "standard_plot_marker.we",
		["marker"] = { x = 7, y = 0, z = 2},
		["location"] = { x = -46, y = -1, z = -35},
		["clear"] = true
	},

	[27] = {
		["name"] = "Miners Upgrade 2",
		["scheme"] = "building_wood_3.we",
		--["scheme"] = "building_owners_house_1E-1.we",
		--["scheme"] = "standard_plot_marker.we",
		["marker"] = { x = 8, y = 0, z = 2},
		["location"] = { x = 38, y = -1, z = -35},
		["clear"] = true
	},




	[28] = {
		["name"] = "Lumberjacks Upgrade 3",
		["scheme"] = "building_wood_4.we",
		--["scheme"] = "building_owners_house_1E-1.we",
		--["scheme"] = "standard_plot_marker.we",
		["marker"] = { x = 0, y = 0, z = 3},
		["location"] = { x = -26, y = 0, z = -35},
		["clear"] = true
	},

	[29] = {
		["name"] = "Farmers Upgrade 3",
		["scheme"] = "building_wood_4.we",
		--["scheme"] = "building_owners_house_1E-1.we",
		--["scheme"] = "standard_plot_marker.we",
		["marker"] = { x = 1, y = 0, z = 3},
		["location"] = { x = -46, y = 0, z = -35},
		["clear"] = true
	},

	[30] = {
		["name"] = "Miners Upgrade 3",
		["scheme"] = "building_wood_4.we",
		--["scheme"] = "building_owners_house_1E-1.we",
		--["scheme"] = "standard_plot_marker.we",
		["marker"] = { x = 2, y = 0, z = 3},
		["location"] = { x = 38, y = 0, z = -35},
		["clear"] = true
	},



[[--	[15] = {
		["name"] = "Main Road (East/West)",
		["scheme"] = "building_wood_4.we",
		--["scheme"] = "building_owners_house_1E-1.we",
		--["scheme"] = "standard_plot_marker.we",
		["marker"] = { x = 5, y = 0, z = 1},
		["location"] = { x = 38, y = 0, z = -35},
		["clear"] = true
	},]]



}




local mayora_town_names = {
	[1] = "Town_Center", 			-- then move in builder and lumberjack and plant collector
	[2] = "Owners House",
	[3] = "Orchard",
	[4] = "Orchard North Fence",
	[5] = "Orchard South Fence",
	[6] = "Builders House",
	[7] = "Miners House",

	[8] = "Lumberjacks House",
	[9] = "Gatherers House",
	[10] = "Farmers House",
	[11] = "Field 1",
	[12] = "House South",
	[13] = "Owners Workshop",
	[14] = "House South",

	[15] = "PitMine",
	[16] = "Fence",
	[17] = "Fence",
	[18] = "Fence",
	[19] = "Fence",
	[20] = "Fence East side Center",
	[21] = "standard plot marker NCenter",

	[22] = "standard plot marker NECenter",
	[23] = "standard plot marker NNW+Center",
	[24] = "standard plot marker bonetest",
	[25] = "standard plot marker N Workshop",
	[26] = "standard plot marker 2N Workshop",
	[27] = "standard plot marker 2NE Workshop",
	[28] = "standard plot marker 2NW Workshop",
	[29] = "lumberjacks plot marker",
	[30] = "standard plot marker 2NW Workshop",
	[31] = "standard plot marker N2W Workshop",
	[32] = "standard plot marker 2N2W Workshop",
	[33] = "standard plot marker N2W Workshop",
	[34] = "standard plot marker 2N2W Workshop",
	[35] = "standard plot marker NorthRow 2E Center",
	[36] = "standard plot marker NorthRow 3E Center",
	[37] = "standard plot marker NorthRow 3ES Center",
	[38] = "standard plot marker NorthRow 3ES Center",
	[39] = "standard plot marker Center SE",
	[40] = "standard plot marker Center SW",
	
	[92] = "Builders Workshop4",
	[92] = "PitMine",
	[92] = "Town_Center_2",
	[93] = "House 1 Floor",
	[94] = "House 2 Floor",
	[95] = "House 3 Floor",
	[96] = "House 1 Path",
	[97] = "House 2 Path",
	[98] = "House 3 Path",
	[99] = "Workshop Upgrade",
	[90] = "House 1 Fence",
	[91] = "House 2 Fence",
	[92] = "House 3 Fence",
	[93] = "House 4 Fence",
	[94] = "Field",
	[95] = "Water Well",
	[96] = "SheepPen",
	[97] = "SheepPen",
}

local mayora_town_schems = {
	[1] = "center_compound_1.we", 		-- build start camp then move in builder, lumberjack and mayor
	[2] = "building_workshop_1.we",		-- start to build orchard then get lumberjack to work
	[3] = "orchard_a.we",			-- build users house
	[4] = "orchard_b.we",			-- build users house
	[5] = "orchard_c.we",			-- build users house
	[6] = "building_wood_1.we",		-- build users house
	[7] = "building_wood_1.we",
	[8] = "building_wood_1.we",
	[9] = "building_wood_1.we",
	[10] = "building_wood_1.we",

	[11] = "building_field_1.we",
	[12] = "building_wood_1S.we",
	[13] = "building_workshop_B.we",
	[14] = "building_wood_1S.we",
	[15] = "building_pitmine.we",
	[16] = "building_wood_4.we",
	[17] = "building_wood_4.we",
	[18] = "building_wood_4.we",
	[19] = "building_wood_4.we",
	[20] = "building_wood_4.we",
	[21] = "standard_plot_marker.we",
	[22] = "standard_plot_marker.we",
	[23] = "standard_plot_marker.we",
	[24] = "bonetest.we",
	[25] = "standard_plot_marker.we",
	[26] = "standard_plot_marker.we",
	[27] = "standard_plot_marker.we",
	[28] = "standard_plot_marker.we",
	[29] = "standard_plot_marker.we",
	[30] = "standard_plot_marker.we",
	[31] = "standard_plot_marker.we",
	[32] = "standard_plot_marker.we",
	[33] = "standard_plot_marker.we",
	[34] = "standard_plot_marker.we",
	[35] = "standard_plot_marker.we",
	[36] = "standard_plot_marker.we",
	[37] = "standard_plot_marker.we",
	[38] = "standard_plot_marker.we",
	[39] = "standard_plot_marker.we",
	[40] = "standard_plot_marker.we",
	
	[93] = "gravel_road (EtoW).we",
	[93] = "building_workshop_2.we",
	[92] = "building_workshop_1.we",
	[92] = "building_pitmine_1.we", 	-- FIXME needs to be a mine
	[92] = "building_wood_start.we",
	[93] = "building_wood_2.we",
	[94] = "building_wood_2.we",
	[95] = "building_wood_2.we",
	[96] = "building_wood_3.we",
	[97] = "building_wood_3.we",
	[98] = "building_wood_3.we",
	[99] = "building_workshop_2.we",
	[90] = "building_wood_4.we",
	[91] = "building_wood_4.we",
	[92] = "building_wood_4.we",
	[93] = "building_wood_4.we",
	[94] = "building_field_1.we",
	[95] = "building_well_1.we",
	[96] = "building_wood_4.we",
	[97] = "building_wood_4.we",
}




-- variable set set to check for a game load start
local mayora_new_start = true
--local mayora_joblist = {}	

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

local function reset_joblist(self)

    self.job_data.joblist = {}
	local nothing_job = {
		name = "nothing",
		status = 0
		}
	add_to_joblist(self,nothing_job)

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





-- TODO OLD VARIABLES TO BE UPDATED / REPLACED OR DELETED

local mayora_buildera = nil		-- tells if there is a builder on hand





--local mayora_marker = "simple_working_villages:building_marker"
local mayora_is_morning = true		-- tells if it is the start of the day
local mayora_buildera = nil		-- tells if there is a builder on hand
local mayora_building_count = 0		-- current town building job number
local mayora_job_status = 0	-- current status of current building job
					-- 0 = no building ready 
					-- 1 = building started
					-- 2 = building is finished
					-- 3 = finish and moveon
local mayora_path_data = nil	-- the mayors private path_data
local mayora_searching_range = {x = 20, y = 5, z = 20}
local mayora_searching_distance = 500
local mayora_found_plant_target = nil
local mayora_builder_here = false
local mayora_buildera_message = nil
local mayora_is_building = false



-- TODO MESSAGING MESSAGES TO BE UPDATED

local mayora_callingmessage = 	{ 
			msg = "Calling Builder A",
			}
local mayora_callingreply = 	{ 
			msg = "Builder A OK",
			}
local mayora_jobreply = 	{ 
			msg = "Builder Finished",
			}
local mayora_comemessage = 	{ 
			msg = "Come Here",
			pos = "",
			}
local mayora_buildmessage = 	{ 
			msg = "Build This",
			pos = "",
			}
local mayora_moveinmessage = 	{ 
			msg = "Movein Here",
			}


local farmer_moveinmessage = 	{ 
			msg = "Movein Here",
			}
local vet_moveinmessage = 	{ 
			msg = "Movein Here",
			}
local medic_moveinmessage = 	{ 
			msg = "Movein Here",
			}
local gardener_moveinmessage = 	{ 
			msg = "Movein Here",
			}
local fireman_moveinmessage = 	{ 
			msg = "Movein Here",
			}






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

local miner_moveinmessage = 	{ 
			msg = "Miner Movein Here",
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
	local buildera_myd = mydest
	mayora_path_data = pathfinder.plot_movement_to_pos(mypos, buildera_myd, false)
	if mayora_path_data == nil then
		-- TODO should indicate who cannot find a path
		--print(" No Path Found to ", buildera_myd)
		self.job_data["pathdata"] = {}
		self.job_data["pathstep"] = -1
		return false
	elseif mayora_path_data == false then
		--print(" IT SEEMS PATHFINDER IS BUSY-- I WILL HAVE TO WAIT MY TURN")
		self.job_data["pathdata"] = {}
		self.job_data["pathstep"] = -1
		return nil 
	else
		--print(" PATHFINDER PLANNED OK")
		self.job_data["pathdata"] = mayora_path_data
		self.job_data["pathstep"] = 1
		return true
		
	end
end





local function go_on_path(self, isrunning)
	local pdata = self.job_data["pathdata"]
	--print("DUMPPATH:", dump(pdata))
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

 -- FIXME SOMETIMES THE NPC'S DANCE TOGETHER -- TODO RECHECK AND MAKE SURE THERE ARE NO SYMETRICAL MOVEMENTS

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
	local current_job = get_from_joblist(self,1)
	local mypos = self.object:get_pos()
	local mydest = current_job["dest"]
	local mystatus = current_job["status"]
	if mystatus == 0 then
		if current_job.dest == nil then
			print("AUTOGO NO DESTINATION")
			rem_from_joblist(self)
			return true
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
			return true
		end
		-- TODO needs 3 types of goto function
		-- 1 = go to exact square
		-- 2 = go to square next to
		-- 3 = go to clostest you can within reason
		local pathres = plan_to_next_to(mypos,mydest,self)
		if pathres == true then
			self:set_animation(simple_working_villages.animation_frames.WALK)
			current_job["status"] = 1
			rem_from_joblist(self)
			add_to_joblist(self,current_job)
			self:set_animation(simple_working_villages.animation_frames.WALK)
			return nil
		elseif pathres == false then
			print("NO PATH FOUND")
			rem_from_joblist(self)
			return true
		elseif pathres == nil then
			print("PATHFINDER BUSY ? wait for it")
			return nil
		end
	elseif mystatus == 1 then
		self:handle_goto_obstacles(true)
		local cani = self:get_animation()
		if cani ~= nil and cani ~= "WALK" then
			self:set_animation(simple_working_villages.animation_frames.WALK)
		end
		if current_job["currloc"] == nil then
		 	current_job["currloc"] = vector.round(mypos)
		 	current_job["count"] = 0
			rem_from_joblist(self)
			add_to_joblist(self,current_job)
		else
			if current_job["currloc"] == vector.round(mypos) then
				current_job["count"] = current_job["count"] + 1
				rem_from_joblist(self)
				add_to_joblist(self,current_job)
			else
				if current_job["count"] > 100 then 
				 	current_job["status"] = 0
				 	current_job["currloc"] = nil
				 	current_job["count"] = nil
					rem_from_joblist(self)
					add_to_joblist(self,current_job)
					return nil
				else
				 	current_job["currloc"] = vector.round(mypos)
				 	current_job["count"] = 0
					rem_from_joblist(self)
					add_to_joblist(self,current_job)
				end
			end	
		end
		local varb = check_for_blocking_luaentitys(self)
		if varb ~= nil then
			current_job["status"] = 0
			rem_from_joblist(self)
			add_to_joblist(self,current_job)
			
			plot_around(self,varb)
		end

		-- FIXME OVERRIDE TO ALWAYS RUN REVERT FOR NORMAL
		--local goonres = go_on_path(self,isrunning)
		local goonres = go_on_path(self,true)
		if goonres == true then
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
	--	print("ADDING JOBS TO LIST")
		current_job.status = 1
		rem_from_joblist(self)
		add_to_joblist(self,current_job)
		local cbuilds_job = {
			["name"] = "checkbuilds",
			["status"] = 0
		}
		add_to_joblist(self,cbuilds_job)
--		if get_job_position() ~= nil then
--			local cgoto_job = {
--				["name"] = "gotohere",
--				["dest"] = get_job_position(self),
--				["status"] = 0
--			}
--			add_to_joblist(self,cgoto_job)
--		end
		local cjobpos_job = {
			["name"] = "checkjobpos",
			["status"] = 0
		}
		add_to_joblist(self,cjobpos_job)

		local cname_job = {
			["name"] = "checkname",
			["status"] = 0
		}
		add_to_joblist(self,cname_job)

		local bedcheck_job = {
			["name"] = "checkmybed",
			["status"] = 0
		}
		add_to_joblist(self,bedcheck_job)

		local chestcheck_job = {
			["name"] = "checkmychest",
			["status"] = 0
		}
		add_to_joblist(self,chestcheck_job)

	elseif current_job.status == 1 then
		--should be uptodate
		print("SHOULD BE UPTO DATE WITH MORNING ROUTINE ")				
		rem_from_joblist(self)

	end
end


local function wait_for_buildera_ok(self)
	local current_job = get_from_joblist(self,1)
	rem_from_joblist(self)
--	print("DO wait_for_buildera_ok JOB ", current_job.status)				
	if current_job.status > 0 then
		-- keep checking
		local themessage = nil
		if func.get_builder_a_message() ~= nil then 
			themessage = func.get_builder_a_message()
			if themessage.msg == mayora_callingreply.msg then
				return true
			elseif themessage.msg == mayora_jobreply.msg then
				return true	
			else
				current_job.status = current_job.status - 1
				add_to_joblist(self,current_job)
			end
		end 
	else
		-- no answer from builder
--		local notify_job = {
--			["name"] = "notify",
--			["status"] = 0,
--			["message"] = " a little worried\nThere is no Answer from the builder !!\nCould you check on him for me?\n"
--		}
--		add_to_joblist(self,notify_job)
	end
end

-- TODO not needed now ? 
local wfba_timeout = 800
local function wait_for_buildera_finished()
	local answer = false
	if wfba_timeout == 0 then 
		return false 
	end
	if func.get_builder_a_message() ~= nil then 
		local themessage = nil
		themessage = func.get_builder_a_message()
		if themessage.msg == mayora_jobreply.msg then
			func.set_builder_a_message(nil)
			return true
		else
		wfba_timeout = wfba_timeout - 1
		end
	end
	return nil
end


local function mayora_plantonextto(mypos,mydest)
	local buildera_myd = func.get_closest_clear_spot(mypos,mydest)	
	if buildera_myd == false or buildera_myd == nil then
		buildera_myd = mydest
	end
	mayora_path_data = pathfinder.plot_movement_to_pos(mypos, buildera_myd, false)
	if mayora_path_data == nil then
		-- TODO should indicate who cannot find a path
		return nil
	elseif mayora_path_data == false then
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
			mayora_plantonextto(curr_loc,epos)
			self:go_to_the(mayora_path_data)
		else
			return true
		end
		ma_tries = ma_tries - 1
		thedist = vector.distance(spos,epos)
	end
	return false
end









local found_beds = { }
local function find_beds_in_build(self, cjob)

	print("Looking for beds in new build")
--	print("DUMP CJOB:" , dump(cjob))

	local xpos = cjob.buildpos.x + cjob.x 
	local ypos = cjob.buildpos.y + cjob.y 
	local zpos = cjob.buildpos.z + cjob.z 

	local bcount = 1
	found_beds = { }


   	for iy = cjob.buildpos.y, ypos  do 
	    	for iz = cjob.buildpos.z, zpos  do 
			for ix = cjob.buildpos.x, xpos  do 

				local testloc = vector.new{ x= ix, y= iy, z= iz}
				--print("Testing a ", minetest.get_node(testloc).name, " at ", testloc)

				if minetest.get_node(testloc).name == "beds:bed_bottom" then
					--local sloc = minetest.pos_to_string(testloc)
					--print("Found a ", minetest.get_node(testloc).name, " at ", testloc)
					found_beds[bcount] = testloc
					bcount = bcount + 1
				end

			end
		end
	end
end


local found_chests = { }
local function find_chests_in_build(self, cjob)

	print("Looking to look for Chests in new build")
--	print("DUMP CJOB:" , dump(cjob))

	local xpos = cjob.buildpos.x + cjob.x 
	local ypos = cjob.buildpos.y + cjob.y 
	local zpos = cjob.buildpos.z + cjob.z 

	local bcount = 1
	found_chests = { }


-- FIXME use find nodes in area instead








   	for iy = cjob.buildpos.y, ypos  do 
	    	for iz = cjob.buildpos.z, zpos  do 
			for ix = cjob.buildpos.x, xpos  do 

				local testloc = vector.new{ x= ix, y= iy, z= iz}
				if minetest.get_node(testloc).name == "default:chest" then
					local sloc = minetest.pos_to_string(testloc)
					--print("Found a ", minetest.get_node(testloc).name, " at ", testloc)
					found_chests[bcount] = testloc
					bcount = bcount + 1
				end

			end
		end
	end
end






--FIX ME BEFORE REMOVING THIS
--
--local town_data = {
--	[1] = {
--		["name"] = "Town Center Compound",
--		["scheme"] = "center_compound_1.we",
--		["marker"] = { x = 0, y = 0, z = 0},
--		["location"] = { x = -2, y = 0, z = -2},
--		["clear"] = true
--	},



-- MOVEIN FUNCTIONS

local function move_in_builder(self, buildnum)

	--if self.job_data["builder_movedin"] ~= true then
		print("Moving Builder into House")
		local mybl = vector.add(get_job_position(self),town_data[buildnum].location)
		mayora_fire_loc = vector.add(get_job_position(self),mayora_start_fire_loc)
		local myml = vector.add(get_job_position(self),town_data[buildnum].marker)
		local mayora_meta = minetest.get_meta(myml)
		local special_job = {
			["name"] = "movein1",
			["status"] = 0,
			["buildpos"] = mybl,
			["x"] = mayora_meta:get_int("maxx"),
			["y"] = mayora_meta:get_int("maxy"),
			["z"] = mayora_meta:get_int("maxz"),
		}
		print("MAYORA: I AM FINDING BEDS")
		find_beds_in_build(self, special_job)
		for key, val in pairs(found_beds) do
			print("Bed found at ", val)
		end
		print("MAYORA: I AM FINDING CHESTS")
		find_chests_in_build(self, special_job)
		for key, val in pairs(found_chests) do
			print("Chest found at ", val)
		end		

		local bposb = vector.new(found_beds[1])
		local cposb = vector.new(found_chests[1])

		if mayora_fire_loc == nil then
			print("ERRRROOORRRRR   FIRE LOCATION = NIL !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
		end

		local hposb = vector.add(mayora_fire_loc,mayora_start_meet_loc[1])

		mayora_moveinmessage.bed_pos = bposb
		mayora_moveinmessage.chest_pos = cposb
		mayora_moveinmessage.home_pos = hposb

		print("MAYORA: BUILDER MOVEIN MESSAGE SENT.")--= ", dump(mayora_moveinmessage))
		func.set_builder_a_message(mayora_moveinmessage)

		self.job_data["builder_movedin"] = true
	--end
end


local function move_in_lumberjack(self, buildnum)

	--if self.job_data["lumberjack_movedin"] ~= true then
		print("Moving Lumberjack into House")

		local mybl = vector.add(get_job_position(self),town_data[buildnum].location)
		mayora_fire_loc = vector.add(get_job_position(self),mayora_start_fire_loc)
		local myml = vector.add(get_job_position(self),town_data[buildnum].marker)
		local mayora_meta = minetest.get_meta(myml)
		local special_job = {
			["name"] = "movein1",
			["status"] = 0,
			["buildpos"] = mybl,
			["x"] = mayora_meta:get_int("maxx"),
			["y"] = mayora_meta:get_int("maxy"),
			["z"] = mayora_meta:get_int("maxz"),
		}
		print("MAYORA: I AM FINDING BEDS")
		find_beds_in_build(self, special_job)
		for key, val in pairs(found_beds) do
			print("Bed found at ", val)
		end
		print("MAYORA: I AM FINDING CHESTS")
		find_chests_in_build(self, special_job)
		for key, val in pairs(found_chests) do
			print("Chest found at ", val)
		end

		local bposb = vector.new(found_beds[1])
		local cposb = vector.new(found_chests[1])
local hposb = vector.add(mayora_fire_loc,mayora_start_meet_loc[5])

		lumberjacka_moveinmessage.bed_pos = bposb
		lumberjacka_moveinmessage.chest_pos = cposb
		lumberjacka_moveinmessage.home_pos = hposb
		print("MAYORA: lumberjack MOVEIN MESSAGE SENT.= ", dump(lumberjacka_moveinmessage))
		func.set_lumberjack_a_message(lumberjacka_moveinmessage)

		self.job_data["lumberjack_movedin"] = true
	--end

end


local function move_in_miner(self, buildnum)

	--if self.job_data["miner_movedin"] ~= true then
		print("Moving Miner into House")


	local mybl = vector.add(get_job_position(self),town_data[buildnum].location)
	mayora_fire_loc = vector.add(get_job_position(self),mayora_start_fire_loc)
		local myml = vector.add(get_job_position(self),town_data[buildnum].marker)
	local mayora_meta = minetest.get_meta(myml)
	local special_job = {
		["name"] = "movein1",
		["status"] = 0,
		["buildpos"] = mybl,
		["x"] = mayora_meta:get_int("maxx"),
		["y"] = mayora_meta:get_int("maxy"),
		["z"] = mayora_meta:get_int("maxz"),
	}
	print("MAYORA: I AM FINDING BEDS")
	find_beds_in_build(self, special_job)
	for key, val in pairs(found_beds) do
		print("Bed found at ", val)
	end
	print("MAYORA: I AM FINDING CHESTS")
	find_chests_in_build(self, special_job)
	for key, val in pairs(found_chests) do
		print("Chest found at ", val)
	end

	local bposb = vector.new(found_beds[1])
	local cposb = vector.new(found_chests[1])
	local hposb = vector.add(mayora_fire_loc,mayora_start_meet_loc[4])

	miner_moveinmessage.bed_pos = bposb
	miner_moveinmessage.chest_pos = cposb
	miner_moveinmessage.home_pos = hposb
	print("MAYORA: miner MOVEIN MESSAGE SENT.= ", dump(miner_moveinmessage))
	func.set_miner_a_message(miner_moveinmessage)
		self.job_data["miner_movedin"] = true
	--else
	--	print("Already Moved Miner into House")
	--end
end


local function move_in_farmer(self, buildnum)

	--if self.job_data["miner_movedin"] ~= true then
		print("Moving farmer into House")


	local mybl = vector.add(get_job_position(self),town_data[buildnum].location)
	mayora_fire_loc = vector.add(get_job_position(self),mayora_start_fire_loc)
		local myml = vector.add(get_job_position(self),town_data[buildnum].marker)
	local mayora_meta = minetest.get_meta(myml)
	local special_job = {
		["name"] = "movein1",
		["status"] = 0,
		["buildpos"] = mybl,
		["x"] = mayora_meta:get_int("maxx"),
		["y"] = mayora_meta:get_int("maxy"),
		["z"] = mayora_meta:get_int("maxz"),
	}
	print("MAYORA: I AM FINDING BEDS")
	find_beds_in_build(self, special_job)
	for key, val in pairs(found_beds) do
		print("Bed found at ", val)
	end
	print("MAYORA: I AM FINDING CHESTS")
	find_chests_in_build(self, special_job)
	for key, val in pairs(found_chests) do
		print("Chest found at ", val)
	end

	local bposb = vector.new(found_beds[1])
	local cposb = vector.new(found_chests[1])
local hposb = vector.add(mayora_fire_loc,mayora_start_meet_loc[3])

	farmer_moveinmessage.bed_pos = bposb
	farmer_moveinmessage.chest_pos = cposb
	farmer_moveinmessage.home_pos = hposb
	print("MAYORA: FARMER MOVEIN MESSAGE SENT.= ", dump(farmer_moveinmessage))
	func.set_farmer_a_message(farmer_moveinmessage)
		self.job_data["farmer_movedin"] = true
	--else
	--	print("Already Moved Miner into House")
	--end
end


local function move_in_gardener(self, buildnum)

	--if self.job_data["miner_movedin"] ~= true then
		print("Moving gardener into House")


	local mybl = vector.add(get_job_position(self),town_data[buildnum].location)
	mayora_fire_loc = vector.add(get_job_position(self),mayora_start_fire_loc)
		local myml = vector.add(get_job_position(self),town_data[buildnum].marker)
	local mayora_meta = minetest.get_meta(myml)
	local special_job = {
		["name"] = "movein1",
		["status"] = 0,
		["buildpos"] = mybl,
		["x"] = mayora_meta:get_int("maxx"),
		["y"] = mayora_meta:get_int("maxy"),
		["z"] = mayora_meta:get_int("maxz"),
	}
	print("MAYORA: I AM FINDING BEDS")
	find_beds_in_build(self, special_job)
	for key, val in pairs(found_beds) do
		print("Bed found at ", val)
	end
	print("MAYORA: I AM FINDING CHESTS")
	find_chests_in_build(self, special_job)
	for key, val in pairs(found_chests) do
		print("Chest found at ", val)
	end

	local bposb = vector.new(found_beds[1])
	local cposb = vector.new(found_chests[1])
local hposb = vector.add(mayora_fire_loc,mayora_start_meet_loc[2])

	gardener_moveinmessage.bed_pos = bposb
	gardener_moveinmessage.chest_pos = cposb
	gardener_moveinmessage.home_pos = hposb
	print("MAYORA: GARDENER MOVEIN MESSAGE SENT.= ", dump(gardener_moveinmessage))
	func.set_gardener_a_message(gardener_moveinmessage)
		self.job_data["farmer_movedin"] = true
	--else
	--	print("Already Moved Miner into House")
	--end
end







local function move_in_medic(self, buildnum)

	--if self.job_data["miner_movedin"] ~= true then
		print("Moving medic into House")


	local mybl = vector.add(get_job_position(self),town_data[buildnum].location)
	mayora_fire_loc = vector.add(get_job_position(self),mayora_start_fire_loc)
		local myml = vector.add(get_job_position(self),town_data[buildnum].marker)
	local mayora_meta = minetest.get_meta(myml)
	local special_job = {
		["name"] = "movein1",
		["status"] = 0,
		["buildpos"] = mybl,
		["x"] = mayora_meta:get_int("maxx"),
		["y"] = mayora_meta:get_int("maxy"),
		["z"] = mayora_meta:get_int("maxz"),
	}
	print("MAYORA: I AM FINDING BEDS")
	find_beds_in_build(self, special_job)
	for key, val in pairs(found_beds) do
		print("Bed found at ", val)
	end
	print("MAYORA: I AM FINDING CHESTS")
	find_chests_in_build(self, special_job)
	for key, val in pairs(found_chests) do
		print("Chest found at ", val)
	end

	local bposb = vector.new(found_beds[1])
	local cposb = vector.new(found_chests[1])
local hposb = vector.add(mayora_fire_loc,mayora_start_meet_loc[6])

	medic_moveinmessage.bed_pos = bposb
	medic_moveinmessage.chest_pos = cposb
	medic_moveinmessage.home_pos = hposb
	print("MAYORA: MEDIC MOVEIN MESSAGE SENT.= ", dump(medic_moveinmessage))
	func.set_medic_a_message(medic_moveinmessage)
		self.job_data["medic_movedin"] = true
	--else
	--	print("Already Moved Miner into House")
	--end
end










local function move_in_vet(self, buildnum)

	--if self.job_data["vet_movedin"] ~= true then
		print("Moving vet into House")


	local mybl = vector.add(get_job_position(self),town_data[buildnum].location)
	mayora_fire_loc = vector.add(get_job_position(self),mayora_start_fire_loc)
		local myml = vector.add(get_job_position(self),town_data[buildnum].marker)
	local mayora_meta = minetest.get_meta(myml)
	local special_job = {
		["name"] = "movein1",
		["status"] = 0,
		["buildpos"] = mybl,
		["x"] = mayora_meta:get_int("maxx"),
		["y"] = mayora_meta:get_int("maxy"),
		["z"] = mayora_meta:get_int("maxz"),
	}
	print("MAYORA: I AM FINDING BEDS")
	find_beds_in_build(self, special_job)
	for key, val in pairs(found_beds) do
		print("Bed found at ", val)
	end
	print("MAYORA: I AM FINDING CHESTS")
	find_chests_in_build(self, special_job)
	for key, val in pairs(found_chests) do
		print("Chest found at ", val)
	end

	local bposb = vector.new(found_beds[1])
	local cposb = vector.new(found_chests[1])
local hposb = vector.add(mayora_fire_loc,mayora_start_meet_loc[7])

	vet_moveinmessage.bed_pos = bposb
	vet_moveinmessage.chest_pos = cposb
	vet_moveinmessage.home_pos = hposb
	print("MAYORA: VET MOVEIN MESSAGE SENT.= ", dump(vet_moveinmessage))
	func.set_vet_a_message(vet_moveinmessage)
		self.job_data["vet_movedin"] = true
	--else
	--	print("Already Moved vet into House")
	--end
end







local function move_in_fireman(self, buildnum)

	--if self.job_data["miner_movedin"] ~= true then
		print("Moving fireman into House")


	local mybl = vector.add(get_job_position(self),town_data[buildnum].location)
	mayora_fire_loc = vector.add(get_job_position(self),mayora_start_fire_loc)
		local myml = vector.add(get_job_position(self),town_data[buildnum].marker)
	local mayora_meta = minetest.get_meta(myml)
	local special_job = {
		["name"] = "movein1",
		["status"] = 0,
		["buildpos"] = mybl,
		["x"] = mayora_meta:get_int("maxx"),
		["y"] = mayora_meta:get_int("maxy"),
		["z"] = mayora_meta:get_int("maxz"),
	}
	print("MAYORA: I AM FINDING BEDS")
	find_beds_in_build(self, special_job)
	for key, val in pairs(found_beds) do
		print("Bed found at ", val)
	end
	print("MAYORA: I AM FINDING CHESTS")
	find_chests_in_build(self, special_job)
	for key, val in pairs(found_chests) do
		print("Chest found at ", val)
	end

	local bposb = vector.new(found_beds[1])
	local cposb = vector.new(found_chests[1])
local hposb = vector.add(mayora_fire_loc,mayora_start_meet_loc[8])

	fireman_moveinmessage.bed_pos = bposb
	fireman_moveinmessage.chest_pos = cposb
	fireman_moveinmessage.home_pos = hposb
	print("MAYORA: FIREMAN MOVEIN MESSAGE SENT.= ", dump(fireman_moveinmessage))
	func.set_fireman_a_message(fireman_moveinmessage)
		self.job_data["fireman_movedin"] = true
	--else
	--	print("Already Moved Miner into House")
	--end
end











local function check_the_buildings(self)

	local current_job = get_from_joblist(self,1)
	--print("DUMP CHECK BUILDINGS JOB ", dump(current_job))
	if current_job["status"] == 0 then
		-- Check there is data for the town
		current_job.status = 1
		rem_from_joblist(self)
		add_to_joblist(self,current_job)
		mayora_building_count = 1
		--print("MAYORA: OPENING BUILDING BLUEPRINTS : ", mayora_building_count)
		if town_data[mayora_building_count].marker == nil then
			print("MAYORA: I CAN NOT FIND THE TOWN PLAN START: ", mayora_step)
			rem_from_joblist(self)
			return false
		end
		return nil

	elseif current_job["status"] == 1 then
		--print("MAYORA: FINDING BLUEPRINT : ", mayora_building_count)
		if town_data[mayora_building_count] == nil then 
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
		local bma_loc = vector.add(jpos,town_data[mayora_building_count].marker)
		current_job.status = 2
		rem_from_joblist(self)
		add_to_joblist(self,current_job)
		local waitfor_job = {
			["name"] = "waitfor",
			["status"] = 30
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
		local bma_loc = vector.add(jpos,town_data[mayora_building_count].marker)
		self:set_yaw_by_direction(bma_loc)

		if minetest.get_node(bma_loc).name == mayora_marker then
			local mayora_meta = minetest.get_meta(bma_loc)
			print("BUILD", mayora_building_count, "[", mayora_meta:get_string("house_label"), "] STATE = ", mayora_meta:get_string("state"))
			if mayora_meta:get_string("state") == "finished" then
				-- this building has been built by the builder and awaits signing off
				rem_from_joblist(self)
				local signoff_job = {
					["name"] = "signoffbuild",
					["status"] = 0
				}
				add_to_joblist(self,signoff_job)
				return true
			elseif mayora_meta:get_string("state") == "built" then
				-- this building is finished and signed off for use - CHECK NEXT

				rem_from_joblist(self)
				current_job.status = 1
				add_to_joblist(self,current_job)




				print("Checking:", mayora_meta:get_string("house_label"))

 				if string.find(mayora_meta:get_string("house_label"), "Farmers House") then			
					print("MAYORA: BUILT FARMERS HOUSE, NOW HIRING FARMER")
					local mybl = vector.add(self.pos_data.job_pos,town_data[mayora_building_count].location)
					local orchard_job = {
						["name"] = "hirefarmer",
						["status"] = 0,
						["buildpos"] = mybl,
						["x"] = mayora_meta:get_int("maxx"),
						["y"] = mayora_meta:get_int("maxy"),
						["z"] = mayora_meta:get_int("maxz"),
					}
					add_to_joblist(self,orchard_job)
				end


 				if string.find(mayora_meta:get_string("house_label"), "Miners House") then			
					print("MAYORA: BUILT MINORS HOUSE, NOW HIRING MINOR")
					local mybl = vector.add(self.pos_data.job_pos,town_data[mayora_building_count].location)
					local orchard_job = {
						["name"] = "hireminer",
						["status"] = 0,
						["buildpos"] = mybl,
						["x"] = mayora_meta:get_int("maxx"),
						["y"] = mayora_meta:get_int("maxy"),
						["z"] = mayora_meta:get_int("maxz"),
					}
					add_to_joblist(self,orchard_job)
				end


                -- TODO change to hire gardener
 				if string.find(mayora_meta:get_string("house_label"), "Gardeners House") then			
					print("MAYORA: BUILT GARDENERS HOUSE, NOW HIRING GARDENER")
					local mybl = vector.add(self.pos_data.job_pos,town_data[mayora_building_count].location)
					local orchard_job = {
						["name"] = "hiregardener",
						["status"] = 0,
						["buildpos"] = mybl,
						["x"] = mayora_meta:get_int("maxx"),
						["y"] = mayora_meta:get_int("maxy"),
						["z"] = mayora_meta:get_int("maxz"),
					}
					add_to_joblist(self,orchard_job)
				end



                -- TODO change to hire medic
 				if string.find(mayora_meta:get_string("house_label"), "Medics House") then			
					print("MAYORA: BUILT MEDICS HOUSE, NOW HIRING MEDIC")
					local mybl = vector.add(self.pos_data.job_pos,town_data[mayora_building_count].location)
					local orchard_job = {
						["name"] = "hiremedic",
						["status"] = 0,
						["buildpos"] = mybl,
						["x"] = mayora_meta:get_int("maxx"),
						["y"] = mayora_meta:get_int("maxy"),
						["z"] = mayora_meta:get_int("maxz"),
					}
					add_to_joblist(self,orchard_job)
				end



                -- TODO change to hire vet
 				if string.find(mayora_meta:get_string("house_label"), "Vets House") then			
					print("MAYORA: BUILT VETS HOUSE, NOW HIRING VET")
					local mybl = vector.add(self.pos_data.job_pos,town_data[mayora_building_count].location)
					local orchard_job = {
						["name"] = "hirevet",
						["status"] = 0,
						["buildpos"] = mybl,
						["x"] = mayora_meta:get_int("maxx"),
						["y"] = mayora_meta:get_int("maxy"),
						["z"] = mayora_meta:get_int("maxz"),
					}
					add_to_joblist(self,orchard_job)
				end




                -- TODO change to hire vet
 				if string.find(mayora_meta:get_string("house_label"), "Firemans House") then			
					print("MAYORA: BUILT FIREMANS HOUSE, NOW HIRING FIREMAN")
					local mybl = vector.add(self.pos_data.job_pos,town_data[mayora_building_count].location)
					local orchard_job = {
						["name"] = "hirefireman",
						["status"] = 0,
						["buildpos"] = mybl,
						["x"] = mayora_meta:get_int("maxx"),
						["y"] = mayora_meta:get_int("maxy"),
						["z"] = mayora_meta:get_int("maxz"),
					}
					add_to_joblist(self,orchard_job)
				end




 				if string.find(mayora_meta:get_string("house_label"), "Field1") then
					print("MAYORA: FOUND FIELD GETTING FARMER TO WORK")
					local mybl = vector.add(self.pos_data.job_pos,town_data[mayora_building_count].location)
					local farmer_farm_job = {
						["name"] = "farmerfarm",
						["status"] = 0,
						["buildpos"] = mybl,
						["x"] = mayora_meta:get_int("maxx"),
						["y"] = mayora_meta:get_int("maxy"),
						["z"] = mayora_meta:get_int("maxz"),
					}
					add_to_joblist(self,farmer_farm_job)
				end

				

				-- could check if orchard and set lumberjact to word
 				if string.find(mayora_meta:get_string("house_label"), "Orchard") then
					print("MAYORA: FOUND ORCHARD SETTING LUMBERJACK TO WORK")
					local mybl = vector.add(self.pos_data.job_pos,town_data[mayora_building_count].location)
					local orchard_job = {
						["name"] = "buildorchard",
						["status"] = 0,
						["buildpos"] = mybl,
						["x"] = mayora_meta:get_int("maxx"),
						["y"] = mayora_meta:get_int("maxy"),
						["z"] = mayora_meta:get_int("maxz"),
					}
					add_to_joblist(self,orchard_job)
				end

 				if string.find(mayora_meta:get_string("house_label"), "PitMine") then
					print("MAYORA: FOUND PITMINE SETTING MINER TO WORK")
					local mybl = vector.add(self.pos_data.job_pos,town_data[mayora_building_count].location)
					local pitmine_job = {
						["name"] = "minepit",
						["status"] = 0,
						["buildpos"] = mybl,
						["x"] = mayora_meta:get_int("maxx"),
						["y"] = mayora_meta:get_int("maxy"),
						["z"] = mayora_meta:get_int("maxz"),
					}
					add_to_joblist(self,pitmine_job)
				end










				mayora_building_count = mayora_building_count + 1
				return nil

			elseif mayora_meta:get_string("state") == "begun" then
				-- this building is begun -- so continue
				rem_from_joblist(self)
				local continuebuild_job = {
					["name"] = "continuebuild",
					["status"] = 0
				}
				add_to_joblist(self,continuebuild_job)
				return true
			elseif mayora_meta:get_string("state") == "unplanned" then
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
			print("START BUILDING")
			local startbuild_job = {
				["name"] = "startbuild",
				["status"] = 0
			}

			rem_from_joblist(self)
			add_to_joblist(self,startbuild_job)
            if mayora_building_count == 1 then
			    local notify_job = {
			    	["name"] = "notify",
			    	["status"] = 0,
			    	["message"] = " waiting to give you an update.\n"
			    }
				local smsg = "I will place markers down to keep track of whats been built, and I am going to hire my mate Bob to help with the building\nYou may have to keep an eye on him.. they may need stuff.\nI have brought a selection of goodies which I have left in my chest, help yourself.. You will need the working villages command sceptor to get me to continue and interact with us fully\n\n Go grab it, and lets get building"
			    self:set_state_info(smsg)
			    add_to_joblist(self,notify_job)
            end




			return true
		end	
	end
end

local function look_at_fire(self)
    look_at_position(self,vector.add(get_job_position(self),mayora_start_fire_loc))
	rem_from_joblist(self)
end




local function goto_myhome(self)

		local hpos = get_home_position(self)

		local wait_job = {
			["name"] = "waitfor",
			["status"] = 100
		}

    	local laf_job = {
			["name"] = "lookatfire",
			["status"] = 100
		}

		local goto_job = {
			["name"] = "gotohere",
			["dest"] = hpos,
			["status"] = 0
		}
		rem_from_joblist(self)
		add_to_joblist(self,wait_job)
		add_to_joblist(self,laf_job)
		add_to_joblist(self,goto_job)


end


local function wait_for_time(self)
	local current_job = get_from_joblist(self,1)
	rem_from_joblist(self)
	if current_job["status"] > 0 then
		--print("Waiting for ",current_job.status)
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

local found_fancyfires = { }
local function find_fancyfires_in_build(self, cjob)

	print("Looking for FancyFires in new build")
	print("DUMP CJOB:" , dump(cjob))

	local xpos = cjob.buildpos.x + cjob.x 
	local ypos = cjob.buildpos.y + cjob.y 
	local zpos = cjob.buildpos.z + cjob.z 

	local bcount = 1
	found_fancyfires = { }


   	for iy = cjob.buildpos.y, ypos  do 
	    	for iz = cjob.buildpos.z, zpos  do 
			for ix = cjob.buildpos.x, xpos  do 

				local testloc = vector.new{ x= ix, y= iy, z= iz}
				if minetest.get_node(testloc).name == "fake_fire:fancy_fire" then
					local sloc = minetest.pos_to_string(testloc)
					--print("Found a ", minetest.get_node(testloc).name, " at ", testloc)
					found_fancyfires[bcount] = testloc
					bcount = bcount + 1
				end

			end
		end
	end
end




local function check_for_tree_base(self,pos)

	for key,val in pairs(tree_types) do
--		print("IN LOC = ", minetest.get_node(pos).name)
		if minetest.get_node(pos).name == val then
			print("HAVE I FOUND A TREE")
			return true
		end
	end
end


local function check_build_site(self)

	-- TODO now its just take a walk around the perimiter and pretend all is good
	-- TODO later it should be to actually check the perimeter and enclosed area.. then either 
		-- if trees found = call lumberjack to remove trees in area
		-- if high land found = call Groundsman to level land in area
		-- if a hole is found = call Miner to fill mine in area
		-- BUT more important issues a foot


	local current_job = get_from_joblist(self,1)
--	print("JOB DUMP: ", dump(current_job))
--	print("CHECKING BUILD SITE STATUS", current_job.status)

	if current_job.status == 0 then
		-- goto the build position
		local bpos = current_job["buildpos"] 	-- vector.add(current_job["buildpos"],jpos)
		bpos.y = bpos.y + 1
		current_job.status = 1
		rem_from_joblist(self)
		add_to_joblist(self,current_job)
		local goto_bpos = {
			["name"] = "gotohere",
			["dest"] = bpos,
			["status"] = 0
		}
		add_to_joblist(self,goto_bpos)

	elseif current_job.status == 1 then
		-- check the area for trees
		local bpos = current_job["buildpos"] 	-- vector.add(current_job["buildpos"],jpos)
		local xpos = current_job["x"] 		-- the width of the build
		local zpos = current_job["z"] 		-- the depth of the build
		local mypos = self.object:get_pos()
	    	for ix = 1, xpos  do 
		    	for iz = 1, zpos  do 
				local tpos = vector.new{ x= bpos.x + ix ,y= mypos.y ,z= bpos.z + iz}
				--print("Checking site pos ", tpos)
				if check_for_tree_base(self,tpos) == true then 
					-- need to check it is a tree and call a lumberjack to remove it
					current_job.status = 0
					rem_from_joblist(self)
					add_to_joblist(self,current_job)
					-- goto tree location

					if self.job_data["hired_lumberjack"] == nil then
						-- JOB phone builder
						local hirelumberjack_job = {
							["name"] = "hirelumberjack",
							["status"] = 0
						}
						add_to_joblist(self,hirelumberjack_job)
						return true
					end

					-- tell lumberjack to chop the tree
					print("SETTING LUMBERJACK CHOP TREE MESSAGE")
					local lumberjacka_chopmessage = 	{ 
						msg = "Lumberjack chop this",
						pos = tpos,
					}

					func.set_lumberjack_a_message(lumberjacka_chopmessage)					
					


--					local treeloc = func.get_closest_clear_spot(self.object:get_pos(), tpos)	

					local notify_job = {
						["name"] = "notify",
						["status"] = 0,
						["message"] = " I am waiting to see if the tree is chopped down !!\n"
					}
					add_to_joblist(self,notify_job)


--					local goto_treeloc = {
--						["name"] = "gotohere",
--						["dest"] = tpos,
--						["status"] = 0
--					}
--					add_to_joblist(self,goto_treeloc)
					return true
				end
			end
		end
	end
	rem_from_joblist(self)
	return false
	
end 


local function signoff_building(self)

	-- sign off the building as finished
	local current_job = get_from_joblist(self,1)
	print("DUMP SIGNOFF BUILDING JOB ", dump(current_job))
	local mybl = vector.add(get_job_position(self),town_data[mayora_building_count].location)
	local myml = vector.add(get_job_position(self),town_data[mayora_building_count].marker)
	local mayora_meta = minetest.get_meta(myml)

	-- should go around the site and "check" it is ok to sign off

	if current_job["status"] == 0 then
		-- go and have a little look at the build
		print("SIGNOFF BUILD STAGE 0")
		current_job.status = 1
		rem_from_joblist(self)
		add_to_joblist(self,current_job)

		-- should find beds herew

--		local checkbs_job = {
--			["name"] = "checkbuildsite",
--			["status"] = 0,
--			["buildpos"] = mybl,--mayora_meta:get_string("build_pos"),
--			["x"] = mayora_meta:get_int("maxx"),
--			["y"] = mayora_meta:get_int("maxy"),
--			["z"] = mayora_meta:get_int("maxz"),
--		}
--		add_to_joblist(self,checkbs_job)

	elseif current_job["status"] == 1 then
		-- go back to the building marker
		print("SIGNOFF BUILD STAGE 1")
		current_job.status = 2

		local goto_job = {
			["name"] = "gotohere",
			["dest"] = myml,
			["status"] = 0
		}
		rem_from_joblist(self)
		add_to_joblist(self,current_job)
		add_to_joblist(self,goto_job)

	elseif current_job["status"] == 2 then
		-- finish and remove job
		print("SIGNOFF BUILD STAGE 2")



		if mayora_meta:get_string("state") == "finished" then

			mayora_meta:set_string("state","built")
			--local temps = 
			mayora_meta:set_string("house_label", town_data[mayora_building_count].name)
--	???		mayora_meta:set_string("formspec",simple_working_villages.buildings.get_formspec(mayora_meta))
			mayora_meta:set_string("owner", self.owner_name)
			mayora_meta:set_string("infotext", town_data[mayora_building_count].name)

			mayora_job_status = 3
		end
		local cbuilds_job = {
			["name"] = "checkbuilds",
			["status"] = 0
		}

		rem_from_joblist(self)
		add_to_joblist(self,cbuilds_job)

	-- TODO check here for special instructions
	-- TODO check here for special instructions
	-- TODO check here for special instructions
	-- TODO check here for special instructions
	-- TODO check here for special instructions
	-- TODO check here for special instructions
	-- TODO check here for special instructions
	-- TODO check here for special instructions
	-- TODO check here for special instructions
	-- TODO check here for special instructions
	-- TODO check here for special instructions
	-- TODO check here for special instructions
	-- TODO check here for special instructions
	-- TODO check here for special instructions
	-- TODO check here for special instructions


		if mayora_building_count == 1 then	

			local special_job = {
				["name"] = "movein1",
				["status"] = 0,
				["buildpos"] = mybl,
				["x"] = mayora_meta:get_int("maxx"),
				["y"] = mayora_meta:get_int("maxy"),
				["z"] = mayora_meta:get_int("maxz"),
			}
			add_to_joblist(self,special_job)

		end









--		if mayora_building_count == 6 then	

       --print("TESTING MOVEINS for ", mayora_meta:get_string("house_label"))

--				print("Testing movein's")

 				if string.find(mayora_meta:get_string("house_label"),"Builders House") then
					print("MAYOR: TRYING TO MOVEIN BUILDER")
					move_in_builder(self,mayora_building_count)					
--				end
		end

--		if mayora_building_count == 7 then	

				if string.find(mayora_meta:get_string("house_label"),"LumberJacks Hut") then
					print("MAYOR: TRYING TO MOVEIN lumberjack")
					move_in_lumberjack(self,mayora_building_count)					
--				end
		end

--		if mayora_building_count == 8 then	

				if string.find(mayora_meta:get_string("house_label"),"Miners House") then
					print("MAYOR: TRYING TO MOVEIN miner")
					move_in_miner(self,mayora_building_count)					
--				end


		end

				if string.find(mayora_meta:get_string("house_label"),"Farmers House") then
					print("MAYOR: TRYING TO MOVEIN farmer")
					move_in_farmer(self,mayora_building_count)					
--				end


		end

				if string.find(mayora_meta:get_string("house_label"),"Gardeners House") then
					print("MAYOR: TRYING TO MOVEIN Gardener")
					move_in_gardener(self,mayora_building_count)					
--				end


		end

				if string.find(mayora_meta:get_string("house_label"),"Vets House") then
					print("MAYOR: TRYING TO MOVEIN Vet")
					move_in_vet(self,mayora_building_count)					
--				end


		end

				if string.find(mayora_meta:get_string("house_label"),"Medics House") then
					print("MAYOR: TRYING TO MOVEIN Medic")
					move_in_medic(self,mayora_building_count)					
--				end


		end

				if string.find(mayora_meta:get_string("house_label"),"Firemans House") then
					print("MAYOR: TRYING TO MOVEIN Fireman")
					move_in_fireman(self,mayora_building_count)					
--				end


		end

















	end
end



local function waitforbuildtofinish(self)

	local current_job = get_from_joblist(self,1)
	rem_from_joblist(self)
	
	local myml = vector.add(get_job_position(self),town_data[mayora_building_count].marker)
	local mayora_meta = minetest.get_meta(myml)
	--print("CHECKING BUILD STATUS", mayora_meta:get_string("state"), current_job.state)

	if mayora_meta:get_string("state") == "finished" then
		local signoff_job = {
			["name"] = "signoffbuild",
			["status"] = 0
		}
		add_to_joblist(self,signoff_job)
	else


--	local lookfortree_job = {
--		["name"] = "lookfortree",
--		["status"] = 0
--	}
--	add_to_joblist(self,lookfortree_job)



--	local walknorth_job = {
--		["name"] = "walknorth",
--		["status"] = 1000
--	}
--	add_to_joblist(self,walknorth_job)

--	end

-- follows is the standard wait handler
		local cstate = current_job.status 
		if cstate == 0 then 
			cstate = mayora_building_count +1 
		else
			cstate = cstate + 1
		end		

		if town_data[cstate] == nil then
			cstate = mayora_building_count 
		end
		current_job.status = cstate
		add_to_joblist(self,current_job)
		--print("CSTATE=", cstate)
		local nbl = town_data[cstate].location
		--print("NBL=",nbl)		
		local nblv = vector.new(nbl.x,nbl.y,nbl.z)
		local nb_loc = vector.add(nblv,get_job_position(self))
		
		local waitfor_joba = {
			["name"] = "waitfor",
			["status"] = 100
		}
		add_to_joblist(self,waitfor_joba)
				

		local gotohome_job = {
			["name"] = "gotohome",
			["status"] = 0
		}
		add_to_joblist(self,gotohome_job)

--		check_build_site(self)

		local waitfor_jobb = {
			["name"] = "waitfor",
			["status"] = 100
		}
		add_to_joblist(self,waitfor_jobb)
		local goto_job = {
			["name"] = "gotohere",
			["dest"] = nb_loc,
			["status"] = 0
		}
		add_to_joblist(self,goto_job)
	end

end



local function continue_building(self)
	--print("MAYORA: TELLING BUILDER TO CONTINUE JOB ", mayora_building_count)
	local myml = vector.add(self.pos_data.job_pos,town_data[mayora_building_count].marker)
	mayora_buildmessage.pos = myml
	func.set_builder_a_message(mayora_buildmessage)

	local waitforbuildfinished_job = {
		["name"] = "waitforbuildfinished",
		["status"] = 0
	}	
	local gotohome_job = {
		["name"] = "gotohome",
		["status"] = 0
	}
	local waitforbuildok_job = {
		["name"] = "waitforbuildok",
		["status"] = 500
	}
	rem_from_joblist(self)
	add_to_joblist(self,waitforbuildfinished_job)
	add_to_joblist(self,gotohome_job)
	add_to_joblist(self,waitforbuildok_job)
	return true
end


local function gardener_clear_building(self)
	--print("MAYORA: TELLING BUILDER TO CONTINUE JOB ", mayora_building_count)
	local myml = vector.add(self.pos_data.job_pos,town_data[mayora_building_count].marker)
	mayora_buildmessage.pos = myml
	func.set_gardener_a_message(mayora_buildmessage)

	local waitforbuildfinished_job = {
		["name"] = "waitforbuildfinished",
		["status"] = 0
	}	
	local gotohome_job = {
		["name"] = "gotohome",
		["status"] = 0
	}
	local waitforbuildok_job = {
		["name"] = "waitforbuildok",
		["status"] = 500
	}
	rem_from_joblist(self)
	add_to_joblist(self,waitforbuildfinished_job)
	add_to_joblist(self,gotohome_job)
	add_to_joblist(self,waitforbuildok_job)
	return true
end





local function start_building(self)

	local current_job = get_from_joblist(self,1)
	--print("DUMP START BUILDINGS JOB ", dump(current_job))
	local myml = vector.add(self.pos_data.job_pos,town_data[mayora_building_count].marker)
	local mybl = vector.add(self.pos_data.job_pos,town_data[mayora_building_count].location)



	if current_job.status == 0 then
		-- going to the marker position
		print("MAYORA: IS GOING TO LAY THE PLANS FOR BUILD NUMBER ", mayora_building_count)
		current_job.status = 1		
		rem_from_joblist(self)
		add_to_joblist(self,current_job)
		local goto_job = {
			["name"] = "gotohere",
			["dest"] = myml,
			["status"] = 0
		}
		add_to_joblist(self,goto_job)


	elseif current_job.status == 1 then
		-- place marker down
		--print("MAYOR:found ", minetest.get_node(myml).name, " where my marker needs to go")
		if minetest.get_node(myml).name ~= "air" and minetest.get_node(myml).name ~= mayora_marker then
			self:dig(myml,false)
			coroutine.yield()
		end
		local function is_material(name)
			return name == mayora_marker
		end
		local wield_stack = self:get_wield_item_stack()
		if is_material(wield_stack:get_name()) or self:has_item_in_main(is_material) then
			if minetest.get_node(myml).name == "air" then
				self:place(mayora_marker,myml)
				coroutine.yield()
				current_job.status = 2
				rem_from_joblist(self)
				add_to_joblist(self,current_job)
			end
		else
			local msg = "mayora at " .. minetest.pos_to_string(self.object:get_pos()) .. " doesn't have " .. mayora_marker
			if self.owner_name then
				minetest.chat_send_player(self.owner_name,msg)
			else
				print(msg)
			end
			self:set_state_info(("I am currently waiting for somebody to give me some %s."):format(mayora_marker))
			coroutine.yield(co_command.pause,"waiting for materials")
		end


	elseif current_job.status == 2 then
		-- setting build instructions
		print("MAYORA: SETTING BUILD INSTRUCTIONS = ", mayora_building_count, " AT MARKER LOC ", myml) 

		
		local bscheme = town_data[mayora_building_count].scheme

		local mayora_meta = minetest.get_meta(myml)
		mayora_meta:set_string("build_pos",minetest.pos_to_string(mybl))
		local tempxyz = simple_working_villages.buildings.load_schematic( bscheme   ,myml)
		mayora_meta:set_int("maxx",tempxyz.x)
		mayora_meta:set_int("maxy",tempxyz.y)
		mayora_meta:set_int("maxz",tempxyz.z)
		mayora_meta:set_string("thename",town_data[mayora_building_count].name)
		mayora_meta:set_int("index",0)
		mayora_meta:set_string("state","checking")		


		print("BUILD NAME = ", town_data[mayora_building_count].name)
		print("BUILD POS = ", mayora_meta:get_string("build_pos"))
		print("MAXX META = ", tempxyz.x)
		print("MAXY META = ", tempxyz.y)
		print("MAXZ META = ", tempxyz.z)

		current_job.status = 3




		local goto_jobbl = {
			["name"] = "gotohere",
			["dest"] = mybl,
			["status"] = 0
		}

		local waitfor_jobbl = {
			["name"] = "waitfor",
			["status"] = 50
		}
		rem_from_joblist(self)
		add_to_joblist(self,current_job)
		add_to_joblist(self,waitfor_jobbl)
		add_to_joblist(self,goto_jobbl)
		


	elseif current_job.status == 3 then

		local mayora_meta = minetest.get_meta(myml)
        -- should i be checking the build site here ?
		local checkbs_job = {
			["name"] = "checkbuildsite",
			["status"] = 0,
			["buildpos"] = mybl,--mayora_meta:get_string("build_pos"),
			["x"] = mayora_meta:get_int("maxx"),
			["y"] = mayora_meta:get_int("maxy"),
			["z"] = mayora_meta:get_int("maxz"),
		}

		current_job.status = 4
		rem_from_joblist(self)
		add_to_joblist(self,current_job)		
        add_to_joblist(self,checkbs_job)


	elseif current_job.status == 4 then

--   		local clearbuild_job = {
--		    ["name"] = "clearbuild",
--		    ["status"] = 0
--	    }


--	    add_to_joblist(self,clearbuild_job)
	   
--	    if self.job_data["hired_gardener"] == nil or self.job_data["hired_gardener"] == false then
--		    -- JOB phone builder
--		    local hiregardener_job = {
--			    ["name"] = "hiregardener",
--			    ["status"] = 0
--		    }
--		    add_to_joblist(self,hiregardener_job)
--	    end

		current_job.status = 5
		rem_from_joblist(self)
		add_to_joblist(self,current_job)
--		add_to_joblist(self,checkbs_job)


	elseif current_job.status == 5 then



		-- phoneing builder and then doing something while waiting for build to finish

		rem_from_joblist(self)
       --print("MAYOR: stage 5 = phone builder")




		local waitfor_job = {
			["name"] = "waitfor",
			["status"] = 50
		}
		add_to_joblist(self,waitfor_job)



		local continuebuild_job = {
			["name"] = "continuebuild",
			["status"] = 0
		}
		add_to_joblist(self,continuebuild_job)



		-- do I need to hire a builder
		if self.job_data["hired_builder"] == nil or self.job_data["hired_builder"] == false then
			-- JOB phone builder
			local hirebuilder_job = {
				["name"] = "hirebuilder",
				["status"] = 0
			}
			add_to_joblist(self,hirebuilder_job)
		end



		-- go to home location
		local gotohome_job = {
			["name"] = "gotohome",
			["status"] = 0
		}
		add_to_joblist(self,gotohome_job)	


		local mayora_meta = minetest.get_meta(myml)

        mayora_meta:set_string("state","begun")


	end

end


local function hire_a_builder(self)
	local current_job = get_from_joblist(self,1)
	rem_from_joblist(self)
	mayora_fire_loc = vector.add(get_job_position(self),mayora_start_fire_loc)
	local hposb = vector.add(mayora_fire_loc,mayora_start_meet_loc[1])
	if self.job_data["hired_builder"] == true then
		print("MAYOR_A: I have a Builder")
	else
		print("MAYOR_A: I will try to hire a Builder")
		if current_job.status == 0 then
			current_job.status = 1
			add_to_joblist(self,current_job)
			print("MAYOR_A: GOING HOME TO HIRE A BUILDER ", get_home_position(self))

			local gotohome_job = {
				["name"] = "gotohere",
				["dest"] = hposb,
				["status"] = 0
			}
			add_to_joblist(self,gotohome_job)
		elseif current_job.status == 1 then
			--rem_from_joblist(self)
			local hireloc = func.get_closest_clear_spot(self.object:get_pos(), get_home_position(self))	
			local mayora_buildera_npc = "simple_working_villages:villager_male_builder_a"
			local obj = core.add_entity(hposb, mayora_buildera_npc, nil)
			local ent = obj:get_luaentity()
			ent.new_job = mayora_buildera_job
			ent.owner_name = self.owner_name
			--print("MAYORA: product_name ", dump(self.product_name))
			ent:update_infotext()
			--print("MAYORA: NEW ENT DUMP ", dump(ent.product_name))
			self.job_data["hired_builder"] = true
			--self.job_data["hired_builder_object"] = obj
			local wait_job = {
				["name"] = "waitfor",
				["status"] = 100
			}
			add_to_joblist(self,wait_job)
		end
	end
end


local function hire_a_gardener(self)
	local current_job = get_from_joblist(self,1)
	rem_from_joblist(self)
	mayora_fire_loc = vector.add(get_job_position(self),mayora_start_fire_loc)
	local hposb = vector.add(mayora_fire_loc,mayora_start_meet_loc[2])
	if self.job_data["hired_gardener"] == true then
		print("MAYOR_A: I have a gardener")
	else
		print("MAYOR_A: I will try to hire a gardener")
		if current_job.status == 0 then
			current_job.status = 1
			add_to_joblist(self,current_job)
			print("MAYOR_A: GOING HOME TO HIRE A gardener ", get_home_position(self))

			local gotohome_job = {
				["name"] = "gotohere",
				["dest"] = hposb,
				["status"] = 0
			}
			add_to_joblist(self,gotohome_job)
		elseif current_job.status == 1 then
			--rem_from_joblist(self)
			local hireloc = func.get_closest_clear_spot(self.object:get_pos(), get_home_position(self))	

			local obj = core.add_entity(hposb, mayora_gardenera_npc, nil)
			local ent = obj:get_luaentity()
			ent.new_job = mayora_gardenera_job
			ent.owner_name = self.owner_name
			--print("MAYORA: product_name ", dump(self.product_name))
			ent:update_infotext()
			--print("MAYORA: NEW ENT DUMP ", dump(ent.product_name))
			self.job_data["hired_gardener"] = true
			--self.job_data["hired_gardener_object"] = obj
			local wait_job = {
				["name"] = "waitfor",
				["status"] = 100
			}
			add_to_joblist(self,wait_job)
		end
	end
end



local function hire_a_farmer(self)
	local current_job = get_from_joblist(self,1)
	rem_from_joblist(self)
	mayora_fire_loc = vector.add(get_job_position(self),mayora_start_fire_loc)
	local hposb = vector.add(mayora_fire_loc,mayora_start_meet_loc[3])
			local wait_job = {
				["name"] = "waitfor",
				["status"] = 100
			}
	if self.job_data["hired_farmer"] == true then
		print("MAYOR_A: I have a Farmer")
		--move_in_farmer(self, 10)
			add_to_joblist(self,wait_job)
	else
		print("MAYOR_A: I will try to hire a Farmer")
		if current_job.status == 0 then
			current_job.status = 1
			add_to_joblist(self,current_job)
			print("MAYOR_A: GOING HOME TO HIRE A FARMER ", get_home_position(self))

			local gotohome_job = {
				["name"] = "gotohere",
				["dest"] = hposb,
				["status"] = 0
			}
			add_to_joblist(self,gotohome_job)
		elseif current_job.status == 1 then
			--rem_from_joblist(self)
			local hireloc = func.get_closest_clear_spot(self.object:get_pos(), get_home_position(self))	
			local mayora_farmera_npc = "simple_working_villages:villager_male_farmer_a"
			local obj = core.add_entity(hposb, mayora_farmera_npc, nil)
			local ent = obj:get_luaentity()
			ent.new_job = mayora_farmera_job
			ent.owner_name = self.owner_name
			--print("MAYORA: product_name ", dump(self.product_name))
			ent:update_infotext()
			--print("MAYORA: NEW ENT DUMP ", dump(ent.product_name))
			self.job_data["hired_farmer"] = true
			--self.job_data["hired_builder_object"] = obj
			move_in_farmer(self, 8)
			add_to_joblist(self,wait_job)

		end
	end
end


local function hire_a_miner(self)
	local current_job = get_from_joblist(self,1)
	rem_from_joblist(self)

	mayora_fire_loc = vector.add(get_job_position(self),mayora_start_fire_loc)
	local hposb = vector.add(mayora_fire_loc,mayora_start_meet_loc[4])

	if self.job_data["hired_miner"] == true then
		print("MAYOR_A: I have a Miner")
	else
		print("MAYOR_A: I will try to hire a Miner")
		if current_job.status == 0 then

			current_job.status = 1
			add_to_joblist(self,current_job)
			print("MAYOR_A: GOING HOME TO HIRE A Miner ", get_home_position(self))

			local gotohome_job = {
				["name"] = "gotohere",
				["dest"] = hposb,
				["status"] = 0
			}
			add_to_joblist(self,gotohome_job)

		elseif current_job.status == 1 then
			--rem_from_joblist(self)
			local hireloc = func.get_closest_clear_spot(self.object:get_pos(), get_home_position(self))	
			local mayora_minera_npc = "simple_working_villages:villager_male_miner_a"

			local obj = core.add_entity(hposb, mayora_minera_npc, nil)
			local ent = obj:get_luaentity()
			ent.new_job = mayora_minera_job
			ent.owner_name = self.owner_name
			--print("MAYORA: product_name ", dump(self.product_name))
			ent:update_infotext()
			--print("MAYORA: NEW ENT DUMP ", dump(ent.product_name))
			self.job_data["hired_miner"] = true

			local wait_job = {
				["name"] = "waitfor",
				["status"] = 100
			}
			add_to_joblist(self,wait_job)

		end
	end
end




local function hire_a_lumberjack(self)

	local current_job = get_from_joblist(self,1)
	rem_from_joblist(self)

	mayora_fire_loc = vector.add(get_job_position(self),mayora_start_fire_loc)
	local hposb = vector.add(mayora_fire_loc,mayora_start_meet_loc[5])

	if current_job.status == 0 then

		current_job.status = 1
		add_to_joblist(self,current_job)
		print("MAYORA: GOING HOME TO HIRE A LUMBERJACK ", get_home_position(self))

		-- go to home location
		local gotohome_job = {
				["name"] = "gotohere",
				["dest"] = hposb,
			["status"] = 0
		}
		add_to_joblist(self,gotohome_job)

	elseif current_job.status == 1 then
		--rem_from_joblist(self)
		local hireloc = func.get_closest_clear_spot(self.object:get_pos(), get_home_position(self))	
		--local mayora_buildera_npc = "simple_working_villages:villager_male_lumberjack_a"

		local obj = core.add_entity(hposb, mayora_lumberjacka_npc, nil)
		local ent = obj:get_luaentity()
		ent.new_job = mayora_lumberjacka_job
		ent.owner_name = self.owner_name
		--print("MAYORA: product_name ", dump(self.product_name))
		ent:update_infotext()
		--print("MAYORA: NEW ENT DUMP ", dump(ent.product_name))
		self.job_data["hired_lumberjack"] = true

	end
end



-- TODO hire_a_medic
local function hire_a_medic(self)

	local current_job = get_from_joblist(self,1)
	rem_from_joblist(self)

	mayora_fire_loc = vector.add(get_job_position(self),mayora_start_fire_loc)
	local hposb = vector.add(mayora_fire_loc,mayora_start_meet_loc[6])
	if self.job_data["hired_medic"] == true then
		print("MAYOR_A: I have a medic")
	else
		print("MAYOR_A: I will try to hire a medic")
	if current_job.status == 0 then

		current_job.status = 1
		add_to_joblist(self,current_job)
		print("MAYORA: GOING HOME TO HIRE A MEDIC ", get_home_position(self))

		-- go to home location
		local gotohome_job = {
				["name"] = "gotohere",
				["dest"] = hposb,
			["status"] = 0
		}
		add_to_joblist(self,gotohome_job)

	elseif current_job.status == 1 then
		--rem_from_joblist(self)
		local hireloc = func.get_closest_clear_spot(self.object:get_pos(), get_home_position(self))	
		--local mayora_buildera_npc = "simple_working_villages:villager_male_lumberjack_a"

		local obj = core.add_entity(hposb, mayora_medica_npc, nil)
		local ent = obj:get_luaentity()
		ent.new_job = mayora_medica_job
		ent.owner_name = self.owner_name
		--print("MAYORA: product_name ", dump(self.product_name))
		ent:update_infotext()
		--print("MAYORA: NEW ENT DUMP ", dump(ent.product_name))
		self.job_data["hired_medic"] = true
end
	end
end





-- TODO hire_a_vet
local function hire_a_vet(self)

	local current_job = get_from_joblist(self,1)
	rem_from_joblist(self)

	mayora_fire_loc = vector.add(get_job_position(self),mayora_start_fire_loc)
	local hposb = vector.add(mayora_fire_loc,mayora_start_meet_loc[7])
	if self.job_data["hired_vet"] == true then
		print("MAYOR_A: I have a vet")
	else
		print("MAYOR_A: I will try to hire a vet")
	if current_job.status == 0 then

		current_job.status = 1
		add_to_joblist(self,current_job)
		print("MAYORA: GOING HOME TO HIRE A VET ", get_home_position(self))

		-- go to home location
		local gotohome_job = {
				["name"] = "gotohere",
				["dest"] = hposb,
			["status"] = 0
		}
		add_to_joblist(self,gotohome_job)

	elseif current_job.status == 1 then
		--rem_from_joblist(self)
		local hireloc = func.get_closest_clear_spot(self.object:get_pos(), get_home_position(self))	
		--local mayora_buildera_npc = "simple_working_villages:villager_male_lumberjack_a"

		local obj = core.add_entity(hposb, mayora_veta_npc, nil)
		local ent = obj:get_luaentity()
		ent.new_job = mayora_veta_job
		ent.owner_name = self.owner_name
		--print("MAYORA: product_name ", dump(self.product_name))
		ent:update_infotext()
		--print("MAYORA: NEW ENT DUMP ", dump(ent.product_name))
		self.job_data["hired_vet"] = true
end
	end
end





-- TODO hire_a_fireman
local function hire_a_fireman(self)

	local current_job = get_from_joblist(self,1)
	rem_from_joblist(self)

	mayora_fire_loc = vector.add(get_job_position(self),mayora_start_fire_loc)
	local hposb = vector.add(mayora_fire_loc,mayora_start_meet_loc[8])
	if self.job_data["hired_fireman"] == true then
		print("MAYOR_A: I have a fireman")
	else
		print("MAYOR_A: I will try to hire a fireman")
	if current_job.status == 0 then

		current_job.status = 1
		add_to_joblist(self,current_job)
		print("MAYORA: GOING HOME TO HIRE A FIREMAN ", get_home_position(self))

		-- go to home location
		local gotohome_job = {
				["name"] = "gotohere",
				["dest"] = hposb,
			["status"] = 0
		}
		add_to_joblist(self,gotohome_job)

	elseif current_job.status == 1 then
		--rem_from_joblist(self)
		local hireloc = func.get_closest_clear_spot(self.object:get_pos(), get_home_position(self))	
		--local mayora_buildera_npc = "simple_working_villages:villager_male_lumberjack_a"

		local obj = core.add_entity(hposb, mayora_firemana_npc, nil)
		local ent = obj:get_luaentity()
		ent.new_job = mayora_firemana_job
		ent.owner_name = self.owner_name
		--print("MAYORA: product_name ", dump(self.product_name))
		ent:update_infotext()
		--print("MAYORA: NEW ENT DUMP ", dump(ent.product_name))
		self.job_data["hired_fireman"] = true
end
	end
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
            self.job_data["newstart"] = false
		end
	end
end



local function speech_1(self)
	local current_job = get_from_joblist(self,1)
	rem_from_joblist(self)
	print("Speach 1 start")



	if current_job.status == 0 then
		print("MAYORA: Going to camp")
		current_job.status = current_job.status + 1
		add_to_joblist(self,current_job)

		local goto_joba = {
			["name"] = "gotohere",
			["dest"] = self.pos_data.job_pos,
			["status"] = 0
		}
		add_to_joblist(self,goto_joba)


	elseif current_job.status == 1 then
		print("MAYORA: waiting in camp for the rest of the actions")
		--current_job.status = current_job.status + 1
		add_to_joblist(self,current_job)
		


	end



end





local function move_in_1(self)
	local current_job = get_from_joblist(self,1)

	--print("DUMP JOB:", dump(current_job))

	if current_job.status == 0 then
		print("MAYORA: I AM BEGINNING TO MOVE IN CAMP")
		current_job.status = current_job.status + 1
	rem_from_joblist(self)
		add_to_joblist(self,current_job)
		
	elseif current_job.status == 1 then
		--print("MAYORA: HIRING LUMBERJACK = TODO")
		current_job.status = current_job.status + 1
	rem_from_joblist(self)
		add_to_joblist(self,current_job)
		
-- 		TODO need to check if I have a lumberjack or hire one
		if self.job_data["hired_lumberjack"] == nil then
			-- JOB phone builder
			local hirelumberjack_job = {
				["name"] = "hirelumberjack",
				["status"] = 0
			}
			add_to_joblist(self,hirelumberjack_job)
--			return true
		end

	elseif current_job.status == 2 then
		current_job.status = current_job.status + 1
	rem_from_joblist(self)
		add_to_joblist(self,current_job)
		print("MAYORA: I AM FINDING BEDS")
		find_beds_in_build(self, current_job)
		for key, val in pairs(found_beds) do
			print("Bed found at ", val)
		end
	

	elseif current_job.status == 3 then
		current_job.status = current_job.status + 1
	rem_from_joblist(self)
		add_to_joblist(self,current_job)
		print("MAYORA: I AM FINDING CHESTS")
		find_chests_in_build(self, current_job)
		for key, val in pairs(found_chests) do
			print("Chest found at ", val)
		end


	elseif current_job.status == 4 then
		current_job.status = current_job.status + 1
	rem_from_joblist(self)
		add_to_joblist(self,current_job)
		print("MAYORA: I AM FINDING CAMPFIRES")
		find_fancyfires_in_build(self, current_job)
		for key, val in pairs(found_fancyfires) do
			print("FancyFire found at ", val)
		end

	elseif current_job.status == 5 then
		current_job.status = current_job.status + 1
	rem_from_joblist(self)
		add_to_joblist(self,current_job)
		print("MAYORA MOVEIN STAGE 5: Moving people in")

		local jpos = get_job_position(self)
		local cposa = vector.new(found_chests[4])
		print("MAYOR chest pos = ", cposa)
		local bposa = vector.new(found_beds[4])
		print("MAYOR bed pos = ", bposa)
		local hposa = vector.add(mayora_fire_loc,mayora_start_meet_loc[0])
		--local hposa = vector.add(vector.new(found_fancyfires[1]),vector.new{x=-2, y=0, z=2})
		print("MAYOR home pos = ", hposa)
	
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

		local bposb = vector.new(found_beds[1])
		local cposb = vector.new(found_chests[1])
		local hposb = vector.add(mayora_fire_loc,mayora_start_meet_loc[1])
        --local hposb = vector.add(vector.new(found_fancyfires[1]),vector.new{x=0, y=0, z=-2})
		--print("MAYORA: BEDB POS = ", bpos)
		--print("MAYORA: CHESTB POS = ", cpos)
		--print("MAYORA: HOMEB POS = ", hpos)

		mayora_moveinmessage.bed_pos = bposb
		mayora_moveinmessage.food_pos = cposb
		mayora_moveinmessage.storage_pos = cposb
		mayora_moveinmessage.job_pos = hposb
		mayora_moveinmessage.tools_pos = cposb
		mayora_moveinmessage.chest_pos = cposb
		mayora_moveinmessage.home_pos = hposb
		print("MAYORA: BUILDER MOVEIN MESSAGE = ", dump(mayora_moveinmessage))
		func.set_builder_a_message(mayora_moveinmessage)


		local bposc = vector.new(found_beds[2])
		local cposc = vector.new(found_chests[2])
		local hposc = vector.add(mayora_fire_loc,mayora_start_meet_loc[5])		
        --local hposc = vector.add(vector.new(found_fancyfires[1]),vector.new{x= 2, y=0, z=-2})
		--print("MAYORA: BEDB POS = ", bpos)
		--print("MAYORA: CHESTB POS = ", cpos)
		--print("MAYORA: HOMEB POS = ", hpos)

		lumberjacka_moveinmessage.bed_pos = bposc
		lumberjacka_moveinmessage.food_pos = cposc
		lumberjacka_moveinmessage.storage_pos = cposc
		lumberjacka_moveinmessage.job_pos = hposc
		lumberjacka_moveinmessage.tools_pos = cposc
		lumberjacka_moveinmessage.chest_pos = cposc
		lumberjacka_moveinmessage.home_pos = hposc
		print("MAYORA: LUMBERJACK MOVEIN MESSAGE = ", dump(lumberjacka_moveinmessage))
		func.set_lumberjack_a_message(lumberjacka_moveinmessage)


--		local bposd = vector.new(found_beds[3])
--		local cposd = vector.new(found_chests[3])
--		local hposb = vector.add(mayora_fire_loc,mayora_start_meet_loc[1])
--		local hposd = vector.add(vector.new(found_fancyfires[1]),vector.new{x= 2, y=0, z=0})
		--print("MAYORA: BEDB POS = ", bpos)
		--print("MAYORA: CHESTB POS = ", cpos)
		--print("MAYORA: HOMEB POS = ", hpos)

--		miner_moveinmessage.bed_pos = bposd
--		miner_moveinmessage.food_pos = cposd
--		miner_moveinmessage.storage_pos = cposd
--		miner_moveinmessage.job_pos = hposd
--		miner_moveinmessage.tools_pos = cposd
--		miner_moveinmessage.chest_pos = cposd
--		miner_moveinmessage.home_pos = hposd
--		print("MAYORA: MINER MOVEIN MESSAGE = ", dump(miner_moveinmessage))
--		func.set_miner_a_message(miner_moveinmessage)


	elseif current_job.status == 6 then
		print("MAYORA: LOOKING AT MY STUFF")	
	rem_from_joblist(self)	
		--get_home_position(self)


		local waitfor_joba = {
			["name"] = "waitfor",
			["status"] = 200
		}
		add_to_joblist(self,waitfor_joba)

		local goto_joba = {
			["name"] = "gotohere",
			["dest"] = self.pos_data.chest_pos,
			["status"] = 0
		}
		add_to_joblist(self,goto_joba)

		local waitfor_jobb = {
			["name"] = "waitfor",
			["status"] = 200
		}
		add_to_joblist(self,waitfor_jobb)

		local goto_jobb = {
			["name"] = "gotohere",
			["dest"] = self.pos_data.bed_pos,
			["status"] = 0
		}
		add_to_joblist(self,goto_jobb)

		local waitforbuildok_job = {
			["name"] = "waitforbuildok",
			["status"] = 500
		}
		add_to_joblist(self,waitforbuildok_job)
	end
end








local function find_building(p)
	if minetest.get_node(p).name ~= "simple_working_villages:building_marker" then
		return false
	end
	local mayora_meta = minetest.get_meta(p)
	if mayora_meta:get_string("state") ~= "begun" then
		return false
	end
	local mayora_build_pos = simple_working_villages.buildings.get_build_pos(mayora_meta)
	if mayora_build_pos == nil then
		return false
	end
	if simple_working_villages.buildings.get(mayora_build_pos)==nil then
		return false
	end
	return true
end



local function been_punched(self)

print("This is where I handle the ON PUNCH EVENT !!")

--self:have_i_been_attacked()





end





local function check_for_tree(self,pos)

	--node_at = minetest.get_node(pos).name

	for key,val in pairs(tree_types) do
	
		if minetest.get_node(pos).name == val then
			-- tree part found

			-- is it a stump
			local tpos = vector.add(pos, vector.new{ x=0, y=1, z=0 })			
			if minetest.get_node(tpos).name ~= var then
				-- does not go upwards

				tpos = vector.add(pos, vector.new{ x=1, y=0, z=0 })			
				if minetest.get_node(tpos).name ~= var then
					
					tpos = vector.add(pos, vector.new{ x=-1, y=0, z=0 })			
					if minetest.get_node(tpos).name ~= var then
				
						tpos = vector.add(pos, vector.new{ x=0, y=0, z=1 })			
						if minetest.get_node(tpos).name ~= val then
				
							tpos = vector.add(pos, vector.new{ x=0, y=0, z=-1 })			
							if minetest.get_node(tpos).name ~= val then

								-- i have found a single block of "tree"
								print("I THINK I HAVE FOUND A STUMP")
								return "STUMP"

							end -- else check south for log
						end -- else check north for log
					end -- else check west for log
				end -- else check east for log
			else
				-- it goes upwards
				local tree_height = 1
				local tpos = vector.add(pos, vector.new{ x=0, y=tree_height, z=0 })			
				while minetest.get_node(tpos).name == var do
					tree_height = tree_height + 1
					tpos = vector.add(pos, vector.new{ x=0, y=tree_height, z=0 })
				end

				print("IT SEEMS THIS TREE IS ", tree_height, " BLOCKS TALL")
				-- look for leaves ?
				-- or branches of tree
				


--				local tpos = vector.add(pos, vector.new{ x=0, y=1, z=0 })			
--				if minetest.get_node(tpos).name == var then
--
--					 tpos = vector.add(pos, vector.new{ x=1, y=0, z=0 })			
--					if minetest.get_node(tpos).name ~= var then
--						
--						tpos = vector.add(pos, vector.new{ x=-1, y=0, z=0 })			
--						if minetest.get_node(tpos).name ~= var then
--					
--							tpos = vector.add(pos, vector.new{ x=0, y=0, z=1 })			
--							if minetest.get_node(tpos).name ~= val then
--					
--								tpos = vector.add(pos, vector.new{ x=0, y=0, z=-1 })			
--								if minetest.get_node(tpos).name ~= val then
--
--									-- i have found a single block of tree
--						
--								end
--							end
--						end
--					end
--				end


			end
			-- is it a trunk



		end
	end
end


--function simple_working_villages.villager:handle_night()
--	local tod = minetest.get_timeofday()
--	if	tod < 0.2 or tod > 0.76 then
--
--	-- goto bed
--
--
--end


local function mine_pit(self)
	local current_job = get_from_joblist(self,1)
	rem_from_joblist(self)

--	if current_job.status == 0 then
--		current_job.status = 1
--		add_to_joblist(self,current_job)

--		local hireminer_job = {
--			["name"] = "hireminer",
--			["status"] = 0
--		}
--		add_to_joblist(self,hireminer_job)
	
--	elseif current_job.status == 1 then

		local s_job = {}
		s_job["msg"] = "Miner Mine Here"
		s_job["name"] = "minepit"
		s_job["status"] = 0
		s_job["buildpos"] = current_job["buildpos"]
		s_job["x"] = current_job["x"]
		s_job["y"] = current_job["y"]
		s_job["z"] = current_job["z"]
		print("MAYORA: TELLING MINER TO MINE")
		func.set_miner_a_message(s_job)

--	end	
end


local function build_orchard(self)

	local current_job = get_from_joblist(self,1)
	rem_from_joblist(self)




	local s_job = {}
	s_job["msg"] = "Lumberjack Plant Orchard"
	s_job["name"] = "plantorchard"
	s_job["status"] = 0
	s_job["buildpos"] = current_job["buildpos"]
	s_job["x"] = current_job["x"]
	s_job["y"] = current_job["y"]
	s_job["z"] = current_job["z"]


	print("MAYORA: TELLING LUMBERJACK TO TEND ORCHARD")
	func.set_lumberjack_a_message(s_job)	


end



local function farmer_farm(self)

	local current_job = get_from_joblist(self,1)
	rem_from_joblist(self)
	local s_job = {}
	s_job["msg"] = "Build This"
	s_job["name"] = "buildthis"
	s_job["status"] = 0
	s_job["buildpos"] = current_job["buildpos"]
	s_job["x"] = current_job["x"]
	s_job["y"] = current_job["y"]
	s_job["z"] = current_job["z"]
	print("MAYORA: TELLING FARMER TO FARM")
	func.set_farmer_a_message(s_job)	


end















local function check_build_item(self,initem)



			--	print("CheckBuildItem=", initem)
				-- TODO TRY BEDTOP REPLACEMENT
				if initem:find("beds:bed_top") then
					print("I Need a Bed Top")
					local buildera_inv = self:get_inventory()
					if buildera_inv:room_for_item("main", ItemStack(initem)) then
						print("adding a bed top")
						buildera_inv:add_item("main", ItemStack(initem))
					else
						local msg = "buildera at " .. minetest.pos_to_string(self.object:get_pos()) ..
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
--					local buildera_inv = self:get_inventory()
--					if buildera_inv:room_for_item("main", ItemStack(initem)) then
--						buildera_inv:add_item("main", ItemStack(initem))
--						--buildera_inv:add_item("main", ItemStack(initem))"beds:bed_top"
--					else
--						local msg = "buildera at " .. minetest.pos_to_string(self.object:get_pos()) ..
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
							local msg = "buildera at " .. minetest.pos_to_string(self.object:get_pos()) ..
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
							local msg = "buildera at " .. minetest.pos_to_string(self.object:get_pos()) ..
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
							local msg = "buildera at " .. minetest.pos_to_string(self.object:get_pos()) ..
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
					
					buildera_nnode.param1 = 0
					
				end


end


















--local mayora_start_bed_loc = vector.new{ x=11, y=0, z=8 }
--local mayora_start_bedtop_loc = vector.new{ x=11, y=0, z=9 }
--local mayora_start_chest_loc = vector.new{ x=14, y=0, z=9 }
-- game locations for the mayors bed and chest
--local mayora_bed_loc = nil
--local mayora_chest_loc = nil


local function check_my_bed(self)

	local current_job = get_from_joblist(self,1)

	local bb_node = { }
	bb_node.param1 = 158
	bb_node.name = "beds:bed_bottom"
	bb_node.param2 = 0

	local bt_node = { }
	bt_node.param1 = 142
	bt_node.name = "beds:bed_top"
	bt_node.param2 = 0

	local jpos = get_job_position(self)
	if jpos ~= nil then
		
		mayora_bed_loc = vector.add(jpos,mayora_start_bed_loc)
		local mayora_bedtop_loc = vector.add(jpos,mayora_start_bedtop_loc)

		if current_job.status == 0 then
			print("MAYOR_A: Going to bed location")
			current_job.status = 1
			-- go to the bed location
			local mypos = self.object:get_pos()
			local gotoloc = func.get_closest_clear_spot(mypos,mayora_bed_loc)
			local gotobedloc_job = {
				["name"] = "gotohere",
				["dest"] = gotoloc,
				["status"] = 0
			}
			rem_from_joblist(self)
			add_to_joblist(self,current_job)
			add_to_joblist(self,gotobedloc_job)

		elseif current_job.status == 1 then
			-- should be at the bed
			--print("MAYOR_A: Found where bed bottom should be :", dump(minetest.get_node(mayora_bed_loc)))
			if minetest.get_node(mayora_bed_loc).name == "beds:bed_bottom" then 
				-- all good bed bottom found
				current_job.status = 3
				rem_from_joblist(self)
				add_to_joblist(self,current_job)
			else
				-- not good bed not found
				current_job.status = 2
				rem_from_joblist(self)
				add_to_joblist(self,current_job)
			end

		elseif current_job.status == 2 then
			-- place bed bottom
				
			print("MAYOR_A: Trying to place bed bottom")
			if minetest.get_node(mayora_bed_loc).name ~= "air" then
				self:dig(mayora_bed_loc,false)
				--coroutine.yield()
			end
			local function is_material(name)
				return name == bb_node.name
			end
			local wield_stack = self:get_wield_item_stack()
			if is_material(wield_stack:get_name()) or self:has_item_in_main(is_material) then
				if minetest.get_node(mayora_bed_loc).name == "air" then
					--coroutine.yield()
					current_job.status = 3
					rem_from_joblist(self)
					add_to_joblist(self,current_job)
					self:place(bb_node,mayora_bed_loc)
				end
			else
				local msg = "mayora at " .. minetest.pos_to_string(self.object:get_pos()) .. " doesn't have " .. bb_node.name
				if self.owner_name then
					minetest.chat_send_player(self.owner_name,msg)
				else
					print(msg)
				end
				self:set_state_info(("I am currently waiting for somebody to give me some %s."):format(bb_node.name))
				coroutine.yield(co_command.pause,"waiting for materials")
			end

		elseif current_job.status == 3 then
			-- should be a bed bottom

			if minetest.get_node(mayora_bed_loc).name ~= "beds:bed_bottom" then 
				-- not good bed bottom not found
				current_job.status = 2
				rem_from_joblist(self)
				add_to_joblist(self,current_job)
			else
				-- Check for a bed top
				if minetest.get_node(mayora_bedtop_loc).name == "beds:bed_top" then 
					-- all good bed bottom found
					current_job.status = 5
					rem_from_joblist(self)
					add_to_joblist(self,current_job)
				else
					-- not good bed not found
					current_job.status = 4
					rem_from_joblist(self)
					add_to_joblist(self,current_job)
				end
			end

		elseif current_job.status == 4 then
			-- place bed top
				
			print("MAYOR_A: Trying to place bed top")
			if minetest.get_node(mayora_bedtop_loc).name ~= "air" then
				self:dig(mayora_bedtop_loc,false)
				--coroutine.yield()
			end
			local function is_material(name)
				return name == bt_node.name
			end

			-- need to check swap
			check_build_item(self,simple_working_villages.buildings.get_registered_nodename(bt_node.name))

			local wield_stack = self:get_wield_item_stack()
			if is_material(wield_stack:get_name()) or self:has_item_in_main(is_material) then
				if minetest.get_node(mayora_bedtop_loc).name == "air" then
					--coroutine.yield()
					current_job.status = 3
					rem_from_joblist(self)
					add_to_joblist(self,current_job)
					self:place(bt_node,mayora_bedtop_loc)
				end
			else
				local msg = "mayora at " .. minetest.pos_to_string(self.object:get_pos()) .. " doesn't have " .. bt_node.name
				if self.owner_name then
					minetest.chat_send_player(self.owner_name,msg)
				else
					print(msg)
				end
				self:set_state_info(("I am currently waiting for somebody to give me some %s."):format(bt_node.name))
				coroutine.yield(co_command.pause,"waiting for materials")
			end
		elseif current_job.status == 5 then
			print("MAYOR_A: Finished checking my bed")
			rem_from_joblist(self)
			self.pos_data.bed_pos = mayora_bed_loc
		end
	else
	-- there is no town center position ( JOB_POS )

	end
end




local function fill_my_chest(self)

print("MAYOR: CALLING IN A SUPPLY DROP")

	local jpos = get_job_position(self)
--	if jpos ~= nil then
	mayora_chest_loc = vector.add(jpos,mayora_start_chest_loc)
	--print("CHEST LOCATION", mayora_chest_loc)
	--print("Where my chest should be = ", dump(minetest.get_node(mayora_chest_loc)))
--	if self.job_data["townchest"] == true then
--		-- already used
--		return false
--	else
		--print("getting chest meta")		
		local inv = core.get_inventory({ type="node", pos=mayora_chest_loc })
		--print("chest size = ", inv:get_size("main"))
		if inv:is_empty("main") then
			--print("The chest is empty, as it should be !")
			local stack    = ItemStack("beds:bed_bottom")
			local leftover = inv:add_item("main", stack)
			local stack    = ItemStack("beds:bed_bottom")
			local leftover = inv:add_item("main", stack)
			local stack    = ItemStack("beds:bed_bottom")
			local leftover = inv:add_item("main", stack)
			local stack    = ItemStack("beds:bed_bottom")
			local leftover = inv:add_item("main", stack)
			local stack    = ItemStack("beds:bed_bottom")
			local leftover = inv:add_item("main", stack)
			local stack    = ItemStack("beds:bed_bottom")
			local leftover = inv:add_item("main", stack)
			local stack    = ItemStack("beds:bed_bottom")
			local leftover = inv:add_item("main", stack)
			local stack    = ItemStack("beds:bed_bottom")
			local leftover = inv:add_item("main", stack)
			local stack    = ItemStack("simple_working_villages:commanding_sceptre")
			local leftover = inv:add_item("main", stack)
			local stack    = ItemStack("simple_working_villages:building_marker 99")
			local leftover = inv:add_item("main", stack)
			local stack    = ItemStack("homedecor:gate_half_door_closed 10")
			local leftover = inv:add_item("main", stack)
			local stack    = ItemStack("fake_fire:fancy_fire 20")
			local leftover = inv:add_item("main", stack)
			local stack    = ItemStack("default:apple 99")
			local leftover = inv:add_item("main", stack)
			local stack    = ItemStack("default:torch 99")
			local leftover = inv:add_item("main", stack)
			local stack    = ItemStack("default:furnace 10")
			local leftover = inv:add_item("main", stack)
			local stack    = ItemStack("default:sapling 50")
			local leftover = inv:add_item("main", stack)
			local stack    = ItemStack("default:chest 20")
			local leftover = inv:add_item("main", stack)
			local stack    = ItemStack("default:fence_wood 99")
			local leftover = inv:add_item("main", stack)
			local stack    = ItemStack("default:fence_rail_wood 99")
			local leftover = inv:add_item("main", stack)
			local stack    = ItemStack("stairs:slab_wood 99")
			local leftover = inv:add_item("main", stack)
			local stack    = ItemStack("stairs:slab_wood 99")
			local leftover = inv:add_item("main", stack)
			local stack    = ItemStack("default:wood 99")
			local leftover = inv:add_item("main", stack)
			local stack    = ItemStack("default:wood 99")
			local leftover = inv:add_item("main", stack)
			local stack    = ItemStack("default:wood 99")
			local leftover = inv:add_item("main", stack)
			local stack    = ItemStack("default:wood 99")
			local leftover = inv:add_item("main", stack)
			local stack    = ItemStack("default:water_source 99")
			local leftover = inv:add_item("main", stack)
			local stack    = ItemStack("doors:door_wood 99")
			local leftover = inv:add_item("main", stack)
			local stack    = ItemStack("default:ladder_wood 99")
			local leftover = inv:add_item("main", stack)
			local stack    = ItemStack("homedecor:table 15")
			local leftover = inv:add_item("main", stack)
			local stack    = ItemStack("homedecor:kitchen_chair_wood 30")
			local leftover = inv:add_item("main", stack)
			--self.job_data["townchest"] = true
			return true
		else
			--print("The chest is NOT empty, listing stacks !")
			local stacks = inv:get_list("main")
			for _, stack in ipairs(stacks) do
				local itemname = stack:get_name()
				local itemcount = stack:get_count()
				--print("STACK ITEM : ",itemname, itemcount)
			end
			return false
		end
	---end
end









local function check_my_chest(self)
	local current_job = get_from_joblist(self,1)

	--print("MAYORA: CHECKMYCHEST JOB:")

	local c_node = { }
	c_node.param1 = 158
	c_node.name = "default:chest"
	c_node.param2 = 0


	local jpos = get_job_position(self)
	if jpos ~= nil then
		
		mayora_chest_loc = vector.add(jpos,mayora_start_chest_loc)

		if current_job.status == 0 then
			--print("MAYOR_A: Going to chest location")
			current_job.status = 1
	rem_from_joblist(self)
			add_to_joblist(self,current_job)
			-- go to the bed location
			local mypos = self.object:get_pos()
			local gotoloc = func.get_closest_clear_spot(mypos,mayora_chest_loc)
			local gotobedloc_job = {
				["name"] = "gotohere",
				["dest"] = gotoloc,
				["status"] = 0
			}
			add_to_joblist(self,gotobedloc_job)

		elseif current_job.status == 1 then
			-- should be at the bed
			--print("MAYOR_A: Found where my chest should be :", dump(minetest.get_node(mayora_chest_loc)))
			if minetest.get_node(mayora_chest_loc).name == c_node.name then 
				-- all good chest found
				current_job.status = 3
	rem_from_joblist(self)
				add_to_joblist(self,current_job)
			else
				-- not good chest not found
				current_job.status = 2
	rem_from_joblist(self)
				add_to_joblist(self,current_job)
			end

		elseif current_job.status == 2 then
			-- place bed bottom
				
			--print("MAYOR_A: Trying to place chest")
			if minetest.get_node(mayora_chest_loc).name ~= "air" then
				self:dig(mayora_chest_loc,false)
				--coroutine.yield()
			end
			local function is_material(name)
				return name == c_node.name
			end

			local wield_stack = self:get_wield_item_stack()
			if is_material(wield_stack:get_name()) or self:has_item_in_main(is_material) then
				if minetest.get_node(mayora_chest_loc).name == "air" then
					--coroutine.yield()

					self:place(c_node,mayora_chest_loc)
					current_job.status = 3
	rem_from_joblist(self)
					add_to_joblist(self,current_job)
				end
			else
					current_job.status = 1
	rem_from_joblist(self)
					add_to_joblist(self,current_job)
				local msg = "mayora at " .. minetest.pos_to_string(self.object:get_pos()) .. " doesn't have " .. c_node.name
				if self.owner_name then
					minetest.chat_send_player(self.owner_name,msg)
				else
					print(msg)
				end
				self:set_state_info(("I am currently waiting for somebody to give me some %s."):format(c_node.name))
				coroutine.yield(co_command.pause,"waiting for materials")
			end





		elseif current_job.status == 3 then
			-- placed chest
			--print("MAYOR_A: Finished checking chest and filling with start goods")
	rem_from_joblist(self)
			self.pos_data.chest_pos = mayora_chest_loc
			fill_my_chest(self)

		end
	else
	-- there is no town center position ( JOB_POS )

	end



end










local function check_my_fire(self)
	local current_job = get_from_joblist(self,1)
	
	--print("MAYORA: CHECKMYFIRE JOB:")

	local c_node = { }
	c_node.name = "fake_fire:fancy_fire"


	local jpos = get_job_position(self)
	if jpos ~= nil then
		
		mayora_fire_loc = vector.add(jpos,mayora_start_fire_loc)

		if current_job.status == 0 then
			--print("MAYOR_A: Going to fire location")
			current_job.status = 1
			-- go to the bed location
			local mypos = self.object:get_pos()
			local gotoloc = func.get_closest_clear_spot(mypos,mayora_fire_loc)
			local gotofireloc_job = {
				["name"] = "gotohere",
				["dest"] = gotoloc,
				["status"] = 0
			}
			rem_from_joblist(self)
			add_to_joblist(self,current_job)
			add_to_joblist(self,gotofireloc_job)


		elseif current_job.status == 1 then
			-- should be at the bed
			--print("MAYOR_A: Found where my chest should be :", dump(minetest.get_node(mayora_chest_loc)))
			if minetest.get_node(mayora_fire_loc).name == c_node.name then 
				-- all good chest found
				current_job.status = 3
				rem_from_joblist(self)
				add_to_joblist(self,current_job)
			else
				-- not good chest not found
				current_job.status = 2
				rem_from_joblist(self)
				add_to_joblist(self,current_job)
			end



		elseif current_job.status == 2 then
			-- place fire
			--print("MAYOR_A: Trying to place fire")
			if minetest.get_node(mayora_fire_loc).name ~= "air" then
				self:dig(mayora_fire_loc,false)
				--coroutine.yield()
			end
			local function is_material(name)
				return name == c_node.name
			end

			local wield_stack = self:get_wield_item_stack()
			if is_material(wield_stack:get_name()) or self:has_item_in_main(is_material) then
				if minetest.get_node(mayora_fire_loc).name == "air" then
					--coroutine.yield()

					self:place(c_node,mayora_fire_loc)
					current_job.status = 3
					rem_from_joblist(self)
					add_to_joblist(self,current_job)
				end
			else
					current_job.status = 1
					rem_from_joblist(self)
					add_to_joblist(self,current_job)
				local msg = "mayora at " .. minetest.pos_to_string(self.object:get_pos()) .. " doesn't have " .. c_node.name
				if self.owner_name then
					minetest.chat_send_player(self.owner_name,msg)
				else
					print(msg)
				end
				self:set_state_info(("I am currently waiting for somebody to give me some %s."):format(c_node.name))
				coroutine.yield(co_command.pause,"waiting for materials")
			end


		elseif current_job.status == 3 then
			-- placed fire
			--print("MAYOR_A: Finished checking fire")
				rem_from_joblist(self)
			self.pos_data.fire_pos = mayora_fire_loc
		end
	else
	-- there is no town center position ( JOB_POS )

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
		--print("Do Situp")
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
--	print("MAYOR: Getting TIME")


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
--	print("")
	local mess = "MAYOR TIME: " .. days_of_week[the_day] 
	if hour < 10 then
		mess = mess .. " 0" .. hour .. ":"
	else
		mess = mess .. " " .. hour .. ":"
	end
	if min < 10 then
		mess = mess .. "0" .. min
	else
		mess = mess .. min
	end
	print(mess)
--	print("Day:", 	
	
-- 0.041666667 = per 1 hour
-- 0.25 = 6AM
-- 0.75 = 9PM
--	wakeup_time = 0.2
--	work_time = 0.24
--	stop_time = 0.76
--	bed_time = 0.805


	-- TODO will have rethink this with the nightworkers

--	print("TOD = ", tod)
--	print("wakeup_time = ", self.wakeup_time)
--	print("work_time = ", self.work_time)
--	print("stop_time = ", self.stop_time)
--	print("bed_time = ", self.bed_time)


--	print("JOBACTION:", self.job_data["jobaction"])
		if get_size_joblist(self) > 0 then 
			for i = 1, get_size_joblist(self) do
			local cjob = get_from_joblist(self,i)
--			print("MAYOR JOB", i, " = ", cjob.name)
			end
		end	if tod > self.bed_time then --and tod < self.wakeup_time then

		-- go to bed time
--		print("Testing bedtime")
		if self.job_data["jobaction"] == 1 then
--			print("BED TIME HAS BEEN SET")
		else
--			print("NOW SETTING BED TIME")
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
--		print("Testing hometime")
		if self.job_data["jobaction"] ~= 2 then
--			print("SETTING HOME TIME")
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
--		print("Testing worktime")
		if self.job_data["jobaction"] ~= 3 then
--			print("SETTING WORK TIME")
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
--		print("Testing uptime")
		if self.job_data["jobaction"] ~= 4 then
--			print("SETTING GETTING UP")
			local uptime_job = {
				["name"] = "uptime",
				["status"] = 0
			}
--			rem_from_joblist(self)
			add_to_joblist(self,uptime_job)
			self.job_data["jobaction"] = 4
		end
	else 
--		print("Testing endbedtime")
		if self.job_data["jobaction"] ~= 1 then
--			print("SETTING BED TIME")
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

	print("MAYORA: ON_GAME_LOAD")

	local nothing_job = {
		name = "nothing",
		status = 0
		}
	add_to_joblist(self,nothing_job)

	mayora_new_start = false

end




local function do_uptime(self)
print("MAYOR: DO UPTIME")
-- get up, go to home, sit down 

	local current_job = get_from_joblist(self,1)


		-- FIXME to test miner movein 
		self.job_data["miner_movedin"] = true

	local nothing_job = {
		name = "nothing",
		status = 0
	}
	





	local situps_job = {
		name = "dositups",
		status = 10
	}

	local gotohome_job = {
		["name"] = "gotohome",
		["status"] = 0
	}
--		current_job.status = 1
	self.job_data["joblist"] = {}			-- list to hold current job list
		--rem_from_joblist(self)
	add_to_joblist(self,nothing_job)
	add_to_joblist(self,situps_job)
	add_to_joblist(self,gotohome_job)
--	end

	self:set_displayed_action("getting up and getting ready for work")

end

local function do_worktime(self)
print("MAOR: DO WORKTIME")
	local dest = get_job_position(self)
	local cbuilds_job = {
		["name"] = "checkbuilds",
		["status"] = 0
	}
	local bedcheck_job = {
		["name"] = "checkmybed",
		["status"] = 0
	}
	local chestcheck_job = {
		["name"] = "checkmychest",
		["status"] = 0
	}
	local firecheck_job = {
		["name"] = "checkmyfire",
		["status"] = 0
	}
		local waitfor_joba = {
			["name"] = "waitfor",
			["status"] = 200
		}
	rem_from_joblist(self)
	add_to_joblist(self,cbuilds_job)
	add_to_joblist(self,chestcheck_job)
	add_to_joblist(self,bedcheck_job)
	add_to_joblist(self,firecheck_job)
	add_to_joblist(self,waitfor_joba)
	self:set_displayed_action("Working")
end

local function do_hometime(self)
print("MAYOR: DO HOMETIME")
-- go to home, sit down 



	local nothing_job = {
		name = "nothing",
		status = 0
	}
	
	local gotohome_job = {
		["name"] = "gotohome",
		["status"] = 0
	}
--		current_job.status = 1
	self.job_data["joblist"] = {}			-- list to hold current job list
		--rem_from_joblist(self)
	add_to_joblist(self,nothing_job)
	add_to_joblist(self,gotohome_job)
--	end
		-- 

	self:set_displayed_action("relaxing after work")
end

local function do_bedtime(self)
   --print("MAYOR: DO BEDTIME")
	local current_job = get_from_joblist(self,1)

	if current_job.status == 0 then

		--print("MAYOR BED POS = ", self.pos_data.bed_pos)
		local dest = func.get_closest_clear_spot(self.object:get_pos(),self.pos_data.bed_pos)
		local gotobed_job = {
			["name"] = "gotohere",
			["dest"] = dest,
			["status"] = 0
		}
		current_job.status = 1
		--rem_from_joblist(self)
        reset_joblist(self)

		add_to_joblist(self,current_job)
		add_to_joblist(self,gotobed_job)

	else
		--rem_from_joblist(self)

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
			-- cannot find bed
		end
		self:set_animation(simple_working_villages.animation_frames.LAY)
		self.object:set_pos(bed_pos)
		self:set_state_info("Zzzzzzz...")
		self:set_displayed_action("sleeping")
		rem_from_joblist(self)
	end
end






local context = {} -- persist data between callback calls


local function emerge_callback(pos, action,
        num_calls_remaining, context)
    -- On first call, record number of blocks
    if not context.total_blocks then
        context.total_blocks  = num_calls_remaining + 1
        context.loaded_blocks = 0
    end

    -- Increment number of blocks loaded
    context.loaded_blocks = context.loaded_blocks + 1

    -- Send progress message
    if context.total_blocks == context.loaded_blocks then
        core.chat_send_all("Finished loading blocks!")
    else
        local perc = 100 * context.loaded_blocks / context.total_blocks
        local msg  = string.format("Loading blocks %d/%d (%.2f%%)",
                context.loaded_blocks, context.total_blocks, perc)
        core.chat_send_all(msg)
    end
end











local slow_update_count = 100
local under_attack = false

simple_working_villages.register_job("simple_working_villages:job_mayor_a", {
	description      = "mayor A (simple_working_villages)",
	long_description = "I am going to build you a small town. "..
"I have a few friends that I can call to help.\
If you run out of supplies just empty my chest and I will call in a fresh load.",
	inventory_image  = "default_paper.png^working_villages_builder.png",
	jobfunc = function(self)




-- 3 types of update
-- on tick
-- on new_game
-- on game start/continue
-- slow update, every N ticks

-- DO ON TICK

		if use_vh1 then VH1.update_bar(self.object, self.object:get_hp()) end





-- ONCE ON NEW GAME
		if self.job_data["isstarted"] == nil then
			print("MAYOR A : Starting initial variables")


			self.job_data["joblist"] = {}			-- list to hold current job list
			self.job_data["jobaction"] = 0		-- TODO Idea to use this as the main loop control
			
			self.job_data["builder_loc"] = nil
			self.job_data["builder_time"] = nil

            self.pos_data["job_pos"] = self.object:get_pos() 



			self.job_data["pathdata"] = {}


			self.job_data["pathstep"] = 0
			self.job_data["pathgoing"] = false

			self.job_data["last_animation"] = "STAND"



			self.job_data["subaction"] = 0			-- Idea to use this as the main sub loop control
			self.job_data["waitaction"] = 0			-- Idea to use this as the main sub loop control
			self.job_data["jobstatus"] = 0			-- status holder of the of the current job 1,2,3,4,5, ect
			self.job_data["jobcounter"] = 0			-- status holder of the of the current job 1,2,3,4,5, ect
			self.job_data["townchest"] = false		-- if the special chest has been deployed
			self.job_data["workers"] = {} 			-- currently active workers
			self.job_data["currentbuild"] = 0		-- current building being worked on  



			self.job_data["checkbuild"] = false
			self.job_data["isstarted"] = true		-- to make sure this only runs once


			local mayor_inv = self:get_inventory()
   			local stack    = ItemStack("beds:bed_bottom")
    		local leftover = mayor_inv:add_item("main", stack)
   			local stack    = ItemStack("simple_working_villages:building_marker 99")
   			local leftover = mayor_inv:add_item("main", stack)
   			local stack    = ItemStack("fake_fire:fancy_fire 1")
   			local leftover = mayor_inv:add_item("main", stack)
   			local stack    = ItemStack("default:chest 1")
   			local leftover = mayor_inv:add_item("main", stack)




	
		end



-- ONLY ON GAME LOAD AND CONTINUE
		if mayora_new_start then
			print("MAYOR: LOAD_START")

-- FIXME FOR TESTING BUILDER
	--self.job_data["hired_builder"] = false



local pos = self.object:get_pos()
local halfsize = { x = 400, y = 100, z = 400 }
local pos1 = vector.subtract(pos, halfsize)
local pos2 = vector.add     (pos, halfsize)

--core.emerge_area(pos1, pos2, emerge_callback, context)



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


			local selfo = self.object:get_texture_mod()
			--print("DUMP SELFO):", dump(selfo))

--			if selfo == "" then
--				self.object:set_texture_mod("^villager_male_mayor_a0.png")
--			else
--				self.object:set_texture_mod("")
--			end				
			

			--local craftr = minetest.get_craft_recipe("homedecor:kitchen_faucet")
			--print("DUMP CRAFTR):", dump(craftr))





--			local selfo = self.object



			local all_objects = minetest.get_objects_inside_radius(self.object:get_pos(), 200)
			for _, object in pairs(all_objects) do
				if object:get_luaentity() then
					local luae = object:get_luaentity()
					local my_oname = luae.name
					

					local dname1 = "simple_working_villages:dummy_item"
					local dname2 = "visual_harm_1ndicators:hpbar"
					local dname3 = "__builtin:item"
					--local dname1 = 
					--local dname1 = 
					--local dname1 = 
					--local dname1 = 

					if my_oname ~= dname1 and my_oname ~= dname2 and my_oname ~= dname3 then
				--		print("ENTITY", _, " NAME: ", my_oname)
					end


					--if my_oname == "simple_working_villages:villager_male_builder_a" then
					--	print("Builder is at ", object:get_pos())
					--end
				end
			end



			--local bobj = self.job_data["hired_builder_object"]
			--if bobj ~= nil then
			--	print("Builder Health = ", bobj:get_hp())
			--else
			--	print("Builder Health = N/A")
			--end			



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

		-- NOTE: has to handle doors here just incase game is loaded with NPC in doorway
		self:handle_doors()		


		-- TODO TODO TODO replace these with job_list
		 --print("MAYORA JOBLIST=", dump(mayora_joblist))
		--print("CHECKING JOBLIST")
		

--		if get_size_joblist(self) > 0 then 
--			print("")
--			for i = 1, get_size_joblist(self) do
--			local cjob = get_from_joblist(self,i)
--			print("MAYOR JOB", i, " = ", cjob.name)
--			end
--		end

--		if get_size_joblist(self) == 0 then 
--			print("NO JOB FOUND IN JOBLIST")
--			local newjob = {
--				name = "checkbuilds",
--				status = 0
--				}
--			add_to_joblist(self,newjob)
--
--		end
		 --print("walk speed = ", self.walk_speed)


		local current_job = get_from_joblist(self,1)

		if current_job.name == "morning" then 				
			do_morning_routine(self)				

		elseif current_job.name == "nothing" then
			--print("Doing Nothing")
			-- FIXME cheap fix to continue doing something instead of nothing
--			local cbuilds_job = {
--				["name"] = "checkbuilds",
--				["status"] = 0
--			}
--			add_to_joblist(self,cbuilds_job)
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

		elseif current_job.name == "checkmybed" then
			check_my_bed(self)

		elseif current_job.name == "sitdown" then
			sit_down(self)

		elseif current_job.name == "laydown" then
			lay_down(self)

		elseif current_job.name == "dositups" then
			do_situps(self)

		elseif current_job.name == "checkmyfire" then
			check_my_fire(self)

		elseif current_job.name == "checkmychest" then
			check_my_chest(self)

		elseif current_job.name == "walknorth" then 
			walk_north(self)

		elseif current_job.name == "minepit" then
			mine_pit(self)

		elseif current_job.name == "buildorchard" then
			build_orchard(self)

		elseif current_job.name == "farmerfarm" then
			farmer_farm(self)

		elseif current_job.name == "beenpunched" then
			been_punched(self)

		elseif current_job.name == "hirebuilder" then 
			hire_a_builder(self)

		elseif current_job.name == "hireminer" then 
			hire_a_miner(self)

		elseif current_job.name == "hirelumberjack" then 
			hire_a_lumberjack(self)

		elseif current_job.name == "hiremedic" then 
			hire_a_medic(self)

		elseif current_job.name == "hirevet" then 
			hire_a_vet(self)

		elseif current_job.name == "hirefireman" then 
			hire_a_fireman(self)

		elseif current_job.name == "hirefarmer" then
			hire_a_farmer(self)

		elseif current_job.name == "hiregardener" then 
			hire_a_gardener(self)

		elseif current_job.name == "waitforbuildok" then
			wait_for_buildera_ok(self)

		elseif current_job.name == "waitforbuildfinished" then
			waitforbuildtofinish(self)

		elseif current_job.name == "gotohome" then
			goto_myhome(self)


		elseif current_job.name == "lookatfire" then
			look_at_fire(self)



		elseif current_job.name == "movein1" then
			move_in_1(self)

		elseif current_job.name == "checkname" then
			check_my_name(self)

		elseif current_job.name == "startbuild" then
			start_building(self)

		elseif current_job.name == "continuebuild" then
			continue_building(self)

		elseif current_job.name == "clearbuild" then
			gardener_clear_building(self)

		elseif current_job.name == "signoffbuild" then	
			signoff_building(self)

		elseif current_job.name == "checkjobpos" then
			check_my_jobpos(self)

		elseif current_job.name == "phonebuilderbuild" then
			continue_building(self)

		elseif current_job.name == "waitfor" then
			wait_for_time(self) 

		elseif current_job.name == "checkbuildsite" then 
			check_build_site(self) 

		elseif current_job.name == "checkbuilds" then
			check_the_buildings(self)
			--print("UP TO CHECK BUILDS")
			--check_for_buildings(self)
			--coroutine.yield(co_command.pause,"Check Builds\n")
		elseif current_job.name == "gotohere" then
			auto_go(self)

		else
			-- ERROR HERE = UNKNOWN JOB
			print("DUMP UNKNOWN JOB = ", dump(current_job.name))
			coroutine.yield(co_command.pause,"ERROR FOUND A JOB I DO NOT KNOW\n")
		end

	end
})
