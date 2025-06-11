local func = {}
local pathfinder = simple_working_villages.require("pathfinder")


-- TODO this is a very quick inter NPC messaging service

local builder_a_message = nil
function func.set_builder_a_message(inmsg)
	builder_a_message = inmsg
	--print("DEBUG: SETMSG = ", dump(inmsg))
end
function func.get_builder_a_message()
	return builder_a_message
end


local lumberjack_a_message = nil
function func.set_lumberjack_a_message(inmsg)
	lumberjack_a_message = inmsg
	--print("DEBUG: SET LUMBERJACK MSG = ", dump(inmsg))
end
function func.get_lumberjack_a_message()
	return lumberjack_a_message
end


local miner_a_message = nil
function func.set_miner_a_message(inmsg)
	miner_a_message = inmsg
	--print("DEBUG: SET MINER MSG = ", dump(inmsg))
end
function func.get_miner_a_message()
	return miner_a_message
end

local farmer_a_message = nil
function func.set_farmer_a_message(inmsg)
	farmer_a_message = inmsg
	print("DEBUG: SET FARMER MSG = ", dump(inmsg))
end
function func.get_farmer_a_message()
	return farmer_a_message
end


local gardener_a_message = nil
function func.set_gardener_a_message(inmsg)
	gardener_a_message = inmsg
	print("DEBUG: SET GARDENER MSG = ", dump(inmsg))
end
function func.get_gardener_a_message()
	return gardener_a_message
end


local medic_a_message = nil
function func.set_medic_a_message(inmsg)
	medic_a_message = inmsg
	print("DEBUG: SET MEDIC MSG = ", dump(inmsg))
end
function func.get_medic_a_message()
	return medic_a_message
end

local fireman_a_message = nil
function func.set_fireman_a_message(inmsg)
	fireman_a_message = inmsg
	print("DEBUG: SET fireman MSG = ", dump(inmsg))
end
function func.get_fireman_a_message()
	return fireman_a_message
end




local vet_a_message = nil
function func.set_vet_a_message(inmsg)
	vet_a_message = inmsg
	print("DEBUG: SET VET MSG = ", dump(inmsg))
end
function func.get_vet_a_message()
	return vet_a_message
end




local town_gravel_chest_loc = nil
local town_dirt_chest_loc = nil
local town_sand_chest_loc = nil
local town_wood_chest_loc = nil
function has_town_chest(intype)
	if intype == "default:gravel" then
		return town_gravel_chest_loc
	elseif intype == "default:dirt" then
		return town_dirt_chest_loc
	elseif intype == "default:sand" then
		return town_sand_chest_loc
	elseif intype == "default:wood" then
		return town_wood_chest_loc
	end
end






local entitys = {
	names = {

		-- NOT REAL WORLD -- IGNORE
		["visual_harm_1ndicators:hpbar"]={dummy=true},
		["simple_working_villages:dummy_item"]={dummy=true},
		["__builtin:item"]={dummy=true},

		-- WORKING VILLAGES NPCS
		-- TODO add new working villages characters
		["simple_working_villages:villager_male"]={npc=true, block=true},
		["simple_working_villages:villager_female"]={npc=true, block=true},
		["mobs_npc:npc"]={npc=true, block=true},
		["mobs_npc:igor"]={npc=true, block=true},
		["mobs_npc:trader"]={npc=true, block=true},

		-- MOBS MONSTERS 
		["mobs_monster:dirt_monster"]={monster=true, block=true},
		["mobs_monster:fire_spirit"]={monster=true, block=true},
		["mobs_monster:land_guard"]={monster=true, block=true},
		["mobs_monster:lava_flan"]={monster=true, block=true},
		["mobs_monster:mese_monster"]={monster=true, block=true},
		["mobs_monster:obsidian_flan"]={monster=true, block=true},
		["mobs_monster:oerkki"]={monster=true, block=true},
		["mobs_monster:sand_monster"]={monster=true, block=true},
		["mobs_monster:spider"]={monster=true, block=true},
		["mobs_monster:stone_monster"]={monster=true, block=true},
		["mobs_monster:tree_monster"]={monster=true, block=true},

		-- MOBS SKELETONS
		["mobs_skeletons:skeleton_archer"]={monster=true, block=true},
		["mobs_skeletons:skeleton_archer_dark"]={monster=true, block=true},
		["mobs_skeletons:skeleton"]={monster=true, block=true},

		-- MOB ANIMALS
		["mobs_animal:sheep_"]={animal=true, block=true},
		["mobs_animal:pumba"]={animal=true, block=true},
		["mobs_animal:chicken"]={animal=true, block=true},
		["mobs_animal:panda"]={animal=true, block=true},
		["mobs_animal:penguin"]={animal=true, block=true},
		["mobs_animal:bunny"]={animal=true, block=true},
		["mobs_animal:bee"]={animal=true, block=true},
		["mobs_animal:cow"]={animal=true, block=true},
		["mobs_animal:kitten"]={animal=true, block=true},
		["mobs_animal:rat"]={animal=true, block=true},

	},
}



function func.get_entity(entity_name)
	for key, value in pairs(entitys.names) do
		--if entity_name==key then
--		print("looking for ", key, " in ", entity_name)	
		--if string.find(key,entity_name) then
		if string.find(entity_name,key) then
--			print("found ", key, " in ", entity_name)	
			return value
		end
	end
	return nil
end




















function func.get_goto_distance_check(pos,dest)
	local tempx = 0
	local tempz = 0
	local tempy = 0
	--print("GET_GOTO_CHECK ", pos, " to ", dest)
	if pos.x < dest.x then 
		tempx = dest.x - pos.x
	else
		tempx = pos.x - dest.x 
	end
	if pos.z < dest.z then 
		tempz = dest.z - pos.z
	else
		tempz = pos.z - dest.z 
	end
	if pos.y < dest.y then 
		tempy = dest.y - pos.y
	else
		tempy = pos.y - dest.y 
	end
	--print("X:",tempx," Y:", tempy, " Z:", tempz)
	if tempx < 0.1 and tempz < 0.1 and tempy < 1.1 then
		return true
	else
		return false
	end
end



function func.get_closest_clear_spot(from_pos, topos)


-- TODO FIXME THIS HAS GOT TO BE REDONE !!
-- DIAGANALS HAVE TO BE ADDED 

	--local from_pos = vector.round(frompos)
--	local from_pos = frompos
--	print("GET CLOSEST SPOT TO ",topos)
	local temppos = nil
--	print("FROM ",from_pos)
--	print("TEMPPOS=",temppos)
	
	local my_n = vector.add(topos,vector.new(0,0,1)) 
	local my_e = vector.add(topos,vector.new(1,0,0)) 
	local my_s = vector.add(topos,vector.new(0,0,-1))
	local my_w = vector.add(topos,vector.new(-1,0,0))

	local distance = 1000 -- set high for now TODO correctly later
	
	if pathfinder.check_movement_to_pos(my_n) ~= nil then
		local distance_from = vector.distance(from_pos,my_n)
		if distance_from < distance then 
			distance = distance_from
			temppos = my_n
--			print("north selected as best choice")
		end
--		print("north ok ", my_n, " DIST= ", distance_from)
	end
--	else print("north blocked", my_n) end

--	print("TEMPPOS=",temppos)

	if pathfinder.check_movement_to_pos(my_s) ~= nil then
		local distance_from = vector.distance(from_pos,my_s)
		if distance_from < distance then 
			distance = distance_from
			temppos = my_s
--			print("south selected as best choice")
		end
--		print("south ok", my_s, " DIST= ", distance_from)
--	else print("south blocked", my_s) end
	end

--	print("TEMPPOS=",temppos)

	if pathfinder.check_movement_to_pos(my_e) ~= nil then
		local distance_from = vector.distance(from_pos,my_e)
		if distance_from < distance then 
			distance = distance_from
			temppos = my_e
--			print("east selected as best choice")
		end
--		print("east ok", my_e, " DIST= ", distance_from)
--	else print("east blocked", my_e) end
	end

--	print("TEMPPOS=",temppos)

	if pathfinder.check_movement_to_pos(my_w) ~= nil then
		local distance_from = vector.distance(from_pos,my_w)
		if distance_from < distance then 
			distance = distance_from
			temppos = my_w
--			print("west selected as best choice")
		end
--		print("west ok", my_w, " DIST= ", distance_from)
--	else print("west blocked", my_w) end
	end

--	print("TEMPPOS=",temppos)

	return temppos

end





function func.find_path_toward(pos,villager)
  local dest = vector.round(pos)
  --TODO: spiral outward from pos and try to find reverse paths
  if func.walkable_pos(dest) then
    dest = pathfinder.get_ground_level(dest)
  end
  local val_pos = func.validate_pos(villager.object:get_pos())
  --FIXME: this also reverses jump height and fear height
  local _,rev = pathfinder.find_path(dest, val_pos, villager)
  return rev
end

--TODO:this is used as a workaround
-- it has to be replaced by routing
--  to the nearest possible position
function func.find_ground_below(position)
  local pos = vector.new(position)
  local height = 0
  local node
  repeat
      height = height + 1
      pos.y = pos.y - 1
      node = minetest.get_node(pos)
      if height > 10 then
        return false
      end
  until pathfinder.walkable(node)
  pos.y = pos.y + 1
  return pos
end

function func.validate_pos(pos)
  local resultp = vector.round(pos)
  local node = minetest.get_node(resultp)
  if minetest.registered_nodes[node.name].walkable then
    resultp = vector.subtract(pos, resultp)
    resultp = vector.round(resultp)
    resultp = vector.add(pos, resultp)
    return vector.round(resultp)
  else
    return resultp
  end
end

--TODO: look in pathfinder whether defining this is even nessecary
function func.clear_pos(pos)
	local node=minetest.get_node(pos)
	local above_node=minetest.get_node({x=pos.x,y=pos.y+1,z=pos.z})
	local above_above_node=minetest.get_node({x=pos.x,y=pos.y+2,z=pos.z})
	return not(pathfinder.walkable(node) or pathfinder.walkable(above_node) or pathfinder.walkable(above_above_node))
end

function func.walkable_pos(pos)
	local node=minetest.get_node(pos)
	return pathfinder.walkable(node)
end

function func.find_adjacent_clear(pos)
  if not pos then error("didn't get a position") end
	local found = func.find_adjacent_pos(pos,func.clear_pos)
	if found~=false then
		return found
	end
	found = vector.add(pos,{x=0,y=-2,z=0})
	if func.clear_pos(found) then
		return found
	end
	return false

end



function func.find_building_marker(pos,dist_xz,dist_y)

--minetest.registered_nodes[]
local locresult = nil

local pos1       = vector.subtract(pos, { x = dist_xz, z = dist_xz, y = dist_y })
local pos2       = vector.add(pos, { x = dist_xz, z = dist_xz, y = dist_y })
local pos_list   = core.find_nodes_in_area(pos1, pos2, { "simple_working_villages:building_marker" })

if pos_list == nil then return nil end

--local minx = pos.x - dist_xyz
--local miny = pos.y - dist_xyz
--local minz = pos.z - dist_xyz
--local maxx = pos.x + dist_xyz
--local maxy = pos.y + dist_xyz
--local maxz = pos.z + dist_xyz


--for i=1, #pos_list do
--    local delta = vector.subtract(pos_list[i], pos)
--    if delta.x*delta.x + delta.y*delta.y + delta.z*delta.z <= 5*5 then
        return pos_list
--    end
--end

end



local find_adjacent_clear = func.find_adjacent_clear

-- search in an expanding box around pos in the XZ plane
-- first hit would be closest
local function search_surrounding(pos, pred, searching_range)


if pos ~= nil then 

	pos = vector.round(pos)
	local max_xz = math.max(searching_range.x, searching_range.z)
	local mod_y
	if searching_range.h == nil then
		if searching_range.y > 5 then
			mod_y = 6
		else
			mod_y = 0
		end
	else
		mod_y = searching_range.h
	end

	local ret = {}

	local function check_column(dx, dz)
		if ret.pos ~= nil then return end
		for j = mod_y - searching_range.y, searching_range.y do
			local p = vector.add({x = dx, y = j, z = dz}, pos)
			if pred(p) and find_adjacent_clear(p)~=false then
				ret.pos = p
				return
			end
		end
	end

	for i = 0, max_xz do
		for k = 0, i do
			-- hit the 8 points of symmetry, bound check and skip duplicates
			if k <= searching_range.x and i <= searching_range.z then
				check_column(k, i)
				if i > 0 then
					check_column(k, -i)
				end
				if k > 0 then
					check_column(-k, i)
					if k ~= i then
						check_column(-k, -i)
					end
				end
			end

			if i <= searching_range.x and k <= searching_range.z then
				if i > 0 then
					check_column(-i, k)
				end
				if k ~= i then
					check_column(i, k)
					if k > 0 then
						check_column(-i, -k)
						check_column(i, -k)
					end
				end
			end
			if ret.pos ~= nil then
				break
			end
		end
	end
	return ret.pos
end

end

func.search_surrounding = search_surrounding

function func.find_adjacent_pos(pos,pred)
	local dest_pos
	if pred(pos) then
		return pos
	end
	dest_pos = vector.add(pos,{x=0,y=1,z=0})
	if pred(dest_pos) then
		return dest_pos
	end
	dest_pos = vector.add(pos,{x=0,y=-1,z=0})
		if pred(dest_pos) then
		return dest_pos
	end
	dest_pos = vector.add(pos,{x=1,y=0,z=0})
	if pred(dest_pos) then
		return dest_pos
	end
	dest_pos = vector.add(pos,{x=-1,y=0,z=0})
	if pred(dest_pos) then
		return dest_pos
	end
	dest_pos = vector.add(pos,{x=0,y=0,z=1})
	if pred(dest_pos) then
		return dest_pos
	end
	dest_pos = vector.add(pos,{x=0,y=0,z=-1})
	if pred(dest_pos) then
		return dest_pos
	end
	return false
end

-- Activating owner griefing settings departs from the documented behavior
-- of the protection system, and may break some protection mods.
local owner_griefing = minetest.settings:get(
    "simple_working_villages_owner_protection")
local owner_griefing_lc = owner_griefing and string.lower(owner_griefing)

if not owner_griefing or owner_griefing_lc == "false" then
    -- Villagers may not grief in protected areas.
    func.is_protected_owner = function(_, pos) -- (owner, pos)
        return minetest.is_protected(pos, "")
    end

else if owner_griefing_lc == "true" then
    -- Villagers may grief in areas protected by the owner.
    func.is_protected_owner = function(owner, pos)
        local myowner = owner or ""
        if myowner == "simple_working_villages:self_employed" then
            myowner = ""
        end
        return minetest.is_protected(pos, myowner)
    end

else if owner_griefing_lc == "ignore" then
    -- Villagers ignore protected areas.
    func.is_protected_owner = function() return false end

else
    -- Villagers may grief in areas where "[owner_protection]:[owner_name]" is allowed.
    -- This makes sense with protection mods that grant permission to
    -- arbitrary "player names."
    func.is_protected_owner = function(owner, pos)
        local myowner = owner or ""
        if myowner == "" then
            myowner = ""
        else
            myowner = owner_griefing..":"..myowner
        end
        return minetest.is_protected(pos, myowner)
    end

    -- Patch areas to support this extension
    local prefixlen = #owner_griefing
    local areas = rawget(_G, "areas")
    if areas then
        local areas_player_exists = areas.player_exists
        function areas.player_exists(area, name)
            local myname = name
            if string.sub(name,prefixlen+1,prefixlen+1) == ":"
                    and string.sub(name,prefixlen+2)
                    and string.sub(name,1,prefixlen) == owner_griefing then
                myname = string.sub(name,prefixlen+2)
                if myname == "simple_working_villages:self_employed" then
                    return true
                end
            end
            return areas_player_exists(area, myname)
        end
    end
end end end -- else else else

function func.is_protected(self, pos)
    return func.is_protected_owner(self.owner_name, pos)
end

-- chest manipulation support functions
function func.is_chest(pos)
	local node = minetest.get_node(pos)
  if (node==nil) then
    return false;
  end
  if node.name=="default:chest" then
    return true;
  end
  local is_chest = minetest.get_item_group(node.name, "chest");
  if (is_chest~=0) then
    return true;
  end
  return false;
end

return func
