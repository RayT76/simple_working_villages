local forms = simple_working_villages.require("forms")

forms.register_menu_page("simple_working_villages:talking_menu", "hello")

forms.register_text_page("simple_working_villages:job_desc",
	function(villager)
		local job = villager:get_job()
		if not job then
			return "I don't have a job."
		end
		return job.long_description or "something..."
end)

forms.put_link("simple_working_villages:talking_menu", "simple_working_villages:job_desc",
	"What do you do in your job?")

forms.register_text_page("simple_working_villages:state",
  function(villager)
    return villager.state_info
end)

forms.put_link("simple_working_villages:talking_menu", "simple_working_villages:state",
  "What do you doing at the moment?")

