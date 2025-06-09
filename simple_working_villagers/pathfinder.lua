local pathfinder = {}


-- TODO I do not think these are needed as the results are returned to the calling function on exit
-- Another issue is the fact that these functions and memory are shared between the NPCS


local proposed_path = {}
local the_path = {}


local function find_ground_below(position)
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
--  until pathwalkable(node)
  pos.y = pos.y + 1
  return pos
end




function pathfinder.check_movement_to_pos(pos, can_fall)

	local debug = false
--	if (pos.x == 64) and (pos.y == 16) and (pos.z == 65) then debug = true end


	local my_a = vector.add(pos,vector.new(0,-2,0)) -- below by two
	local my_b = vector.add(pos,vector.new(0,-1,0)) -- below by one
	-- pos = legs level
	local my_d = vector.add(pos,vector.new(0,1,0)) -- head level
	local my_e = vector.add(pos,vector.new(0,2,0)) -- directly above head

	local node_a = minetest.get_node(my_a)
	local node_b = minetest.get_node(my_b)
	local node_c = minetest.get_node(pos)
	local node_d = minetest.get_node(my_d)
	local node_e = minetest.get_node(my_e)


	if debug then print("DEBUG CHECKMOVEMENTTOPOS CHECKING POS = ", pos) end
	-- TODO needs a better check for doors --  check edit
	if doors.registered_doors[node_c.name] then
		--	if string.find(node_c.name,"doors:") then
		if debug then print("DOOR FOUND") end
		return pos
	end

	-- check for block in the face
	if minetest.registered_nodes[node_d.name].walkable then
		if debug then print("IN THE FACE") end
		return nil
	end


	-- check for steps
	if minetest.registered_nodes[node_c.name].walkable then
		-- but is there head room		
		if debug then print("STEP FOUND") end
		if minetest.registered_nodes[node_e.name].walkable then
			-- no head room
			if debug then print("NO ROOM TO STEP UP TO") end
			return nil
		else
			if debug then print("I CAN STEP UP") end
			return my_d

		end
	end



	if debug then print("I CAN WALK HERE AT THIS POINT") end
	-- I can walk here at this point


	if minetest.registered_nodes[node_b.name].walkable or pathfinder.walkable(node_b) then
		-- walk onto solid floor
		if debug then print("WALK ONTO SOLID FLOOR") end
		return pos
	else
		-- no solid floor but how far down
		if debug then print("NO SOLID FLOOR, BUT") end

		if string.find(node_b.name,"default:ladder") then
			if debug then print("I HAVE FOUND A LADDER.") end
			return pos
		end




		if minetest.registered_nodes[node_a.name].walkable then
			-- little drop but no biggie
			if debug then print("ONLY A STEP DOWN") end
			return my_b
		else
			if debug then print("NOT JUST A STEP DOWN") end
			-- nope, too far for me... i am scared of heights
			if can_fall then 
				-- TODO should get the ground-level below this point
				if debug then print("I AM ALLOWED TO FALL....  BUT") end
			end

--		if debug then print("GROUNDBELOW TEMPR = ", pos) end
--		local tempr = find_ground_below(pos)
--		if tempr == false then 
--			return nil
--		else
			if debug then print("ELSE GO DOWN TO ???") end
--			return my_a
		end
	end
end






local function check_movement_from_pos(pos, can_fall)

	local cfall = nil
	if can_fall == nil then
		cfall = false
	else
		cfall = can_fall
	end 


local debug = false
--if (pos.x == 64) and (pos.y == 16) and (pos.z == 65) then debug = true end
if debug then print("DEBUG CHECKMOVEMENTFROM ", pos) end

	local my_movement = {
				up = nil,
				down = nil,
				north = nil,
				south = nil,
				east = nil,
				west = nil,
				northeast = nil,
				northwest = nil,
				southeast = nil,
				southwest = nil,
	}

	local pos_leg = vector.round(pos)
	local pos_head = vector.add(pos_leg, vector.new(0,1,0)) -- directly below feet
	local pos_above = vector.add(pos_leg, vector.new(0,2,0)) -- directly above head
	local pos_below = vector.add(pos_leg, vector.new(0,-1,0)) -- directly below feet
	
	local pos_below_node = minetest.get_node(pos_below)
	local pos_leg_node = minetest.get_node(pos_leg)
	local pos_head_node = minetest.get_node(pos_head)
	local pos_above_node = minetest.get_node(pos_above)
	
	-- USED VECTORS	{+EAST/-WEST, UP/DOWN, +NORTH/-SOUTH}
	local pos_north = vector.add(pos_leg, vector.new(0,0,1));
	local pos_south = vector.add(pos_leg, vector.new(0,0,-1));
	local pos_east = vector.add(pos_leg, vector.new(1,0,0));
	local pos_west = vector.add(pos_leg, vector.new(-1,0,0));



	-- UP AND DOWN string.find(node.name,"default:ladder")
	if string.find(pos_leg_node.name,"default:ladder") then
		-- standing on a ladder
if debug then print("STANDING ON A LADDER") end

		-- TODO inserted this to bugcheck 		
		--if not(pos_above_node.walkable) then
			my_movement.up = pos_head
		--end

--		if string.find(pos_head_node.name,"default:ladder") then
--			-- I can climb as high as I jump
--			if string.find(pos_above_node.name,"default:ladder") or not(pos_above_node.walkable) then
--				-- I could climb up higher				
--			end
--		end


	end
	if string.find(pos_below_node.name,"default:ladder") then
		-- I could climb down
if debug then print("I COULD CLIMB DOWN") end
		my_movement.down = pos_below
	end
		
	-- check simple N S E W
	my_movement.north = pathfinder.check_movement_to_pos(pos_north,cfall)
	my_movement.south = pathfinder.check_movement_to_pos(pos_south,cfall)
	my_movement.east = pathfinder.check_movement_to_pos(pos_east,cfall)
	my_movement.west = pathfinder.check_movement_to_pos(pos_west,cfall)

	-- TODO 
	-- needs to check if jump is needed
	if pos_above_node.walkable or string.find(pos_above_node.name,"stairs:slab") then
--		print("ABOVE=SOLID ", pos_above_node.name)

--		print("check north")
		if my_movement.north ~= nil then
			if my_movement.north.y > pos_leg.y then
				my_movement.north = nil
			end
		end

--		print("check south")
		if my_movement.south ~= nil then
			if my_movement.south.y > pos_leg.y then
				my_movement.south = nil
			end
		end

--		print("check east")
		if my_movement.east ~= nil then
			if my_movement.east.y > pos_leg.y then
				my_movement.east = nil
			end
		end

--		print("check west")
		if my_movement.west ~= nil then
			if my_movement.west.y > pos_leg.y then
				my_movement.west = nil
			end
		end

--		print("finished check jump in check movement from pos ")
	else
--		print("ABOVE=NON-SOLID ", pos_above_node.name)
	end




--		print("check diag's ")

	-- FIXME check diag's
	if my_movement.north ~= nil then
		if my_movement.east ~= nil then
			my_movement.northeast = pathfinder.check_movement_to_pos(vector.add(pos_leg, vector.new(1,0,1)),cfall);
		end
		if my_movement.west ~= nil then
			my_movement.northwest = pathfinder.check_movement_to_pos(vector.add(pos_leg, vector.new(-1,0,1)),cfall);
		end
	end


	if my_movement.south ~= nil then
		if my_movement.east ~= nil then
			my_movement.southeast = pathfinder.check_movement_to_pos(vector.add(pos_leg, vector.new(1,0,-1)),cfall);
		end
		if my_movement.west ~= nil then
			my_movement.southwest = pathfinder.check_movement_to_pos(vector.add(pos_leg, vector.new(-1,0,-1)),cfall);
		end
	end
--		print("finished  check movement from pos")


--print("RETURN MY_MOVEMENT = ", dump(my_movement))
	return my_movement
end






local function plot_movement_index_lowest_cost(in_cost)
	local lowest_index = nil
	local cstart = in_cost * 2   -- should use the *2 so the NPC can go further away to enable finding path
	if cstart < 20 then cstart = 20 end
	for i, v in pairs(proposed_path) do
		--print("INDEX DATA:" , dump(v))
		if v.processed == false then
		--	print("v.hcost=",v.hcost);
			if v.hcost < cstart then 
				cstart = v.hcost
				lowest_index = i
			end
		end
	end
	return lowest_index
end

local function plot_movement_lowest_cost(in_cost)
	local lowest_cost = nil
	local cstart = in_cost * 2   -- should use the *2 so the NPC can go further away to enable finding path
	if cstart < 20 then cstart = 20 end
	for i, v in pairs(proposed_path) do
		if v.processed == false then
		--	print("v.hcost=",v.hcost);
			if v.hcost < cstart then
				cstart = v.hcost
				lowest_cost = v.hcost
			end
		end
	end
	return lowest_cost
end


local function plot_movement_lowest_cost_anyway(in_cost)

	local returndata = {
		["lcost"] = -1,
		["pos"] = -1,
	}
	local lowest_cost = nil
	local lowest_cost_pos = nil


	local cstart = in_cost * 2   -- should use the *2 so the NPC can go further away to enable finding path
	if cstart < 20 then cstart = 20 end
	for i, v in pairs(proposed_path) do
		--if v.processed == false then
		--	print("v.hcost=",v.hcost);
			if v.hcost < cstart then
				cstart = v.hcost
				lowest_cost = v.hcost
				lowest_cost_pos = v.pos
			end
		--end
	end

	returndata.lcost = lowest_cost
	returndata.pos = lowest_cost_pos


	return returndata
end





local function plot_movement_process_node(spos, step ,toendpos, can_fall)

	local cfall = false;
	if can_fall ~= nil then 
		cfall = can_fall
	end


--	print("PROCESS NODE START");
	local my_movement = check_movement_from_pos(spos, cfall)
--	print("POS = ", spos)
--	print("STEP = ", step)
--	print("TOPOS = ", toendpos)

	local node_hash = minetest.hash_node_position(spos)	
	proposed_path[node_hash].processed = true
	

	if my_movement.up ~= nil then
		local hash_index = minetest.hash_node_position(my_movement.up)
		if proposed_path[hash_index] == nil then
			-- have not been to node yet
			local node_cost = vector.distance(my_movement.up, toendpos)
			proposed_path[hash_index] = {hcost = node_cost, steps = step, parent = node_hash, pos = my_movement.up, processed = false}
		else
			-- have already been here -- check steps maybe
			
		end
	end

	if my_movement.down ~= nil then
		local hash_index = minetest.hash_node_position(my_movement.down)
		if proposed_path[hash_index] == nil then
			-- have not been to node yet
			local node_cost = vector.distance(my_movement.down, toendpos)
			proposed_path[hash_index] = {hcost = node_cost, steps = step, parent = node_hash, pos = my_movement.down, processed = false}
		else
			-- have already been here -- check steps maybe
			
		end
	end

	if my_movement.north ~= nil then
		local hash_index = minetest.hash_node_position(my_movement.north)
		if proposed_path[hash_index] == nil then
			-- have not been to node yet
			local node_cost = vector.distance(my_movement.north, toendpos)
			proposed_path[hash_index] = {hcost = node_cost, steps = step, parent = node_hash, pos = my_movement.north, processed = false}
		else
			-- have already been here -- check steps maybe
			
		end
	end

	if my_movement.south ~= nil then
		local hash_index = minetest.hash_node_position(my_movement.south)
		if proposed_path[hash_index] == nil then
			-- have not been to node yet
			local node_cost = vector.distance(my_movement.south, toendpos)
			proposed_path[hash_index] = {hcost = node_cost, steps = step, parent = node_hash, pos = my_movement.south, processed = false}
		else
			-- have already been here -- check steps maybe
			
		end
	end

	if my_movement.east ~= nil then
		local hash_index = minetest.hash_node_position(my_movement.east)
		if proposed_path[hash_index] == nil then
			-- have not been to node yet
			local node_cost = vector.distance(my_movement.east, toendpos)
			proposed_path[hash_index] = {hcost = node_cost, steps = step, parent = node_hash, pos = my_movement.east, processed = false}
		else
			-- have already been here -- check steps maybe
			
		end
	end

	if my_movement.west ~= nil then
		local hash_index = minetest.hash_node_position(my_movement.west)
		if proposed_path[hash_index] == nil then
			-- have not been to node yet
			local node_cost = vector.distance(my_movement.west, toendpos)
			proposed_path[hash_index] = {hcost = node_cost, steps = step, parent = node_hash, pos = my_movement.west, processed = false}
		else
			-- have already been here -- check steps maybe
			
		end
	end

	if my_movement.northeast ~= nil then
		local hash_index = minetest.hash_node_position(my_movement.northeast)
		if proposed_path[hash_index] == nil then
			-- have not been to node yet
			local node_cost = vector.distance(my_movement.northeast, toendpos)
			proposed_path[hash_index] = {hcost = node_cost, steps = step, parent = node_hash, pos = my_movement.northeast, processed = false}
		else
			-- have already been here -- check steps maybe
			
		end
	end

	if my_movement.northwest ~= nil then
		local hash_index = minetest.hash_node_position(my_movement.northwest)
		if proposed_path[hash_index] == nil then
			-- have not been to node yet
			local node_cost = vector.distance(my_movement.northwest, toendpos)
			proposed_path[hash_index] = {hcost = node_cost, steps = step, parent = node_hash, pos = my_movement.northwest, processed = false}
		else
			-- have already been here -- check steps maybe
			
		end
	end

	if my_movement.southwest ~= nil then
		--print("SOUTHWEST = ", dump(my_movement))
		local hash_index = minetest.hash_node_position(my_movement.southwest)
		if proposed_path[hash_index] == nil then
			-- have not been to node yet
			local node_cost = vector.distance(my_movement.southwest, toendpos)
			proposed_path[hash_index] = {hcost = node_cost, steps = step, parent = node_hash, pos = my_movement.southwest, processed = false}
		else
			-- have already been here -- check steps maybe
			
		end
	end

	if my_movement.southeast ~= nil then
		local hash_index = minetest.hash_node_position(my_movement.southeast)
		if proposed_path[hash_index] == nil then
			-- have not been to node yet
			local node_cost = vector.distance(my_movement.southeast, toendpos)
			proposed_path[hash_index] = {hcost = node_cost, steps = step, parent = node_hash, pos = my_movement.southeast, processed = false}
		else
			-- have already been here -- check steps maybe
			
		end
	end


end



local function walkable(node)
		if string.find(node.name,"doors:") then
			return false
--		elseif string.find(node.name,"default:ladder") then
--			return true
		elseif minetest.registered_nodes[node.name]~= nil then
			return minetest.registered_nodes[node.name].walkable
		else
			return true
		end
end




























--[[
minetest.get_content_id(name)
minetest.registered_nodes
minetest.get_name_from_content_id(id)
local ivm = a:index(pos.x, pos.y, pos.z)
local ivm = a:indexp(pos)
minetest.hash_node_position({x=,y=,z=})
minetest.get_position_from_hash(hash)

start_index, target_index, current_index
^ Hash of position

current_value
^ {int:hCost, int:gCost, int:fCost, hash:parent, vect:pos}
]]--


--print("loading pathfinder")

--TODO: route via climbable

local openSet = {}
local closedSet = {}

local function get_distance(start_pos, end_pos)
	local distX = math.abs(start_pos.x - end_pos.x)
	local distZ = math.abs(start_pos.z - end_pos.z)

	if distX > distZ then
		return 14 * distZ + 10 * (distX - distZ)
	else
		return 14 * distX + 10 * (distZ - distX)
	end
end

local function get_distance_to_neighbor(start_pos, end_pos)
	local distX = math.abs(start_pos.x - end_pos.x)
	local distY = math.abs(start_pos.y - end_pos.y)
	local distZ = math.abs(start_pos.z - end_pos.z)

	if distX > distZ then
		return (14 * distZ + 10 * (distX - distZ)) * (distY + 1)
	else
		return (14 * distX + 10 * (distZ - distX)) * (distY + 1)
	end
end



local function check_clearance(cpos, x, z, height) --TODO: this is unused
	for i = 1, height do
		local n_name = minetest.get_node({x = cpos.x + x, y = cpos.y + i, z = cpos.z + z}).name
		local c_name = minetest.get_node({x = cpos.x, y = cpos.y + i, z = cpos.z}).name
		--print(i, n_name, c_name)
		if walkable(n_name) or walkable(c_name) then
			return false
		end
	end
	return true
end

assert(check_clearance)

local function get_neighbor_ground_level(pos, jump_height, fall_height)
	local node = minetest.get_node(pos)
	local height = 0
	if walkable(node) then
		repeat
			height = height + 1
			if height > jump_height then
				return nil
			end
			pos.y = pos.y + 1
			node = minetest.get_node(pos)
		until not(walkable(node))
		return pos
	else
		repeat
			height = height + 1
			if height > fall_height then
				return nil
			end
			pos.y = pos.y - 1
			node = minetest.get_node(pos)
		until walkable(node)
		return {x = pos.x, y = pos.y + 1, z = pos.z}
	end
end

local function get_neighbors(current_pos, entity_height, entity_jump_height, entity_fear_height)
	local neighbors = {}
	local neighbors_index = 1
	for z = -1, 1 do
	for x = -1, 1 do
		local neighbor_pos = {x = current_pos.x + x, y = current_pos.y, z = current_pos.z + z}
		local neighbor = minetest.get_node(neighbor_pos)
		local neighbor_ground_level = get_neighbor_ground_level(neighbor_pos, entity_jump_height, entity_fear_height)
		local neighbor_clearance = false
		if neighbor_ground_level then
			-- print(neighbor_ground_level.y - current_pos.y)
			-- minetest.set_node(neighbor_ground_level, {name = "default:dry_shrub"})
			local node_above_head = minetest.get_node(
					{x = current_pos.x, y = current_pos.y + entity_height, z = current_pos.z})
			if neighbor_ground_level.y - current_pos.y > 0 and not(walkable(node_above_head)) then
				local height = -1
				repeat
					height = height + 1
					local node = minetest.get_node(
							{x = neighbor_ground_level.x,
							y = neighbor_ground_level.y + height,
							z = neighbor_ground_level.z})
				until walkable(node) or height > entity_height
				if height >= entity_height then
					neighbor_clearance = true
				end
			elseif neighbor_ground_level.y - current_pos.y > 0 and walkable(node_above_head) then
				neighbors[neighbors_index] = {
						hash = nil,
						pos = nil,
						clear = nil,
						walkable = nil,
				}
			else
				local height = -1
				repeat
					height = height + 1
					local node = minetest.get_node(
							{x = neighbor_ground_level.x,
							y = current_pos.y + height,
							z = neighbor_ground_level.z})
				until walkable(node) or height > entity_height
				if height >= entity_height then
					neighbor_clearance = true
				end
			end

			neighbors[neighbors_index] = {
					hash = minetest.hash_node_position(neighbor_ground_level),
					pos = neighbor_ground_level,
					clear = neighbor_clearance,
					walkable = walkable(neighbor),
			}
		else
			neighbors[neighbors_index] = {
					hash = nil,
					pos = nil,
					clear = nil,
					walkable = nil,
			}
		end
		neighbors_index = neighbors_index + 1
	end
	end
	return neighbors
end

--TODO: path to the nearest of multiple endpoints
-- or first path nearest to the endpoint

function pathfinder.find_path(pos, endpos, entity)
	--print("searching for a path to:" .. minetest.pos_to_string(endpos))
	local start_index = minetest.hash_node_position(pos)
	local target_index = minetest.hash_node_position(endpos)
	local count = 1

	openSet = {}
	closedSet = {}

	local h_start = get_distance(pos, endpos)
	openSet[start_index] = {hCost = h_start, gCost = 0, fCost = h_start, parent = nil, pos = pos}

	-- Entity values
	local entity_height = 2
	local entity_fear_height = 2
	local entity_jump_height = 1
	if entity then
		local collisionbox = entity.collisionbox or entity.initial_properties.collisionbox
		entity_height = math.ceil(collisionbox[5] - collisionbox[2])
		entity_fear_height = entity.fear_height or 2
		entity_jump_height = entity.jump_height or 1
	end

	repeat
		local current_index
		local current_values

		-- Get one index as reference from openSet
		current_index, current_values = next(openSet)

		-- Search for lowest fCost
		for i, v in pairs(openSet) do
			if v.fCost < openSet[current_index].fCost or v.fCost == current_values.fCost and v.hCost < current_values.hCost then
				current_index = i
				current_values = v
			end
		end

		openSet[current_index] = nil
		closedSet[current_index] = current_values
		count = count - 1

		if current_index == target_index then
			--print("Found path")
			local path = {}
			local reverse_path = {}
			repeat
				if not(closedSet[current_index]) then
					return {endpos} --was empty return
				end
				table.insert(path, closedSet[current_index].pos)
				current_index = closedSet[current_index].parent
				if #path > 100 then
					--print("path to long")
					return
				end
			until start_index == current_index
			for _,wp in pairs(path) do
				table.insert(reverse_path, 1, wp)
			end
			if #path ~= #reverse_path then
			 print("path's length is "..#path.." but reverse path has length "..#reverse_path)
			end
			--print("path length: "..#reverse_path)
			return reverse_path,path
		end

		local current_pos = current_values.pos

		local neighbors = get_neighbors(current_pos, entity_height, entity_jump_height, entity_fear_height)

		for id, neighbor in pairs(neighbors) do
			-- don't cut corners
			local cut_corner = false
			if id == 1 then
				if not(neighbors[id + 1].clear) or not(neighbors[id + 3].clear)
					or neighbors[id + 1].walkable or neighbors[id + 3].walkable then
					cut_corner = true
				end
			elseif id == 3 then
				if not neighbors[id - 1].clear or not neighbors[id + 3].clear
					or neighbors[id - 1].walkable or neighbors[id + 3].walkable then
					cut_corner = true
				end
			elseif id == 7 then
				if not neighbors[id + 1].clear or not neighbors[id - 3].clear
				or neighbors[id + 1].walkable or neighbors[id - 3].walkable then
					cut_corner = true
				end
			elseif id == 9 then
				if not neighbors[id - 1].clear or not neighbors[id - 3].clear
				or neighbors[id - 1].walkable or neighbors[id - 3].walkable then
					cut_corner = true
				end
			end

			if neighbor.hash ~= current_index and not closedSet[neighbor.hash] and neighbor.clear and not cut_corner then
				local move_cost_to_neighbor = current_values.gCost + get_distance_to_neighbor(current_values.pos, neighbor.pos)
				local gCost = 0
				if openSet[neighbor.hash] then
					gCost = openSet[neighbor.hash].gCost
				end
				if move_cost_to_neighbor < gCost or not openSet[neighbor.hash] then
					if not openSet[neighbor.hash] then
						count = count + 1
					end
					local hCost = get_distance(neighbor.pos, endpos)
					openSet[neighbor.hash] = {
							gCost = move_cost_to_neighbor,
							hCost = hCost,
							fCost = move_cost_to_neighbor + hCost,
							parent = current_index,
							pos = neighbor.pos
					}
				end
			end
		end
		if count > 100 then
			--print("failed finding a path to:" minetest.pos_to_string(endpos))
			return
		end
	until count < 1
	--print("count < 1")
	return {endpos}
end

pathfinder.walkable = walkable

function pathfinder.get_ground_level(pos)
	return get_neighbor_ground_level(pos, 30927, 30927)
end





































function pathfinder.plot_movement_get_step(instep)
	if the_path[instep] ~= nil then
		return the_path[instep]
	end
	return nil
end


local pathfinder_in_use = false


function pathfinder.plot_movement_to_pos(from_pos, to_pos, can_fall)

	-- starting to believe this function is being called by all NPC's at the same time
	-- this causes path errors as the position and destination will keep being overwritten
	-- quick fix is to check if the function is being used first, and wait if it is

	if pathfinder_in_use then 
		return nil
	end
	pathfinder_in_use = true
 

	-- TODO WORK out why i did the following ??
	local startpos = vector.round(vector.add(from_pos, vector.new{x=0,y=1,z=0}))
	startpos.y = startpos.y -1

--	print("START PLOT MOVEMENT FROM ", startpos)

	proposed_path = {}
	the_path = {}

--	local startpos = vector.round(vector.add(from_pos,vector.new(0,0.1,0)))
	local endpos = vector.round(to_pos)
--	print("TO ", endpos)
	local start_index = minetest.hash_node_position(startpos)
	local hash_index = nil
	local start_cost = vector.distance(startpos, endpos)
	local node_cost = nil
	local curr_steps = 0
	proposed_path[start_index] = {hcost = start_cost, steps = curr_steps, parent = nil, pos = startpos, processed = false}
	local lindex = plot_movement_index_lowest_cost(start_cost)
	local lcost = plot_movement_lowest_cost(start_cost)

--	print("START PLOT MOVEMENT WHILE")	
	local max_loop_count = 1000
	--local max_loop_yeald = 200

	while (lindex ~= nil) and (lcost > 0) do
	
		curr_steps = curr_steps + 1
		local node_data = proposed_path[lindex]
--		print("CURRSTEP = ", curr_steps, "COST = ", lcost, " TOPOS = ", node_data.pos);
		local tempr = plot_movement_process_node(node_data.pos, node_data.steps+1 , endpos, can_fall)
		lindex = plot_movement_index_lowest_cost(start_cost)
		lcost = plot_movement_lowest_cost(start_cost)

		max_loop_count = max_loop_count - 1
		if max_loop_count < 0 then 
			lindex = nil
		end

	end

	if (lcost == nil) or (lindex == nil) then 
		-- try to get as close as possible
		-- will have to change destination
		local costdata = plot_movement_lowest_cost_anyway(start_cost) 
--		print("ROUTE CHANGED TO CLOSEST DESTINATION ", costdata.pos)
--		print("WITH A ROUTE COST OF ", costdata.lcost)
		lcost = 0
		endpos = costdata.pos
	end
	if lcost ~= nil then 
		if lcost == 0 then 
--			print("FINISHED I found a route -- now need to backtrack")
			local this_index = minetest.hash_node_position(endpos)
			local path_data = {}
			local this_parent 
			while this_index ~= start_index do
				path_data = proposed_path[this_index]
				this_index = path_data.parent
--				print("STEP ", path_data.steps, " POS = ", path_data.pos)
				the_path[path_data.steps] = path_data.pos	
			end
		end
	end

	pathfinder_in_use = false
	return the_path

end











return pathfinder
