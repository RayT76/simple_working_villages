simple_working_villages.register_job("simple_working_villages:job_empty", {
	description      = "empty (simple_working_villages)",
	inventory_image  = "default_paper.png",
	jobfunc          = function() end,
})

-- only a recipe of the empty job is registered.
-- other job is created by writing on the empty job.
minetest.register_craft{
	output = "simple_working_villages:job_empty",
	recipe = {
		{"default:paper", "default:obsidian"},
	},
}
