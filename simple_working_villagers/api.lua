--TODO: split this into single modules

local log = simple_working_villages.require("log")
local cmnp = modutil.require("check_prefix","venus")

local func = simple_working_villages.require("jobs/util")

-- TODO :: Animations wanted for characters

-- Stand = 
-- Lay = 
-- Walk =
-- Mine =
-- Walk-Mine =
-- Sit =
-- 
-- Swim
-- Swim-Attack
-- Fly
-- Fly-Attack
-- Fall
-- Fall-Attack
-- Duck Standard
-- Duck
-- Climb
-- 
-- 


simple_working_villages.animation_frames = {
  STAND     = { x=  0, y= 79, },
  LAY       = { x=162, y=166, },
  WALK      = { x=168, y=187, },
  MINE      = { x=189, y=198, },
  WALK_MINE = { x=200, y=219, },
  SIT       = { x= 81, y=160, },
}

--	|Animation| Start | End | FPS |
--	|---------|-------|-----|-----|
--	|Swim     |  246  | 279 |  30 |
--	|Swim Atk |  285  | 318 |  30 |
--	|Fly      |  325  | 334 |  30 |
--	|Fly Atk  |  340  | 349 |  30 |
--	|Fall     |  355  | 364 |  30 |
--	|Fall Atk |  365  | 374 |  30 |
--	|Duck Std |  380  | 380 |  30 |
--	|Duck     |  381  | 399 |  30 |
--	|Climb    |  410  | 429 |  30 |

simple_working_villages.registered_villagers = {}
simple_working_villages.registered_jobs = {}
simple_working_villages.registered_eggs = {}
local have_i_been_hit = false
local been_hit_by = nil
local curr_animation = nil

-- records failed node place attempts to prevent repeating mistakes
-- key=minetest.pos_to_string(pos) val=(os.clock()+180)
local failed_pos_data = {}
local failed_pos_time = 0

local top_velocity = 1.6

-- remove old positions
local function failed_pos_cleanup()
--print("API:REGISTER_VILLAGER [", product_name, "]")
	-- build a list of all items to discard
	local discard_tab = {}
	local now = os.clock()
	for key, val in pairs(failed_pos_data) do
		if now >= val then
			discard_tab[key] = true
		end
	end
	-- discard the old entries
	for key, _ in pairs(discard_tab) do
		failed_pos_data[key] = nil
	end
end

-- add a failed place position
function simple_working_villages.failed_pos_record(pos)
--print("API:REGISTER_VILLAGER [", product_name, "]")
	local key = minetest.hash_node_position(pos)
	failed_pos_data[key] = os.clock() + 180 -- mark for 3 minutes

	-- cleanup if more than 1 minute has passed since the last cleanup
	if os.clock() > failed_pos_time then
		failed_pos_time = os.clock() + 60
		failed_pos_cleanup()
	end
end

-- check if a position is marked as failed and hasn't expired
function simple_working_villages.failed_pos_test(pos)
	local key = minetest.hash_node_position(pos)
	local exp = failed_pos_data[key]
	return exp ~= nil and exp >= os.clock()
end

-- simple_working_villages.is_job reports whether a item is a job item by the name.
function simple_working_villages.is_job(item_name)
	if simple_working_villages.registered_jobs[item_name] then
		return true
	end
	return false
end

-- simple_working_villages.is_villager reports whether a name is villager's name.
function simple_working_villages.is_villager(name)
  if simple_working_villages.registered_villagers[name] then
    return true
  end
  return false
end

---------------------------------------------------------------------

-- simple_working_villages.villager represents a table that contains common methods
-- for villager object.
-- this table must be contains by a metatable.__index of villager self tables.
-- minetest.register_entity set initial properties as a metatable.__index, so
-- this table's methods must be put there.
simple_working_villages.villager = {}

-- simple_working_villages.villager.get_inventory returns a inventory of a villager.
function simple_working_villages.villager:get_inventory()
  return minetest.get_inventory {
    type = "detached",
    name = self.inventory_name,
  }
end

-- simple_working_villages.villager.get_job_name returns a name of a villager's current job.
function simple_working_villages.villager:get_job_name()
  local inv = self:get_inventory()
  local new_job = self.object:get_luaentity().new_job
  if new_job ~= "" then
    self.object:get_luaentity().new_job = ""
    local job_stack = ItemStack(new_job)
    inv:set_stack("job", 1, job_stack)
    return new_job
  end
  return inv:get_stack("job", 1):get_name()
end

-- simple_working_villages.villager.get_job returns a villager's current job definition.
function simple_working_villages.villager:get_job()
  local name = self:get_job_name()
  if name ~= "" then
    return simple_working_villages.registered_jobs[name]
  end
  return nil
end

-- simple_working_villages.villager.is_enemy returns if an object is an enemy.
function simple_working_villages.villager:is_enemy(obj)
  log.verbose("villager %s checks if %s is hostile",self.inventory_name,obj)
  --TODO
  return false
end

-- simple_working_villages.villager.get_nearest_player returns a player object who
-- is the nearest to the villager, the position of and the distance to the player.
function simple_working_villages.villager:get_nearest_player(range_distance,pos)
  local min_distance = range_distance
  local player,ppos
  local position = pos or self.object:get_pos()
  local all_objects = minetest.get_objects_inside_radius(position, range_distance)
  for _, object in pairs(all_objects) do
    if object:is_player() then
      local player_position = object:get_pos()
      local distance = vector.distance(position, player_position)
      if distance < min_distance then
        min_distance = distance
        player = object
        ppos = player_position
      end
    end
  end
  return player,ppos,min_distance
end

-- simple_working_villages.villager.get_nearest_enemy returns an enemy who is the nearest to the villager.
function simple_working_villages.villager:get_nearest_enemy(range_distance)
  local enemy
  local min_distance = range_distance
  local position = self.object:get_pos()
  local all_objects = minetest.get_objects_inside_radius(position, range_distance)
  for _, object in pairs(all_objects) do
    if self:is_enemy(object) then
      local object_position = object:get_pos()
      local distance = vector.distance(position, object_position)
      if distance < min_distance then
        min_distance = distance
        enemy = object
      end
    end
  end
  return enemy
end
-- simple_working_villages.villager.get_nearest_item_by_condition returns the position of
-- an item that returns true for the condition
function simple_working_villages.villager:get_nearest_item_by_condition(cond, range_distance)
  local max_distance=range_distance
  if type(range_distance) == "table" then
    max_distance=math.max(math.max(range_distance.x,range_distance.y),range_distance.z)
  end
  local item = nil
  local min_distance = max_distance
  local position = self.object:get_pos()
  local all_objects = minetest.get_objects_inside_radius(position, max_distance)
  for _, object in pairs(all_objects) do
	local opos = object:get_pos()
--	print("OBJECT POS = ", opos)
	if opos.y < position.y + range_distance.y then
    if not object:is_player() and object:get_luaentity() and object:get_luaentity().name == "__builtin:item" then
      local found_item = ItemStack(object:get_luaentity().itemstring):to_table()
      if found_item then
        if cond(found_item) then
          local item_position = object:get_pos()
          local distance = vector.distance(position, item_position)

          if distance < min_distance then
            min_distance = distance
            item = object
          end
        end
      end
    end

	end

  end
  return item;
end







-- TODO RT Editing this for testing

-- simple_working_villages.villager.get_nearest_item_by_condition returns the position of
-- an item that returns true for the condition
function simple_working_villages.villager:get_nearest_wounded_animal(distance)
	local animal = nil
	local myposition = self.object:get_pos() -- should round this function for pathing error prevention
	local all_objects = minetest.get_objects_inside_radius(myposition, distance)
	for _, object in pairs(all_objects) do
		if object:get_luaentity() then
			local my_oname = object:get_luaentity().name

			if string.find(my_oname,"simple_working_villages:villager_male") then
			elseif string.find(my_oname,"simple_working_villages:villager_female") then

			elseif my_oname == "mobs_npc:npc" then  
			elseif my_oname == "mobs_npc:igor" then
			elseif my_oname == "mobs_npc:trader" then

			elseif my_oname == "visual_harm_1ndicators:hpbar" then
			elseif my_oname == "simple_working_villages:dummy_item" then
			elseif my_oname == "__builtin:item" then

			elseif my_oname == "mobs_monster:dirt_monster" then
			elseif my_oname == "mobs_monster:fire_spirit" then
			elseif my_oname == "mobs_monster:land_guard" then
			elseif my_oname == "mobs_monster:lava_flan" then
			elseif my_oname == "mobs_monster:mese_monster" then
			elseif my_oname == "mobs_monster:obsidian_flan" then
			elseif my_oname == "mobs_monster:oerkki" then
			elseif my_oname == "mobs_monster:sand_monster" then
			elseif my_oname == "mobs_monster:spider" then
			elseif my_oname == "mobs_monster:stone_monster" then
			elseif my_oname == "mobs_monster:tree_monster" then

			elseif my_oname == "mobs_skeletons:skeleton_archer" then
			elseif my_oname == "mobs_skeletons:skeleton_archer_dark" then
			elseif my_oname == "mobs_skeletons:skeleton" then

			elseif my_oname == "mobs_monster:dirt_monster" then
			elseif my_oname == "mobs_monster:dirt_monster" then
			elseif my_oname == "mobs_monster:dirt_monster" then
			elseif my_oname == "mobs_monster:dirt_monster" then
			elseif my_oname == "mobs_monster:dirt_monster" then
			elseif my_oname == "mobs_monster:dirt_monster" then

			elseif string.find(my_oname,"mobs_animal:sheep_") then
				if object:get_hp() < object:get_properties().hp_max then return object end

			elseif my_oname == "mobs_animal:pumba" then
				if object:get_hp() < object:get_properties().hp_max then return object end
			elseif my_oname == "mobs_animal:chicken" then
				if object:get_hp() < object:get_properties().hp_max then return object end
			elseif my_oname == "mobs_animal:panda" then
				if object:get_hp() < object:get_properties().hp_max then return object end
			elseif my_oname == "mobs_animal:penguin" then
				if object:get_hp() < object:get_properties().hp_max then return object end
			elseif my_oname == "mobs_animal:bunny" then
				if object:get_hp() < object:get_properties().hp_max then return object end
			elseif my_oname == "mobs_animal:bee" then
				if object:get_hp() < object:get_properties().hp_max then return object end
			elseif my_oname == "mobs_animal:cow" then
				if object:get_hp() < object:get_properties().hp_max then return object end
			elseif my_oname == "mobs_animal:kitten" then
				if object:get_hp() < object:get_properties().hp_max then return object end
			elseif my_oname == "mobs_animal:rat" then
				if object:get_hp() < object:get_properties().hp_max then return object end
			else
				print("WHAT IS A : ",my_oname)
			end
		end
	end
	return nil;
end






-- TODO RT Editing this for testing

-- simple_working_villages.villager.get_nearest_item_by_condition returns the position of
-- an item that returns true for the condition
function simple_working_villages.villager:get_nearest_wounded_npc(distance)
	local animal = nil
	local myposition = self.object:get_pos() -- should round this function for pathing error prevention
	local ohp = nil
	local olhp = nil
	local all_objects = minetest.get_objects_inside_radius(myposition, distance)
	for _, fobject in pairs(all_objects) do
		if fobject:get_luaentity() then
			local luae = fobject:get_luaentity()
			local my_oname = luae.name

            
            if string.find(my_oname,"simple_working_villages:villager") then
                --print("Medic found ", my_oname, luae.health, fobject:get_hp(), fobject:get_properties().hp_max) 
                local props = fobject:get_properties()
                --print("DUMPLUEA:", dump(props.hp_max) )
				if fobject:get_hp() < fobject:get_properties().hp_max then return fobject end

			elseif string.find(my_oname,"simple_working_villages:villager_male") then
				if fobject:get_hp() < fobject:get_properties().hp_max then return fobject end
			elseif string.find(my_oname,"simple_working_villages:villager_female") then
				if fobject:get_hp() < fobject:get_properties().hp_max then return fobject end
			elseif my_oname == "mobs_npc:npc" then  
				if fobject:get_hp() < fobject:get_properties().hp_max then return fobject end
			elseif my_oname == "mobs_npc:igor" then

			elseif my_oname == "mobs_npc:trader" then
				if fobject:get_hp() < fobject:get_properties().hp_max then return fobject end
			-- WITCHES
			elseif string.find(my_oname,"witches:witch_") then

				if fobject:get_hp() < fobject:get_properties().hp_max then return fobject end

			elseif my_oname == "leads:lead" then
			elseif my_oname == "visual_harm_1ndicators:hpbar" then
			elseif my_oname == "simple_working_villages:dummy_item" then
			elseif my_oname == "__builtin:item" then

			elseif my_oname == "mobs_monster:dirt_monster" then
			elseif my_oname == "mobs_monster:fire_spirit" then
			elseif my_oname == "mobs_monster:land_guard" then
			elseif my_oname == "mobs_monster:lava_flan" then
			elseif my_oname == "mobs_monster:mese_monster" then
			elseif my_oname == "mobs_monster:obsidian_flan" then
			elseif my_oname == "mobs_monster:oerkki" then
			elseif my_oname == "mobs_monster:sand_monster" then
			elseif my_oname == "mobs_monster:spider" then
			elseif my_oname == "mobs_monster:stone_monster" then
			elseif my_oname == "mobs_monster:tree_monster" then

			elseif my_oname == "mobs_skeletons:skeleton_archer" then
			elseif my_oname == "mobs_skeletons:skeleton_archer_dark" then
			elseif my_oname == "mobs_skeletons:skeleton" then

			elseif my_oname == "mobs_monster:dirt_monster" then
	

			elseif string.find(my_oname,"mobs_animal:sheep_") then
			elseif my_oname == "mobs_animal:pumba" then
			elseif my_oname == "mobs_animal:chicken" then
			elseif my_oname == "mobs_animal:panda" then
			elseif my_oname == "mobs_animal:penguin" then
			elseif my_oname == "mobs_animal:bunny" then
			elseif my_oname == "mobs_animal:bee" then
			elseif my_oname == "mobs_animal:cow" then
			elseif my_oname == "mobs_animal:kitten" then
			elseif my_oname == "mobs_animal:rat" then
--				end   nativevillages:toad
			else
				print("WHAT IS A : ",my_oname)
				--print("DUMP : ", fobject:get_luaentity())
			end
		end
	end
	return nil;
end






-- simple_working_villages.villager.get_front returns a position in front of the villager.
function simple_working_villages.villager:get_front()
  local direction = self:get_look_direction()
  if math.abs(direction.x) >= 0.5 then
    if direction.x > 0 then	direction.x = 1	else direction.x = -1 end
  else
    direction.x = 0
  end

  if math.abs(direction.z) >= 0.5 then
    if direction.z > 0 then	direction.z = 1	else direction.z = -1 end
  else
    direction.z = 0
  end
  return vector.add(vector.round(self.object:get_pos()), direction)
end

-- simple_working_villages.villager.get_front_node returns a node that exists in front of the villager.
function simple_working_villages.villager:get_front_node()
  local front = self:get_front()
  return minetest.get_node(front)
end

-- simple_working_villages.villager.get_back returns a position behind the villager.
function simple_working_villages.villager:get_back()
  local direction = self:get_look_direction()
  if math.abs(direction.x) >= 0.5 then
    if direction.x > 0 then	direction.x = -1
    else direction.x = 1 end
  else
    direction.x = 0
  end

  if math.abs(direction.z) >= 0.5 then
    if direction.z > 0 then	direction.z = -1
    else direction.z = 1 end
  else
    direction.z = 0
  end

  --direction.y = direction.y - 1

  return vector.add(vector.round(self.object:get_pos()), direction)
end

-- simple_working_villages.villager.get_back_node returns a node that exists behind the villager.
function simple_working_villages.villager:get_back_node()
  local back = self:get_back()
  return minetest.get_node(back)
end

-- simple_working_villages.villager.get_look_direction returns a normalized vector that is
-- the villagers's looking direction.
function simple_working_villages.villager:get_look_direction()
  local yaw = self.object:get_yaw()
  return vector.normalize{x = -math.sin(yaw), y = 0.0, z = math.cos(yaw)}
end

-- simple_working_villages.villager.set_animation sets the villager's animation.
-- this method is wrapper for self.object:set_animation.
function simple_working_villages.villager:set_animation(frame)
	self.curr_animation = frame

  self.object:set_animation(frame, 15, 0)
  if frame == simple_working_villages.animation_frames.LAY then
    local dir = self:get_look_direction()
    local dirx = math.abs(dir.x)*0.5
    local dirz = math.abs(dir.z)*0.5
    self.object:set_properties({collisionbox={-0.5-dirx, 0, -0.5-dirz, 0.5+dirx, 0.5, 0.5+dirz}})
  else
    self.object:set_properties({collisionbox={-0.25, 0, -0.25, 0.25, 1.75, 0.25}})
  end
end




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











function simple_working_villages.villager:get_animation()
	if self.curr_animation == nil then 
		return nil
	end
	if self.curr_animation.x == 0 and self.curr_animation.y == 79 then 
		return "STAND"
	elseif self.curr_animation.x == 162 and self.curr_animation.y == 166 then
		return "LAY"
	elseif self.curr_animation.x == 168 and self.curr_animation.y == 187 then
		return "WALK"
	elseif self.curr_animation.x == 189 and self.curr_animation.y == 198 then
		return "MINE"
	elseif self.curr_animation.x == 200 and self.curr_animation.y == 219 then
		return "WALK_MINE"
	elseif self.curr_animation.x == 81 and self.curr_animation.y == 160 then
		return "SIT"
	else
		return nil
	end
end



-- simple_working_villages.villager.set_yaw_by_direction sets the villager's yaw
-- by a direction vector.
function simple_working_villages.villager:set_yaw_by_direction(direction)
  self.object:set_yaw(math.atan2(direction.z, direction.x) - math.pi / 2)
end

-- simple_working_villages.villager.get_wield_item_stack returns the villager's wield item's stack.
function simple_working_villages.villager:get_wield_item_stack()
  local inv = self:get_inventory()
  return inv:get_stack("wield_item", 1)
end

-- simple_working_villages.villager.set_wield_item_stack sets villager's wield item stack.
function simple_working_villages.villager:set_wield_item_stack(stack)
  local inv = self:get_inventory()
  inv:set_stack("wield_item", 1, stack)
end

-- simple_working_villages.villager.add_item_to_main add item to main slot.
-- and returns leftover.
function simple_working_villages.villager:add_item_to_main(stack)
  local inv = self:get_inventory()
  return inv:add_item("main", stack)
end

function simple_working_villages.villager:replace_item_from_main(rstack,astack)
  local inv = self:get_inventory()
  inv:remove_item("main", rstack)
  inv:add_item("main", astack)
end

-- simple_working_villages.villager.move_main_to_wield moves itemstack from main to wield.
-- if this function fails then returns false, else returns true.
function simple_working_villages.villager:move_main_to_wield(pred)
  local inv = self:get_inventory()
  local main_size = inv:get_size("main")

  for i = 1, main_size do
    local stack = inv:get_stack("main", i)
    if pred(stack:get_name()) then
      local wield_stack = inv:get_stack("wield_item", 1)
      inv:set_stack("wield_item", 1, stack)
      inv:remove_item("main", stack)
      inv:add_item("main", wield_stack)
      return true
    end
  end
  return false
end

-- simple_working_villages.villager.is_named reports the villager is still named.
function simple_working_villages.villager:is_named()
--print("API: IS_NAMED")
  return self.nametag ~= ""
end

-- simple_working_villages.villager.has_item_in_main reports whether the villager has item.
function simple_working_villages.villager:has_item_in_main(pred)
  local inv = self:get_inventory()
  local stacks = inv:get_list("main")

  for _, stack in ipairs(stacks) do
    local itemname = stack:get_name()
    if pred(itemname) then
      return true
    end
  end
end

-- simple_working_villages.villager.change_direction change direction to destination and velocity vector.
function simple_working_villages.villager:change_direction(destination,velocity)

	local thevelocity = top_velocity

	if velocity ~= nil then 
		thevelocity = velocity
	end 
  local position = self.object:get_pos()
  local tempvelocity = self.object:get_velocity()
  local direction = vector.subtract(destination, position)
  direction.y = 0
  local velocity = vector.multiply(vector.normalize(direction), thevelocity)
  velocity.y = tempvelocity.y
  self.object:set_velocity(velocity)
  self:set_yaw_by_direction(direction)
end

-- simple_working_villages.villager.change_direction_randomly change direction randonly.
function simple_working_villages.villager:change_direction_randomly()
  local direction = {
    x = math.random(0, 5) * 2 - 5,
    y = 0,
    z = math.random(0, 5) * 2 - 5,
  }
  local velocity = vector.multiply(vector.normalize(direction), top_velocity)
  self.object:set_velocity(velocity)
  self:set_yaw_by_direction(direction)
  self:set_animation(simple_working_villages.animation_frames.WALK)
end

-- simple_working_villages.villager.get_timer get the value of a counter.
function simple_working_villages.villager:get_timer(timerId)
  return self.time_counters[timerId]
end

-- simple_working_villages.villager.set_timer set the value of a counter.
function simple_working_villages.villager:set_timer(timerId,value)
  assert(type(value)=="number","timers need to be countable")
  self.time_counters[timerId]=value
end

-- simple_working_villages.villager.clear_timers set all counters to 0.
function simple_working_villages.villager:clear_timers()
  for timerId,_ in pairs(self.time_counters) do
    self.time_counters[timerId] = 0
  end
end

-- simple_working_villages.villager.count_timer count a counter up by 1.
function simple_working_villages.villager:count_timer(timerId)
  if not self.time_counters[timerId] then
    log.info("villager %s timer %q was not initialized", self.inventory_name,timerId)
    self.time_counters[timerId] = 0
  end
  self.time_counters[timerId] = self.time_counters[timerId] + 1
end

-- simple_working_villages.villager.count_timers count all counters up by 1.
function simple_working_villages.villager:count_timers()
  for id, counter in pairs(self.time_counters) do
    self.time_counters[id] = counter + 1
  end
end

-- simple_working_villages.villager.timer_exceeded if a timer exceeds the limit it will be reset and true is returned
function simple_working_villages.villager:timer_exceeded(timerId,limit)
  if self:get_timer(timerId)>=limit then
    self:set_timer(timerId,0)
    return true
  else
    return false
  end
end

-- simple_working_villages.villager.update_infotext updates the infotext of the villager.
function simple_working_villages.villager:update_infotext()
--print("API: UPDATE_INFOTEXT")

  local infotext = ""
  local job_name = self:get_job()

  if job_name ~= nil then
    job_name = job_name.description
    infotext = infotext .. job_name .. "\n"
  else
    infotext = infotext .. "no job\n"
    self.disp_action = "inactive"
  end
  infotext = infotext .. "[Owner] : " .. self.owner_name
  infotext = infotext .. "\nthis villager is " .. self.disp_action
  if self.pause then
    infotext = infotext .. ", [paused]"
  end
  self.object:set_properties{infotext = infotext}
end

-- simple_working_villages.villager.is_near checks if the villager is within the radius of a position
function simple_working_villages.villager:is_near(pos, distance)
  local p = self.object:get_pos()
  p.y = p.y + 0.5
  return vector.distance(p, pos) < distance
end

function simple_working_villages.villager:handle_liquids()
  local ctrl = self.object
  local inside_node = minetest.get_node(self.object:get_pos())
  -- perhaps only when changed
  if minetest.get_item_group(inside_node.name,"liquid") > 0 then
    -- swim
    local viscosity = minetest.registered_nodes[inside_node.name].liquid_viscosity
    ctrl:set_acceleration{x = 0, y = -self.initial_properties.weight/(100*viscosity), z = 0}
  elseif minetest.registered_nodes[inside_node.name].climbable then
    --go down slowly
    ctrl:set_acceleration{x = 0, y = -0.1, z = 0}
  else
    -- fall
    ctrl:set_acceleration{x = 0, y = -self.initial_properties.weight, z = 0}
  end
end

-- FIXME Hacked to get working -- needs work

function simple_working_villages.villager:jump()
  local ctrl = self.object
  local below_node = minetest.get_node(vector.subtract(ctrl:get_pos(),{x=0,y=1,z=0}))
  local velocity = ctrl:get_velocity()
  if below_node.name == "air" then return false end
--  local jump_force = math.sqrt(self.initial_properties.weight) * 1.5
--  if minetest.get_item_group(below_node.name,"liquid") > 0 then
--    local viscosity = minetest.registered_nodes[below_node.name].liquid_viscosity
--    jump_force = jump_force/(viscosity*100)
--  end
--  ctrl:set_velocity{x = velocity.x, y = jump_force, z = velocity.z}
  ctrl:set_velocity{x = velocity.x, y = 6.5, z = velocity.z}
end

-- FIXME Hacked to get working -- needs work

function simple_working_villages.villager:down()
  local ctrl = self.object
--  local below_node = minetest.get_node(vector.subtract(ctrl:get_pos(),{x=0,y=1,z=0}))
--  local velocity = ctrl:get_velocity()
--  if below_node.name == "default:ladder" then return false end
--  local jump_force = math.sqrt(self.initial_properties.weight) * 1.5
--  if minetest.get_item_group(below_node.name,"liquid") > 0 then
--    local viscosity = minetest.registered_nodes[below_node.name].liquid_viscosity
--    jump_force = jump_force/(viscosity*100)
--  end
  ctrl:set_velocity{x = 0, y = -6, z = 0}
end



-- FIXME Hacked to get working -- not sure if needed ???

function simple_working_villages.villager:buried_check()

	--print("Buried Check")
	local mylegs = vector.round(self.object:get_pos())
	local myhead = vector.add(mylegs, vector.new(0,1,0))
	local legnode = minetest.get_node(mylegs)
	local headnode = minetest.get_node(myhead)
	if minetest.registered_nodes[headnode.name].walkable and minetest.registered_nodes[legnode.name].walkable then
		--print("I seem to have buried myself in the ground?")
		local currpos = vector.add(myhead, vector.new(0,1,0))
		local currnode = minetest.get_node(currpos)
		while currnode.walkable do
			currpos = vector.add(currnode, vector.new(0,1,0))
			currnode = minetest.get_node(currpos)
		end
		--("Open ground seems to be at location ", currpos)
		self.object:set_pos(currpos)
	elseif minetest.registered_nodes[legnode.name].walkable then
		self.object:set_pos(myhead)
	end
end


function simple_working_villages.villager:handle_doors()
	local my_pos = vector.round(self.object:get_pos())
	local my_dir = self:get_look_direction()
	local my_fwd = vector.add(my_pos, vector.round(my_dir))
	local back_pos = self:get_back()
	local legnode = minetest.get_node(my_pos)
	local my_fwd_c = vector.new(0,0,0) -- legs level
	my_fwd_c = vector.add(my_fwd_c, my_fwd);
	local front_node_c = minetest.get_node(my_fwd_c)
		if doors.registered_doors[front_node_c.name] then
		local door = doors.get(my_fwd_c)
			if door ~= nil then 
				door:open() 
			end
		end
		if doors.registered_doors[legnode.name] then
			
		local door = doors.get(my_pos)
			if door ~= nil then 
				door:open()
			end
		end
		if doors.registered_doors[minetest.get_node(back_pos).name] then
			local door = doors.get(back_pos)
			if door ~= nil then door:close() end
		end
end









--simple_working_villages.villager.handle_obstacles(ignore_fence,ignore_doors)
--if the villager hits a walkable he wil jump
--if ignore_fence is false the villager will not jump over fences
--if ignore_doors is false and the villager hits a door he opens it
function simple_working_villages.villager:handle_obstacles(ignore_fence,ignore_doors)
	local my_debug = false; 
	local my_pos = vector.round(self.object:get_pos())
	local my_vel = self.object:get_velocity()
	if my_vel.x ~= 0 and my_vel.z ~= 0 then
		local my_dir = self:get_look_direction()
		local my_fwd = vector.add(my_pos, vector.round(my_dir))
		local my_abv = vector.add(my_pos, vector.new(0,2,0)) -- directly above head
		local my_blw = vector.add(my_pos, vector.new(0,-1,0)) -- directly below feet
		local above_node = minetest.get_node(my_abv)
		local below_node = minetest.get_node(my_blw)
		local my_fwd_a = vector.new(0,-2,0) -- below by two
		local my_fwd_b = vector.new(0,-1,0) -- below by one
		local my_fwd_c = vector.new(0,0,0) -- legs level
		local my_fwd_d = vector.new(0,1,0) -- head level
		local my_fwd_e = vector.new(0,2,0) -- directly above head
		my_fwd_a = vector.add(my_fwd_a, my_fwd);
		my_fwd_b = vector.add(my_fwd_b, my_fwd);
		my_fwd_c = vector.add(my_fwd_c, my_fwd);
		my_fwd_d = vector.add(my_fwd_d, my_fwd);
		my_fwd_e = vector.add(my_fwd_e, my_fwd);
		local front_node_a = minetest.get_node(my_fwd_a)
		local front_node_b = minetest.get_node(my_fwd_b)
		local front_node_c = minetest.get_node(my_fwd_c)
		local front_node_d = minetest.get_node(my_fwd_d)
		local front_node_e = minetest.get_node(my_fwd_e)
		local is_above_solid = minetest.registered_nodes[above_node.name].walkable;
		local is_below_solid = minetest.registered_nodes[below_node.name].walkable;
		local is_forwarda_solid = minetest.registered_nodes[front_node_a.name].walkable;
		local is_forwardb_solid = minetest.registered_nodes[front_node_b.name].walkable;
		local is_forwardc_solid = minetest.registered_nodes[front_node_c.name].walkable; -- legs level
		local is_forwardd_solid = minetest.registered_nodes[front_node_d.name].walkable;
		local is_forwarde_solid = minetest.registered_nodes[front_node_e.name].walkable;
		local back_pos = self:get_back()
		if my_debug then
			print("");
			print("MYPOSITION  :",my_pos);
			print("MYVELOCITY:",my_vel);
			print("MYDIRECTION  :",my_dir);
			print("MYFORWARD  :",my_fwd);
		end
		if string.find(front_node_c.name,"default:river_water_") then
			--print("Found a River.");
			if string.find(front_node_b.name,"default:river_water_") then
				--print("Too deep for me");
				self:change_direction_randomly()
				return true
			end
		end
		if string.find(front_node_c.name,"default:water_") then
			--print("Found some Water.");

			if string.find(front_node_b.name,"default:water_") then
				--print("Too deep for me");
				self:change_direction_randomly()
				return true
			end
		end
		if doors.registered_doors[minetest.get_node(back_pos).name] then
			local door = doors.get(back_pos)
			if door ~= nil then door:close() end
		end
		if doors.registered_doors[front_node_c.name] then
			local door = doors.get(my_fwd_c)
			local door_dir = vector.apply(minetest.facedir_to_dir(front_node_c.param2),math.abs)
			local door_dest = vector.new(0,self.object:get_pos().y,0);
			door_dest.x = my_pos.x + math.round(my_dir.x);
			door_dest.z = my_pos.z + math.round(my_dir.z);
			local villager_dir = vector.round(vector.apply(my_dir,math.abs))
			--if vector.equals(door_dir,villager_dir) then
			--	if door:state() then
					--door:close()
			--	else
					door:open()
			--	end
			--end
			--self.object:set_pos(vector.round(door_dest))
					--dwddoor:close()
			if my_debug then
				--print("DOOR FOUND =", front_node_c.name);
				--print("DOORDIR=", door_dir);
				--print("DOORDEST=", door_dest);
				--print("VillagerDIR=", villager_dir);
			end

		elseif not is_forwarda_solid and not is_forwardb_solid then
	--		print("HAVE TO WATCH MY STEP - CHANGE DIR");
			self:change_direction_randomly()

		elseif is_above_solid then
			-- CANNOT JUMP !
	--		print("Something Above");
			if is_forwardd_solid then 
	--			print("In my face - ", front_node_d.name, " - change dir");
				self:change_direction_randomly()
			elseif is_forwardc_solid or is_forwardd_solid then 
	--			print("Above and nowhere to go - change dir");
				self:change_direction_randomly()
			else
	--			print("Not sure what to do");
			end

		 else 
			-- CAN JUMP ?
	--		print("Nothing Above");
			if is_forwardd_solid then 
	--			print("In my face - ", front_node_d.name, " - change dir");
				self:change_direction_randomly()
			else
	--			print("Not in my face");
				if is_forwardc_solid then 
	--				print("Step found - looking for room");
					if is_forwarde_solid then 
	--					print("No room to jump up - change dir");
						self:change_direction_randomly()
					else
	--					print("Is room to jump up - Try Jumping");
						self:jump()
					end
				end
			end



		end
	end
end













function simple_working_villages.villager:handle_goto_obstacles(can_drop)

	if can_drop == nil then can_drop = true end

	local my_debug = false
	if my_debug then print("DEBUG HANDLE GOTO OBSTACLES") end

	local my_pos = vector.round(self.object:get_pos())
	local my_vel = self.object:get_velocity()
	local my_dir = self:get_look_direction()
	local my_fwd = vector.add(my_pos, vector.round(my_dir));
	local my_abv = vector.add(my_pos, vector.new(0,2,0)); -- directly above head
	local my_blw = vector.add(my_pos, vector.new(0,-1,0)); -- directly below feet
	local above_node = minetest.get_node(my_abv)
	local below_node = minetest.get_node(my_blw)
	local my_fwd_a = vector.new(0,-2,0) -- below by two
	local my_fwd_b = vector.new(0,-1,0) -- below by one
	local my_fwd_c = vector.new(0,0,0) -- legs level
	local my_fwd_d = vector.new(0,1,0) -- head level
	local my_fwd_e = vector.new(0,2,0) -- directly above head
	my_fwd_a = vector.add(my_fwd_a, my_fwd);
	my_fwd_b = vector.add(my_fwd_b, my_fwd);
	my_fwd_c = vector.add(my_fwd_c, my_fwd);
	my_fwd_d = vector.add(my_fwd_d, my_fwd);
	my_fwd_e = vector.add(my_fwd_e, my_fwd);

	local pos_node = minetest.get_node(my_pos)
	local front_node_a = minetest.get_node(my_fwd_a)
	local front_node_b = minetest.get_node(my_fwd_b)
	local front_node_c = minetest.get_node(my_fwd_c)
	local front_node_d = minetest.get_node(my_fwd_d)
	local front_node_e = minetest.get_node(my_fwd_e)

	
	local is_legs_solid = minetest.registered_nodes[pos_node.name].walkable;
	local is_above_solid = minetest.registered_nodes[above_node.name].walkable;
	local is_below_solid = minetest.registered_nodes[below_node.name].walkable;
	local is_forwarda_solid = minetest.registered_nodes[front_node_a.name].walkable;
	local is_forwardb_solid = minetest.registered_nodes[front_node_b.name].walkable;
	local is_forwardc_solid = minetest.registered_nodes[front_node_c.name].walkable; -- legs level
	local is_forwardd_solid = minetest.registered_nodes[front_node_d.name].walkable;
	local is_forwarde_solid = minetest.registered_nodes[front_node_e.name].walkable;
	local back_pos = self:get_back()


	if my_debug then
		print("MYPOSITION  :",my_pos)
		print("MYVELOCITY:",my_vel)
		print("MYDIRECTION  :",my_dir)
		print("MYFORWARD  :",my_fwd)
		print("POS NODE = ", pos_node.name)
	end
	
-- TODO RT : have to implement the ignore doors and fences functionality
-- TODO RT : have to change get node "doors:door" to group door function here and elsewhere in the mod
-- TODO RT : have to check for water and act accordingly


--	local my_entity = object:get_luaentity().name
--	local my_entity = obj:get_luaentity()
--	if my_entity ~= nil then 
--		print("Entity = ", my_entity.name);
--		local name_split = string.split(obj:get_luaentity().name, ':')
--	end



--    if pointedobject:get_luaentity() then
--mods/mob_core/api.lua:                    pointedobject = pointedobject:get_luaentity()




	--if minetest.get_item_group(item_name, key) > 0 then

	if is_legs_solid then 
		if my_debug then print("I AM STANDING IN SOMETHING") end
		if string.find(pos_node.name,"stairs:slab") or string.find(pos_node.name,"beds:") or string.find(pos_node.name,"stairs:") or doors.registered_doors[pos_node.name] then
			if my_debug then print("TESTED GOTO JUMP POS") end
		else 
			if my_debug then print("TESTED GOTO JUMP NEG = JUMP") end
			

			self.object:set_pos(vector.add(self.object:get_pos(), vector.new{x=0,y=1,z=0}))


--			self:jump()
		end
	end

--	print("FRONT B NODE = ", front_node_b.name)
--	print("FRONT C NODE = ", front_node_c.name)
	if string.find(front_node_b.name,"doors:") then
		if my_debug then print("FOUND A DOOR") end
		self:jump()
		return true
	end

	if string.find(front_node_c.name,"default:river_water_") then
		if my_debug then print("Found a River.") end
		if string.find(front_node_b.name,"default:river_water_") then
			if my_debug then print("Too deep for me") end
			--self:change_direction_randomly()
			return true
		end
	end

	if string.find(front_node_c.name,"default:water_") then
		if my_debug then print("Found some Water.") end

		if string.find(front_node_b.name,"default:water_") then
			if my_debug then print("Too deep for me") end
			--self:change_direction_randomly()
			return true
		end
	end


-- doors.registered_doors[pos_node.name]

--	if string.find(minetest.get_node(back_pos).name,"doors:") then
	if doors.registered_doors[minetest.get_node(back_pos).name] then
		local door = doors.get(back_pos)
		if door ~= nil then door:close() end
	end


	if not is_below_solid then
		if my_debug then print("Allow to fall to get new location") end
		-- stops getting on stuck of pyramids ??
		return nil
	end 

	if doors.registered_doors[front_node_c.name] then
		
		local door = doors.get(my_fwd_c)
		local door_dir = vector.apply(minetest.facedir_to_dir(front_node_c.param2),math.abs)

		local door_dest = vector.new(0,self.object:get_pos().y,0);
		door_dest.x = my_pos.x + math.round(my_dir.x);
		door_dest.z = my_pos.z + math.round(my_dir.z);

		local villager_dir = vector.round(vector.apply(my_dir,math.abs))
		--if vector.equals(door_dir,villager_dir) then
		--	if door:state() then
				--door:close()
		--	else
				door:open()
		--	end
		--end
		--self.object:set_pos(vector.round(door_dest))
				--dwddoor:close()
		if my_debug then
			print("DOOR FOUND =", front_node_c.name);
			print("DOORDIR=", door_dir);
			print("DOORDEST=", door_dest);
			print("VillagerDIR=", villager_dir);
		end
	end

	if can_drop == false then	
		if not(is_forwarda_solid) and not(is_forwardb_solid) then
			if my_debug then 
				print("IS_FORWARDA_SOLID=",is_forwarda_solid) 
				print("IS_FORWARDB_SOLID=",is_forwardb_solid) 
			end
			--self:change_direction_randomly()
		end
--		return nil
	end


	if is_above_solid then
		-- CANNOT JUMP !
		if my_debug then print("Something Above") end
		if is_forwardd_solid then 
			if my_debug then print("In my face - ", front_node_d.name, " - change dir?") end
			--self:change_direction_randomly()
		elseif is_forwardc_solid or is_forwardd_solid then 
			if my_debug then print("Above and nowhere to go - change dir") end
			--self:change_direction_randomly()
		else
			if my_debug then print("Not sure what to do") end
		end




-- TRY LADDER HERE
	elseif string.find(below_node.name,"default:ladder") then
		-- ladder below !
		if my_debug then print("ladder below") end
		--self:down()
 
	elseif string.find(above_node.name,"default:ladder") then
		-- ladder below !
		if my_debug then print("ladder above") end
		self:jump()

	 else 
		-- CAN JUMP ?
		if my_debug then print("Nothing Above") end
		if is_forwardd_solid then 
			if my_debug then print("In my face - ", front_node_d.name, " - change dir?") end
			--self:change_direction_randomly()
		else
			if my_debug then print("Not in my face") end
			if is_forwardc_solid then 
				if my_debug then print("Step found - looking for room") end
				if is_forwarde_solid then 
					if my_debug then print("No room to jump up - change dir?") end
					--self:change_direction_randomly()
				else
					if my_debug then print("Is room to jump up - Try Jumping") end

	

					self:jump()
				end
			end
		end



	end

	




--				    if minetest.get_item_group(front_node.name, "fence") > 0 and not(ignore_fence) then
--				--	print("HandleObstacles:Not Ignore Fences?");
--				      self:change_direction_randomly()
--				    elseif string.find(front_node.name,"doors:door") and not(ignore_doors) then
--				--	print("HandleObstacles:Not Ignore Doors?");
--				      local door = doors.get(front_pos)
--				      local door_dir = vector.apply(minetest.facedir_to_dir(front_node.param2),math.abs)
--				      local villager_dir = vector.round(vector.apply(front_diff,math.abs))
--				      if vector.equals(door_dir,villager_dir) then
--					if door:state() then
--					  door:close()
--					else
--					  door:open()
---					end
--				      end
--
--
--				-- TODO RT : have to do some more checks for blocks above head when jumpingid
--				    elseif minetest.registered_nodes[front_node.name].walkable and not(minetest.registered_nodes[above_node.name].walkable) then
--					print("Something to Jump over");
--				      if velocity.y == 0 then
--					local nBox = minetest.registered_nodes[front_node.name].node_box
--					if (nBox == nil) then
--					  nBox = {-0.5,-0.5,-0.5,0.5,0.5,0.5}
--					else
--					  nBox = nBox.fixed
--					end
--					if type(nBox[1])=="number" then
--					  nBox = {nBox}
--					end
--					for _,box in pairs(nBox) do --TODO: check rotation of the nodebox
--					  local nHeight = (box[5] - box[2]) + front_pos.y
--					  if nHeight > self.object:get_pos().y + .5 then
--					    self:jump()
--					  end
--					end
--				      end
--				    end
--				  end
--				  if not ignore_doors then
--				    local back_pos = self:get_back()
--				    if string.find(minetest.get_node(back_pos).name,"doors:door") then
--				      local door = doors.get(back_pos)
--				      door:close()
--				    end
--				  end
end














-- simple_working_villages.villager.pickup_item pickup items placed and put it to main slot.
function simple_working_villages.villager:pickup_item()
  local pos = self.object:get_pos()
  local radius = 1.0
  local all_objects = minetest.get_objects_inside_radius(pos, radius)

  for _, obj in ipairs(all_objects) do
    if not obj:is_player() and obj:get_luaentity() and obj:get_luaentity().itemstring then
      local itemstring = obj:get_luaentity().itemstring
      local stack = ItemStack(itemstring)
      if stack and stack:to_table() then
        local name = stack:to_table().name

        if minetest.registered_items[name] ~= nil then
          local inv = self:get_inventory()
          local leftover = inv:add_item("main", stack)

          minetest.add_item(obj:get_pos(), leftover)
          obj:get_luaentity().itemstring = ""
          obj:remove()
        end
      end
    end
  end
end

-- simple_working_villages.villager.get_job_data get a job data field
function simple_working_villages.villager:get_job_data(key)
  local actual_job_data = self.job_data[self:get_job_name()]
  if actual_job_data == nil then
    return nil
  end
  return actual_job_data[key]
end

-- simple_working_villages.villager.set_job_data set a job data field
function simple_working_villages.villager:set_job_data(key, value)
  local actual_job_data = self.job_data[self:get_job_name()]
  if actual_job_data == nil then
    actual_job_data = {}
    self.job_data[self:get_job_name()] = actual_job_data
  end
  actual_job_data[key] = value
end

-- simple_working_villages.villager:new returns a new villager object.
function simple_working_villages.villager:new(o)
  return setmetatable(o or {}, {__index = self})
end

simple_working_villages.require("villager_state")

-- simple_working_villages.villager.is_active check if the villager is paused.
-- deprecated check self.pause instesad
function simple_working_villages.villager:is_active()
  print("self:is_active is deprecated: check self.pause directly it's a boolean value")
  return self.pause
end

--simple_working_villages.villager.set_paused set the villager to paused state
--deprecated use set_pause
function simple_working_villages.villager:set_paused(reason)
  print("self:set_paused() is deprecated use self:set_pause() and self:set_displayed_action() instead")
  self:set_pause(true)
  self:set_displayed_action(reason or "resting")
end

simple_working_villages.require("async_actions")

-- compatibility with like player object
function simple_working_villages.villager:get_player_name()
  return self.object:get_player_name()
end



-- TODO TEST true from false
function simple_working_villages.villager:is_player()
  return false
end

-- TODO TEST true from false
function simple_working_villages.villager:get_wield_index()
  return 1
end

--deprecated
function simple_working_villages.villager:set_state(id)
  if id == "idle" then
    print("the idle state is deprecated")
  elseif id == "goto_dest" then
    print("use self:go_to(pos) instead of self:set_state(\"goto\")")
    self:go_to(self.destination)
  elseif id == "job" then
    print("the job state is not nessecary anymore")
  elseif id == "dig_target" then
    print("use self:dig(pos,collect_drops) instead of self:set_state(\"dig_target\")")
    self:dig(self.target,true)
  elseif id == "place_wield" then
    print("use self:place(itemname,pos) instead of self:set_state(\"place_wield\")")
    local wield_stack = self:get_wield_item_stack()
    self:place(wield_stack:get_name(),self.target)
  end
end

---------------------------------------------------------------------

-- simple_working_villages.manufacturing_data represents a table that contains manufacturing data.
-- this table's keys are product names, and values are manufacturing numbers
-- that has been already manufactured.
simple_working_villages.manufacturing_data = (function()
  local file_name = minetest.get_worldpath() .. "/simple_working_villages_data"
  minetest.register_on_shutdown(function()
    local file = io.open(file_name, "w")
    file:write(minetest.serialize(simple_working_villages.manufacturing_data))
    file:close()
  end)
  local file = io.open(file_name, "r")
  if file ~= nil then
    local data = file:read("*a")
    file:close()
    return minetest.deserialize(data)
  end
  return {}
end) ()

--------------------------------------------------------------------

-- register empty item entity definition.
-- this entity may be hold by villager's hands.
do
  minetest.register_craftitem("simple_working_villages:dummy_empty_craftitem", {
    wield_image = "working_villages_dummy_empty_craftitem.png",
  })

  local function on_activate(self)
    -- attach to the nearest villager.
    local all_objects = minetest.get_objects_inside_radius(self.object:get_pos(), 0.1)
    for _, obj in ipairs(all_objects) do
      local luaentity = obj:get_luaentity()

      if simple_working_villages.is_villager(luaentity.name) then
        self.object:set_attach(obj, "Arm_R", {x = 0.065, y = 0.50, z = -0.15}, {x = -45, y = 0, z = 0})
        self.object:set_properties{textures={"simple_working_villages:dummy_empty_craftitem"}}
        self.object:set_properties{health={15}}
        return
      end
    end
  end

  local function on_step(self)
    local all_objects = minetest.get_objects_inside_radius(self.object:get_pos(), 0.1)
    for _, obj in ipairs(all_objects) do
      local luaentity = obj:get_luaentity()

      if simple_working_villages.is_villager(luaentity.name) then
        local stack = luaentity:get_wield_item_stack()

        if stack:get_name() ~= self.itemname then
          if stack:is_empty() then
            self.itemname = ""
            self.object:set_properties{textures={"simple_working_villages:dummy_empty_craftitem"}}
          else
            self.itemname = stack:get_name()
            self.object:set_properties{textures={self.itemname}}
          end
        end
        return
      end
    end
    -- if cannot find villager, delete empty item.
    self.object:remove()
    return
  end

  minetest.register_entity("simple_working_villages:dummy_item", {
    hp_max		    = 1,
    visual		    = "wielditem",
    visual_size	  = {x = 0.025, y = 0.025},
    collisionbox	= {0, 0, 0, 0, 0, 0},
    physical	    = false,
    textures	    = {"air"},
    on_activate	  = on_activate,
    on_step       = on_step,
    itemname      = "",
  })
end

---------------------------------------------------------------------

simple_working_villages.job_inv = minetest.create_detached_inventory("simple_working_villages:job_inv", {
  on_take = function(inv, listname, _, stack) --inv, listname, index, stack, player
    inv:add_item(listname,stack)
  end,
  on_put = function(inv, listname, _, stack)
    if inv:contains_item(listname, stack:peek_item(1)) then
      --inv:remove_item(listname, stack)
      stack:clear()
    end
  end,
})
simple_working_villages.job_inv:set_size("main", 32)

-- simple_working_villages.register_job registers a definition of a new job.
function simple_working_villages.register_job(job_name, def)
  local name = cmnp(job_name)
  simple_working_villages.registered_jobs[name] = def

  minetest.register_tool(name, {
    stack_max       = 1,
    description     = def.description,
    inventory_image = def.inventory_image,
    groups          = {not_in_creative_inventory = 1}
  })

  --simple_working_villages.job_inv:set_size("main", #simple_working_villages.registered_jobs)
  simple_working_villages.job_inv:add_item("main", ItemStack(name))
end

-- simple_working_villages.register_egg registers a definition of a new egg.
function simple_working_villages.register_egg(egg_name, def)
  local name = cmnp(egg_name)
  simple_working_villages.registered_eggs[name] = def

  minetest.register_tool(name, {
    description     = def.description,
    inventory_image = def.inventory_image,
    stack_max       = 1,

    on_use = function(itemstack, user, pointed_thing)
      if pointed_thing.above ~= nil and def.product_name ~= nil then
        -- set villager's direction.
        local new_villager = minetest.add_entity(pointed_thing.above, def.product_name)
        new_villager:get_luaentity():set_yaw_by_direction(
          vector.subtract(user:get_pos(), new_villager:get_pos())
        )
        new_villager:get_luaentity().owner_name = user:get_player_name()
        new_villager:get_luaentity():update_infotext()

        itemstack:take_item()
        return itemstack
      end
      return nil
    end,
  })
end

local job_coroutines = simple_working_villages.require("job_coroutines")
local forms = simple_working_villages.require("forms")

-- simple_working_villages.register_villager registers a definition of a new villager.
function simple_working_villages.register_villager(product_name, def)
  local name = cmnp(product_name)
  simple_working_villages.registered_villagers[name] = def

  -- initialize manufacturing number of a new villager.
  if simple_working_villages.manufacturing_data[name] == nil then
    simple_working_villages.manufacturing_data[name] = 0
  end

  -- create_inventory creates a new inventory, and returns it.
  local function create_inventory(self)
    self.inventory_name = self.product_name .. "_" .. tostring(self.manufacturing_number)
    local inventory = minetest.create_detached_inventory(self.inventory_name, {
      on_put = function(_, listname, _, stack) --inv, listname, index, stack, player
        if listname == "job" then
          local job_name = stack:get_name()
          local job = simple_working_villages.registered_jobs[job_name]
          if type(job.on_start)=="function" then
            job.on_start(self)
            self.job_thread = coroutine.create(job.on_step)
          elseif type(job.jobfunc)=="function" then
            self.job_thread = coroutine.create(job.jobfunc)
          end
          self:set_displayed_action("active")
          self:set_state_info(("I started working as %s."):format(job.description))
      end
      end,
      allow_put = function(inv, listname, _, stack) --inv, listname, index, stack, player
        -- only jobs can put to a job inventory.
        if listname == "main" then
          return stack:get_count()
      elseif listname == "job" and simple_working_villages.is_job(stack:get_name()) then
        if not inv:is_empty("job") then
          inv:remove_item("job", inv:get_list("job")[1])
        end
        return stack:get_count()
      elseif listname == "wield_item" then
        return 0
      end
      return 0
      end,
      on_take = function(_, listname, _, stack) --inv, listname, index, stack, player
        if listname == "job" then
          local job_name = stack:get_name()
          local job = simple_working_villages.registered_jobs[job_name]
          self.time_counters = {}
          if job then
            if type(job.on_stop)=="function" then
              job.on_stop(self)
            elseif type(job.jobfunc)=="function" then
              self.job_thread = false
            end
          end
          self:set_state_info("I stopped working.")
          self:update_infotext()
      end
      end,

      allow_take = function(_, listname, _, stack) --inv, listname, index, stack, player
        if listname == "wield_item" then
          return 0
      end
      return stack:get_count()
      end,

      on_move = function(inv, from_list, _, to_list, to_index)
        --inv, from_list, from_index, to_list, to_index, count, player
        if to_list == "job" or from_list == "job" then
          local job_name = inv:get_stack(to_list, to_index):get_name()
          local job = simple_working_villages.registered_jobs[job_name]

          if to_list == "job" then
            if type(job.on_start)=="function" then
              job.on_start(self)
              self.job_thread = coroutine.create(job.on_step)
            elseif type(job.jobfunc)=="function" then
              self.job_thread = coroutine.create(job.jobfunc)
            end
          elseif from_list == "job" then
            if type(job.on_stop)=="function" then
              job.on_stop(self)
            elseif type(job.jobfunc)=="function" then
              self.job_thread = false
            end
          end

          self:set_displayed_action("active")
          self:set_state_info(("I started working as %s."):format(job.description))
        end
      end,

      allow_move = function(inv, from_list, from_index, to_list, _, count)
        --inv, from_list, from_index, to_list, to_index, count, player
        if to_list == "wield_item" then
          return 0
        end

        if to_list == "main" then
          return count
        elseif to_list == "job" and simple_working_villages.is_job(inv:get_stack(from_list, from_index):get_name()) then
          return count
        end

        return 0
      end,
    })

    inventory:set_size("main", 16)
    inventory:set_size("job",  1)
    inventory:set_size("wield_item", 1)

    return inventory
  end

  local function fix_pos_data(self)
    if self:has_home() then
      -- share some data from building sign
      local sign = self:get_home()
      self.pos_data.home_pos = sign:get_door()
      self.pos_data.bed_pos = sign:get_bed()
    end
    if self.village_name then
      -- TODO: share pos data from central village data
      --local village = simple_working_villages.get_village(self.village_name)
      --if village then
        --self.pos_data = village:get_villager_pos_data(self.inventory_name)
      --end
      -- remove this later
      return -- do semething for luacheck
    end
  end

  -- on_activate is a callback function that is called when the object is created or recreated.
  local function on_activate(self, staticdata)
	print("WARNING: ON_ACTIVATE!!!")
    -- parse the staticdata, and compose a inventory.
    if staticdata == "" then
      self.product_name = name
      self.manufacturing_number = simple_working_villages.manufacturing_data[name]
      simple_working_villages.manufacturing_data[name] = simple_working_villages.manufacturing_data[name] + 1
      create_inventory(self)

      -- attach dummy item to new villager.
      minetest.add_entity(self.object:get_pos(), "simple_working_villages:dummy_item")
    else
      -- if static data is not empty string, this object has beed already created.
      local data = minetest.deserialize(staticdata)

      self.product_name = data["product_name"]
      self.manufacturing_number = data["manufacturing_number"]
      self.nametag = data["nametag"]
      self.owner_name = data["owner_name"]
      self.pause = data["pause"]
      self.job_data = data["job_data"]
      self.state_info = data["state_info"]
      self.pos_data = data["pos_data"]

      local inventory = create_inventory(self)
      for list_name, list in pairs(data["inventory"]) do
        inventory:set_list(list_name, list)
      end

      fix_pos_data(self)
    end

    self:set_displayed_action("active")
    self.object:set_nametag_attributes{
      text = self.nametag
    }
    self.object:set_velocity{x = 0, y = 0, z = 0}
    self.object:set_acceleration{x = 0, y = -self.initial_properties.weight, z = 0}

    --legacy
    if type(self.pause) == "string" then
      self.pause = (self.pause == "resting")
    end

    local job = self:get_job()
    if job ~= nil then
      if type(job.on_start)=="function" then
        job.on_start(self)
        self.job_thread = coroutine.create(job.on_step)
      elseif type(job.jobfunc)=="function" then
        self.job_thread = coroutine.create(job.jobfunc)
      end
      if self.pause then
        if type(job.on_pause)=="function" then
          job.on_pause(self)
        end
        self:set_displayed_action("resting")
      end
    end
  end

  -- get_staticdata is a callback function that is called when the object is destroyed.
  local function get_staticdata(self)
    local inventory = self:get_inventory()
    local data = {
      ["product_name"] = self.product_name,
      ["manufacturing_number"] = self.manufacturing_number,
      ["nametag"] = self.nametag,
      ["owner_name"] = self.owner_name,
      ["inventory"] = {},
      ["pause"] = self.pause,
      ["job_data"] = self.job_data,
      ["state_info"] = self.state_info,
      ["pos_data"] = self.pos_data,
    }

    -- set lists.
    for list_name, list in pairs(inventory:get_lists()) do
      data["inventory"][list_name] = {}

      for i, item in ipairs(list) do
        data["inventory"][list_name][i] = item:to_string()
      end
    end

    return minetest.serialize(data)
  end

  -- on_step is a callback function that is called every delta times.
  local function on_step(self, dtime)
    --[[ if owner didn't login, the villager does nothing.
		-- perhaps add a check for this to be used in jobfuncs etc.
		if not minetest.get_player_by_name(self.owner_name) then
			return
		end--]]

    self:handle_liquids()

    -- pickup surrounding item.
    self:pickup_item()

    if self.pause then
      return
    end
    job_coroutines.resume(self,dtime)
  end

  -- on_rightclick is a callback function that is called when a player right-click them.
  local function on_rightclick(self, clicker)
    local wielded_stack = clicker:get_wielded_item()
    if wielded_stack:get_name() == "simple_working_villages:commanding_sceptre"
      and (self.owner_name == "simple_working_villages:self_employed"
        or clicker:get_player_name() == self.owner_name or
        minetest.check_player_privs(clicker, "debug")) then

      forms.show_formspec(self, "simple_working_villages:inv_gui", clicker:get_player_name())
    else
      forms.show_formspec(self, "simple_working_villages:talking_menu", clicker:get_player_name())
    end
  end

  -- on_punch is a callback function that is called when a player punches a villager.
  --local function on_punch(self, puncher, tool_capabilities, dir)


  local function on_punch(self, puncher, time_from_last_punch, tool_capabilities, direction, damage)
	print("ON PUNCH EVENT")
	local myohp = self.health


	if puncher:is_player() then 
		print("Hit by Player ", puncher:get_player_name())
	end

	local myluae = puncher:get_luaentity()
	if myluae ~= nil then 
		print("Hit by LUAE Entity ")
	end


	print("Puncher = ", puncher:get_player_name())


--	print("ONPUNCH:HEALTH", myohp)
--	print("ONPUNCH:DAMAGE", damage)
	self.health = myohp-damage
	myohp = self.health
--	print("ONPUNCH:", myohp)

	have_i_been_hit = true
	been_hit_by = puncher

	if self.health <= 0 then 
		print(" I THINK I HAVE DIED !!")
		-- TODO PLACE BONES  ??
	
		local pos = self.object:get_pos() 
--		core.set_node(pos, { name = "default:mese" })
		core.set_node(pos, { name = "bones:bones" })




	else
		print(" I AM STILL ALIVE !!")
	end


--	print("IS HIT = ", have_i_been_hit)
--	print("HIT BY = ", been_hit_by)

--	local beenpunched_job = {
--		["name"] = "beenpunched",
--		["status"] = 0,
--		["puncher"] = puncher,
--		["damage"] = damage
--	}
--	add_to_joblist(beenpunched_job)
--	print("ONPUNCH:PUNCHER", dump(puncher))
--	print("ONPUNCH:TFLP", dump(time_from_last_punch))
	--print("ONPUNCH:DIR", dump(dir))
--	print("ONPUNCH:TOOL", dump(tool_capabilities))
  	--TODO: aggression (add player ratings table)
	return false

  end

function simple_working_villages.villager:have_i_been_attacked()

--	print("IS HIT = ", have_i_been_hit)
--	print("HIT BY = ", been_hit_by)

	if have_i_been_hit == true then
		have_i_been_hit = false
		return been_hit_by
	else
		been_hit_by = nil 
		return nil
	end

end












  -- register a definition of a new villager.

  local villager_def = simple_working_villages.villager:new({
    initial_properties = {
      hp_max                      = def.hp_max,
      weight                      = def.weight,
      mesh                        = def.mesh,
      textures                    = def.textures,

      --TODO: put these into simple_working_villagers.villager
      physical                    = true,
      visual                      = "mesh",
      visual_size                 = {x = 1, y = 1},
      collisionbox                = {-0.25, 0, -0.25, 0.25, 1.75, 0.25},
      pointable                   = true,
      stepheight                  = 0.6,
      is_visible                  = true,
      makes_footstep_sound        = true,
	--      automatic_face_movement_dir = false,  TODO RT Not sure why this is false, let try setting to true
	-- interestingly when set to true the NPC's walk sideways 
      automatic_face_movement_dir = false,
      infotext                    = "",
      nametag                     = "",
      static_save                 = true,
    }
  })

  -- extra initial properties
  villager_def.pause                       = false






  villager_def.disp_action                 = "inactive\nNo job"
  villager_def.state                       = "job"
  villager_def.state_info                  = "I am doing nothing particular."
  villager_def.job_thread                  = false
  villager_def.product_name                = ""
  villager_def.manufacturing_number        = -1
  villager_def.health			   = 30
  villager_def.owner_name                  = ""
  villager_def.time_counters               = {}
  villager_def.destination                 = vector.new(0,0,0)
  villager_def.job_data                    = {}
  villager_def.pos_data                    = {}
 
--	wakeup_time = 0.2
--	work_time = 0.24
--	stop_time = 0.76
--	bed_time = 0.805
--	size_x = 0.8,
--	size_y = 1.3,


	if def.name ~= nil then 
		villager_def.initial_properties.nametag = def.name
	else
		villager_def.initial_properties.nametag = ""
	end




	if def.size_x ~= nil then 
		villager_def.initial_properties.visual_size["x"] = def.size_x
	else
		villager_def.initial_properties.visual_size["x"] = 1
	end

	if def.size_y ~= nil then 
		villager_def.initial_properties.visual_size["y"] = def.size_y
	else
		villager_def.initial_properties.visual_size["y"] = 1
	end




	if def.wakeup_time ~= nil then 
		villager_def.wakeup_time = def.wakeup_time
	else
		villager_def.wakeup_time = 0.2
	end

	if def.work_time ~= nil then 
		villager_def.work_time = def.work_time
	else
		villager_def.work_time = 0.24
	end

	if def.stop_time ~= nil then 
		villager_def.stop_time = def.stop_time
	else
		villager_def.stop_time = 0.76
	end

	if def.bed_time ~= nil then 
		villager_def.bed_time = def.bed_time
	else
		villager_def.bed_time = 0.805
	end




	if def.walk_speed ~= nil then 
		villager_def.walk_speed = def.walk_speed
	else
		villager_def.walk_speed = 1.6
	end

	if def.walk_speed ~= nil then 
		villager_def.dig_delay = def.dig_delay
	else
		villager_def.dig_delay = 100
	end

	if def.build_delay ~= nil then 
		villager_def.build_delay = def.build_delay
	else
		villager_def.build_delay = 100
	end

	if def.run_speed ~= nil then 
		villager_def.run_speed = def.run_speed
	else
		villager_def.run_speed = 1.6
	end

	if def.start_job == nil then 
--	print("INITIATION: NO START JOB")
		villager_def.new_job                     = ""
	else
--	print("INITIATION: START JOB")
		villager_def.new_job = def.start_job
	end

--villager_def:update_infotext()


				--		local obj = core.add_entity(myps, worker_marker, nil)
				--		local ent = obj:get_luaentity()

				--		ent.new_job
				--		ent.owner_name = self.owner_name
				--		ent:update_infotext()

  -- callback methods
  villager_def.on_activate                 = on_activate
  villager_def.on_step                     = on_step
  villager_def.on_rightclick               = on_rightclick
  villager_def.on_punch                    = on_punch

--  villager_def.on_punch = function(self, puncher, ...)
--		if self.rider and puncher == self.rider then return end
--		local name = puncher:is_player() and puncher:get_player_name()
--		if name
--		and name == self.owner
--		and puncher:get_player_control().sneak then
--			self:set_saddle(false)
--			return
--		end
--		animalia.punch(self, puncher, ...)
--	end,

  villager_def.get_staticdata              = get_staticdata

  -- storage methods
  villager_def.get_stored_table            = simple_working_villages.get_stored_villager_table
  villager_def.set_stored_table            = simple_working_villages.set_stored_villager_table
  villager_def.clear_cached_table          = simple_working_villages.clear_cached_villager_table

  -- home methods
  villager_def.get_home                    = simple_working_villages.get_home
  villager_def.has_home                    = simple_working_villages.is_valid_home
  villager_def.set_home                    = simple_working_villages.set_home
  villager_def.remove_home                 = simple_working_villages.remove_home


  minetest.register_entity(name, villager_def)



  if def.visible == nil or def.visible ~= false then 
  	-- register villager egg.
		simple_working_villages.register_egg(name .. "_egg", {
		description     = name .. " egg",
		inventory_image = def.egg_image,
		product_name    = name,
		})
  end
end

