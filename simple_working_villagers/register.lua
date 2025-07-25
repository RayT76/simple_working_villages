

-- TODO to make the NPC's have a little personal character the following values may be defined

	-- name		= name of the NPC Character
	-- visible	= if the character appears in the inventory menu
	-- start_job	= default job for the NPC
	-- wakeup_time	= time of day the NPC wakes
	-- work_time	= time of day the NPC starts work
	-- stop_time	= time of day the NPC stops work
	-- bed_time	= time of day the NPC goes to bed
	-- walk_speed	= walking speed of the NPC
	-- run_speed	= running speed of the NPC
	-- size_x	= size (width) of the NPC
	-- size_y	= size (height) of the NPC -- may reduce to one value called scale
	-- hp_max	= max hp for the NPC
	-- weight	= weight of the NPC
	-- mesh		= mesh used by the NPC
	-- textures	= texture used by the NPC
	-- egg_image	= egg image for the NPC


    -- dayoff
    -- hobby 

	-- TODO

	-- animation speed


	-- build_speed	= building speed of the NPC
	-- nightworker	= day or night worker

	-- and other information to make characters unique



-- WANTED CHARACTERS

-- Mayor
	-- Brings the items to start a town
	-- Hires builder and lays the town plans

-- Builder
	-- Builds all the Buildings in the Town

-- GrassCutter -- landscaper ? should be gardener !!
	-- Clears Grass and Debry from plots

-- Lumberjack
	-- Cuts down and saves Raw materials

-- Teacher
	-- Brings Books and items for new school
	-- Keeps kids in school for daytimes

-- Farmer
	-- Farms and replants Crops

-- Guard / Police
	-- Guards areas or does walkarounds ?

-- Miner
	-- mines for ores, sands and Rocks

-- Medic

-- Vet

-- Collector

-- Fireman

-- Librarian

-- shopkeeper

-- pool attendent

-- Carpenter

-- Sheep Shepard




local product_name = "simple_working_villages:villager_male_mayor_a"
local texture_namea = {"villager_male_mayor_a.png","villager_male_mayor_a0.png"}
--local texture_nameb = "villager_male_mayor_a0.png"
local egg_img_name = "simple_villager_egg.png"
simple_working_villages.register_villager(product_name, {
	name = "Mike Mayor",
	visible = true,
	start_job = "simple_working_villages:job_mayor_a",
	wakeup_time = 0.24,
	work_time = 0.291,
	stop_time = 0.69,
	bed_time = 0.875,
	walk_speed = 2.6,
	run_speed = 3.3,
	size_x = 1,
	size_y = 1.1,
	hp_max     = 30,
	weight     = 20,
	mesh       = "character.b3d",
	textures   = texture_namea,
	egg_image  = egg_img_name,
})

local product_name = "simple_working_villages:villager_male_builder_a"
local texture_name = "villager_male_builder_a.png"
local egg_img_name = "simple_villager_egg.png"
simple_working_villages.register_villager(product_name, {
	name = "Bob Builder",
	visible = false,
	start_job = "simple_working_villages:job_builder_a",
	wakeup_time = 0.26,
	work_time = 0.291,
	stop_time = 0.72,
	bed_time = 0.87,
	walk_speed = 2.3,
	run_speed = 3,
	size_x = 1.2,
	size_y = 0.95,
	hp_max     = 30,
	weight     = 20,
	mesh       = "character.b3d",
	textures   = {texture_name},
	egg_image  = egg_img_name,
})

local product_name = "simple_working_villages:villager_male_lumberjack_a"
local texture_name = "villager_male_lumberjack_a.png"
local egg_img_name = "simple_villager_egg.png"
simple_working_villages.register_villager(product_name, {
	name = "Larry Lumberjack",
	visible = false,
	start_job = "simple_working_villages:job_lumberjack_a",
	wakeup_time = 0.27,
	work_time = 0.291,
	stop_time = 0.69,
	bed_time = 0.88,
	walk_speed = 1.8,
	run_speed = 2.5,
	size_x = 1.1,
	size_y = 1.1,
	hp_max     = 30,
	weight     = 20,
	mesh       = "character.b3d",
	textures   = {texture_name},
	egg_image  = egg_img_name,
})


local product_name = "simple_working_villages:villager_male_miner_a"
local texture_name = "villager_male_miner_a.png"
local egg_img_name = "simple_villager_egg.png"
simple_working_villages.register_villager(product_name, {
	name = "Doug Digger",
	visible = false,
	start_job = "simple_working_villages:job_miner_a",
	wakeup_time = 0.25,
	work_time = 0.291,
	stop_time = 0.75,
	bed_time = 0.84,
	walk_speed = 1.7,
	dig_delay = 15,
	build_delay = 100,
	run_speed = 2.2,
	size_x = 0.9,
	size_y = 0.9,
	hp_max     = 30,
	weight     = 20,
	mesh       = "character.b3d",
	textures   = {texture_name},
	egg_image  = egg_img_name,
})


local product_name = "simple_working_villages:villager_male_farmer_a"
local texture_name = "villager_male_farmer.png"
local egg_img_name = "simple_villager_egg.png"
simple_working_villages.register_villager(product_name, {
	name = "Fred Farmer",
	visible = false,
	start_job = "simple_working_villages:job_farmer_a",
	wakeup_time = 0.255,
	work_time = 0.291,
	stop_time = 0.78,
	bed_time = 0.882,
	walk_speed = 2,
	run_speed = 3,
	hp_max     = 30,
	weight     = 20,
	mesh       = "character.b3d",
	textures   = {texture_name},
	egg_image  = egg_img_name,
})


local product_name = "simple_working_villages:villager_male_gardener_a"
local texture_name = "villager_male_lawnmower.png"
local egg_img_name = "simple_villager_egg.png"
simple_working_villages.register_villager(product_name, {
	name = "Garry Gardener",
	visible = false,
	start_job = "simple_working_villages:job_grass_cutter",
	wakeup_time = 0.245,
	work_time = 0.291,
	stop_time = 0.78,
	bed_time = 0.883,
	walk_speed = 1.9,
	run_speed = 3,	hp_max     = 30,
	weight     = 20,
	mesh       = "character.b3d",
	textures   = {texture_name},
	egg_image  = egg_img_name,
})



local product_name = "simple_working_villages:villager_male_medic"
local texture_name = "villager_male_medic.png"
local egg_img_name = "simple_villager_egg.png"
simple_working_villages.register_villager(product_name, {
	name = "Marvin Medic",
	visible = false,
	start_job = "simple_working_villages:job_medic",
	wakeup_time = 0.264,
	work_time = 0.291,
	stop_time = 0.78,
	bed_time = 0.86,
	walk_speed = 2.6,
	run_speed = 3,	
    hp_max     = 30,
	weight     = 20,
	mesh       = "character.b3d",
	textures   = {texture_name},
	egg_image  = egg_img_name,
})


local product_name = "simple_working_villages:villager_male_vet"
local texture_name = "villager_male_vet.png"
local egg_img_name = "simple_villager_egg.png"
simple_working_villages.register_villager(product_name, {
	name = "Victor Vet",
	visible = false,
	start_job = "simple_working_villages:job_vet",
	wakeup_time = 0.253,
	work_time = 0.291,
	stop_time = 0.78,
	bed_time = 0.885,
	walk_speed = 2.3,
	run_speed = 3,	
    hp_max     = 30,
	weight     = 20,
	mesh       = "character.b3d",
	textures   = {texture_name},
	egg_image  = egg_img_name,
})

local product_name = "simple_working_villages:villager_male_fireman"
local texture_name = "villager_male_fireman.png"
local egg_img_name = "villager_male_egg.png"
simple_working_villages.register_villager(product_name, {
	name = "Frank Fireman",
	visible = false,
	start_job = "simple_working_villages:job_fireman",
	wakeup_time = 0.266,
	work_time = 0.291,
	stop_time = 0.78,
	bed_time = 0.89,
	walk_speed = 2.6,
	run_speed = 3,	
    hp_max     = 30,
	weight     = 20,
	mesh       = "character.b3d",
	textures   = {texture_name},
	egg_image  = egg_img_name,
})



local product_name = "simple_working_villages:villager_male_grasscutter"
local texture_name = "villager_male_lawnmower.png"
local egg_img_name = "villager_male_egg.png"
simple_working_villages.register_villager(product_name, {
	name = "Gene Grass",
	visible = false,
	start_job = "simple_working_villages:job_grasscutter",
	wakeup_time = 0.282,
	work_time = 0.291,
	stop_time = 0.78,
	bed_time = 0.889,
	walk_speed = 1.8,
	run_speed = 3,	
    hp_max     = 30,
	weight     = 20,
	mesh       = "character.b3d",
	textures   = {texture_name},
	egg_image  = egg_img_name,
})

local product_name = "simple_working_villages:villager_male_plantcollector"
local texture_name = "villager_male_plantcollector.png"
local egg_img_name = "villager_male_egg.png"
simple_working_villages.register_villager(product_name, {
	name = "Peter Plant",
	visible = false,
	start_job = "simple_working_villages:job_plantcollector",
	wakeup_time = 0.258,
	work_time = 0.291,
	stop_time = 0.78,
	bed_time = 0.885,
	walk_speed = 1.8,
	run_speed = 3,	
    hp_max     = 30,
	weight     = 20,
	mesh       = "character.b3d",
	textures   = {texture_name},
	egg_image  = egg_img_name,
})


local product_name = "simple_working_villages:villager_male_guard"
local texture_name = "villager_male_police.png"
local egg_img_name = "villager_male_egg.png"
simple_working_villages.register_villager(product_name, {
	name = "Gerald Guard",
	visible = false,
	start_job = "simple_working_villages:job_guard",
	wakeup_time = 0.24,
	work_time = 0.291,
	stop_time = 0.78,
	bed_time = 0.885,
	walk_speed = 2.2,
	run_speed = 3,	
    hp_max     = 30,
	weight     = 20,
	mesh       = "character.b3d",
	textures   = {texture_name},
	egg_image  = egg_img_name,
})
