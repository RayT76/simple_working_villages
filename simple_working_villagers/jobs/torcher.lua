local fail = simple_working_villages.require("failures")
local log = simple_working_villages.require("log")
local co_command = simple_working_villages.require("job_coroutines").commands
local follower = simple_working_villages.require("jobs/follow_player")
local use_vh1 = minetest.get_modpath("visual_harm_1ndicators")

local torcher = {}

function torcher.is_dark(pos)
	local light_level = minetest.get_node_light(pos)
	return light_level <= 5
end

function torcher.is_walkable(nodename)
  if minetest.registered_nodes[nodename] == nil then
    return true
  end
  return minetest.registered_nodes[nodename].walkable
end

function torcher.place_torch_at(v,pos)
  local support = minetest.get_node(vector.add(pos,{x=0,y=-1,z=0}))
  if not torcher.is_walkable(support.name) then
    --TODO: try elsewhere
    log.verbose("no ground to support torch in front of villager %s", v.inventory_name)
    return
  end
  --perhaps check if there are nodes to the at the sides to support the torch and place to walls
  local sucess, ret = v:place("default:torch",pos)
  if sucess == false then
    if ret == fail.too_far then
      log.error("torch placement in front of villager %s was too far away", v.inventory_name)
    elseif ret == fail.blocked then
      --TODO:try elsewhere
      log.verbose("pos in front of villager %s blocked", v.inventory_name)
    elseif ret == fail.not_in_inventory then
      local msg = "Hey wait, I don't have any more torches!"
      local player = v:get_nearest_player(10)
      if player ~= nil then
        minetest.chat_send_player(player:get_player_name(),msg)
      elseif v.owner_name then
        minetest.chat_send_player(v.owner_name,msg)
      else
        print(("torcher at %s doesn't have torches"):format(minetest.pos_to_string(v.object:get_pos())))
      end
      return co_command.pause,"in need of torches"
    else
      log.error("unknown failure in torch placement of villager %s: %s",v.inventory_name,ret)
    end
  end
end

simple_working_villages.register_job("simple_working_villages:job_torcher", {
	description      = "torcher (simple_working_villages)",
	long_description = "I'm following the nearest player enlightning his way by placing torches.",
	inventory_image  = "default_paper.png^working_villages_torcher.png",
	jobfunc = function(self)
		if use_vh1 then VH1.update_bar(self.object, self.health) end
		while (self.pause) do
			coroutine.yield()
		end
		local position = self.object:get_pos()
		if torcher.is_dark(position) then
			local front = self:get_front() -- if it is dark, set torch.
			if torcher.is_dark(front) then
				local comm, dat = torcher.place_torch_at(self,front)
				if comm ~= nil then
				  return comm, dat
				end
			end
		end
		follower.step(self)
	end,
})

return torcher
