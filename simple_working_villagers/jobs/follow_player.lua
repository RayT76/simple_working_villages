
local func = simple_working_villages.require("jobs/util")

local follower = {}
local use_vh1 = minetest.get_modpath("visual_harm_1ndicators")

function follower.walk_in_direction(v,dir)
  local position = v.object:get_pos()
  --swim upward
  if dir.y > 1 and minetest.get_item_group(minetest.get_node(position).name,"liquid") > 0 then
    v:jump()
  end

  local velocity = v.object:get_velocity()
  if velocity.x==0 and velocity.y==0 then
    v:set_animation(simple_working_villages.animation_frames.WALK)
  end
  --speed should actually be limited
  v.object:set_velocity{x = dir.x, y = velocity.y, z = dir.z}
  v:set_yaw_by_direction(dir)

  --if villager is stoped by obstacle, the villager must jump.
  v:handle_obstacles(true)
end

function follower.stop(v)
  local velocity = v.object:get_velocity()
  if velocity.x~=0 or velocity.y~=0 then
    v:set_animation(simple_working_villages.animation_frames.STAND)
    v.object:set_velocity{x = 0, y = velocity.y, z = 0}
  end
end

function follower.step(v)
  local position = v.object:get_pos()
  local player,player_position = v:get_nearest_player(20,position)
  local direction = vector.new(0,0,0)



  if player~=nil then
    direction = vector.subtract(player_position, position)
  end

  if vector.length(direction) < 3 then
    --swim upward
    if direction.y > 1 and minetest.get_item_group(minetest.get_node(position).name,"liquid") > 0 then
      v:jump()
    end

    follower.stop(v)
  else
    follower.walk_in_direction(v,direction)
  end
end

simple_working_villages.register_job("simple_working_villages:job_folow_player", {
	description      = "follower (simple_working_villages)",
	long_description = "I'll just follow you wherever you go.",
	inventory_image  = "default_paper.png^memorandum_letters.png",
	jobfunc = function(v)
		if use_vh1 then VH1.update_bar(v.object, v.health) end
		v:handle_goto_obstacles(true)
		while (v.pause) do
			coroutine.yield()
		end
		local position = v.object:get_pos()
		local player,player_position = v:get_nearest_player(40,position)
		if player_position ~= nil then
			if vector.distance(player_position,position) > 5 then
				local dest = func.get_closest_clear_spot(position, player_position)
				if dest ~= nil then
					v:go_to(dest)
				else
					print("NO DESTINATION FOUND")
				end
			end
		end
	end,
})

return follower
