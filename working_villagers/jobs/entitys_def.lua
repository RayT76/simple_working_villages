--local func = working_villages.require("jobs/util")

local entity = {
	names = {
		["working_villages:villager_male"]={npc=true},
		["working_villages:villager_female"]={npc=true},
		["mobs_npc:npc"]={npc=true},
		["mobs_npc:igor"]={npc=true},
		["mobs_npc:trader"]={npc=true},

		["visual_harm_1ndicators:hpbar"]={dummy=true},
		["working_villages:dummy_item"]={dummy=true},
		["__builtin:item"]={dummy=true},

		["mobs_monster:dirt_monster"]={monster=true},
		["mobs_monster:fire_spirit"]={monster=true},
		["mobs_monster:land_guard"]={monster=true},
		["mobs_monster:lava_flan"]={monster=true},
		["mobs_monster:mese_monster"]={monster=true},
		["mobs_monster:obsidian_flan"]={monster=true},
		["mobs_monster:oerkki"]={monster=true},
		["mobs_monster:sand_monster"]={monster=true},
		["mobs_monster:spider"]={monster=true},
		["mobs_monster:stone_monster"]={monster=true},
		["mobs_monster:tree_monster"]={monster=true},

		["mobs_skeletons:skeleton_archer"]={monster=true},
		["mobs_skeletons:skeleton_archer_dark"]={monster=true},
		["mobs_skeletons:skeleton"]={monster=true},

		["mobs_monster:dirt_monster"]={monster=true},
		["mobs_monster:dirt_monster"]={monster=true},
		["mobs_monster:dirt_monster"]={monster=true},
		["mobs_monster:dirt_monster"]={monster=true},
		["mobs_monster:dirt_monster"]={monster=true},
		["mobs_monster:dirt_monster"]={monster=true},

		["mobs_animal:sheep_"]={animal=true},
		["mobs_animal:pumba"]={animal=true},
		["mobs_animal:chicken"]={animal=true},
		["mobs_animal:panda"]={animal=true},
		["mobs_animal:penguin"]={animal=true},
		["mobs_animal:bunny"]={animal=true},
		["mobs_animal:bee"]={animal=true},
		["mobs_animal:cow"]={animal=true},
		["mobs_animal:kitten"]={animal=true},
		["mobs_animal:rat"]={animal=true},
	},
}


function entity.get_entity(entity_name)
	for key, value in pairs(entity.names) do
		if item_name==key then
			return value
		end
	end
	return nil
end








