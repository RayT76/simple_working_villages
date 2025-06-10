local init = os.clock()
minetest.log("action", "["..minetest.get_current_modname().."] loading init")

simple_working_villages={
	modpath = minetest.get_modpath("simple_working_villages"),
}

if not minetest.get_modpath("modutil") then
	print("INIT: LOADING LOCAL MODUTIL")
	dofile(simple_working_villages.modpath.."/modutil/portable.lua")
else
	print("INIT: LOADING MODUTIL")
end


modutil.require("local_require")(simple_working_villages)
local log = simple_working_villages.require("log")

function simple_working_villages.setting_enabled(name, default)
  local b = minetest.settings:get_bool("simple_working_villages_enable_"..name)
  if b == nil then
    if default == nil then
      return false
    end
    return default
  end
  return b
end

simple_working_villages.require("groups")
--TODO: check for which preloading is needed
--content
simple_working_villages.require("forms")
simple_working_villages.require("talking")
--TODO: instead use the building sign mod when it is ready
simple_working_villages.require("building")
simple_working_villages.require("storage")

--base

simple_working_villages.require("api")
simple_working_villages.require("register")
simple_working_villages.require("commanding_sceptre")
simple_working_villages.require("deprecated")

--job helpers
simple_working_villages.require("jobs/util")
simple_working_villages.require("jobs/empty")

--base jobs
simple_working_villages.require("jobs/builder")
simple_working_villages.require("jobs/builder_a")


simple_working_villages.require("jobs/lumberjack_a")
simple_working_villages.require("jobs/miner_a")
simple_working_villages.require("jobs/mayor_a")
simple_working_villages.require("jobs/farmer_a")

simple_working_villages.require("jobs/follow_player")
simple_working_villages.require("jobs/guard")
simple_working_villages.require("jobs/plant_collector")
simple_working_villages.require("jobs/farmer")
simple_working_villages.require("jobs/woodcutter")
simple_working_villages.require("jobs/gardener_a")


--testing jobs
simple_working_villages.require("jobs/torcher")
simple_working_villages.require("jobs/snowclearer")


simple_working_villages.require("jobs/fireman")
simple_working_villages.require("jobs/grass_cutter")

simple_working_villages.require("jobs/medic")
simple_working_villages.require("jobs/vet")

print("SIMPLE_simple_working_villages_INIT:")


--local pname = user:get_player_name()
--print("Player name : ", pname)
--local inv = minetest.get_inventory({type="player", name=pname})
--print("Player inventory = ", dump(inv))

--local startnode = core.get_node(vector.new{ x = 0, y = 0, z = 0 })
--local startnode = minetest.get_node(vector.new{ x = 0, y = 0, z = 0 })
--if startnode ~= nil then 
--	print(dump(startnode)) --> { name=.., param1=.., param2=.. }
--else
--	print("START NODE = NIL") --> { name=.., param1=.., param2=.. }
--end
--print("END:SIMPLE_simple_working_villages_INIT:")


if simple_working_villages.setting_enabled("spawn",false) then
  simple_working_villages.require("spawn")
end

if simple_working_villages.setting_enabled("debug_tools",false) then
  simple_working_villages.require("util_test")
end

--ready
local time_to_load= os.clock() - init
log.action("loaded init in %.4f s", time_to_load)

