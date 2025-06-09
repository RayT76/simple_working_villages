local func = working_villages.require("jobs/util")
local log = working_villages.require("log")

local function spawner(initial_job)
    return function(pos, _, _, active_object_count_wider)
               --  (pos, node, active_object_count, active_object_count_wider)
        if active_object_count_wider > 1 then return end
        if func.is_protected_owner("working_villages:self_employed",pos) then
            return
        end

        local pos1 = {x=pos.x-4,y=pos.y-8,z=pos.z-4}
        local pos2 = {x=pos.x+4,y=pos.y+1,z=pos.z+4}
        for _,p in ipairs(minetest.find_nodes_in_area_under_air(
                pos1,pos2,"group:soil")) do
            local above = minetest.get_node({x=p.x,y=p.y+2,z=p.z})
            local above_def = minetest.registered_nodes[above.name]
            if above_def and not above_def.groups.walkable then
                log.action("Spawning a %s at %s", initial_job, minetest.pos_to_string(p,0))
                local gender = {
                    "working_villages:villager_male",
                    "working_villages:villager_female",
                }
                local new_villager = minetest.add_entity(
                    {x=p.x,y=p.y+1,z=p.z},gender[math.random(2)], ""
                )
                local entity = new_villager:get_luaentity()
                entity.new_job = initial_job
                entity.owner_name = "working_villages:self_employed"
                entity:update_infotext()
                return
            end
        end
    end
end

working_villages.require("jobs/plant_collector")

local herb_names = {}
for name,_ in pairs(working_villages.herbs.names) do
    herb_names[#herb_names + 1] = name
end
for name,_ in pairs(working_villages.herbs.groups) do
    herb_names[#herb_names + 1] = "group:"..name
end

minetest.register_abm({
    label = "Spawn herb collector",
    nodenames = herb_names,
    neighbors = "air",
    interval = 60,
    chance = 2048,
    catch_up = false,
    action = spawner("working_villages:job_herbcollector"),
})

minetest.register_abm({
    label = "Spawn woodcutter",
    nodenames = "group:tree",
    neighbors = "air",
    interval = 60,
    chance = 2048,
    catch_up = false,
    action = spawner("working_villages:job_woodcutter"),
})

