function simple_working_villages.villager:set_pause(state)
  assert(type(state) == "boolean","pause state must be a boolean")
  self.pause = state
  if state then
    self.object:set_velocity{x = 0, y = 0, z = 0}
    --perhaps check what animation we are in
    self:set_animation(simple_working_villages.animation_frames.STAND)
  end
end

-- simple_working_villages.villager.set_displayed_action sets the text to be displayed after "this villager is "
function simple_working_villages.villager:set_displayed_action(action)
  assert(type(action) == "string","action info must be a string")
  if self.disp_action ~= action then
    self.disp_action = action
    self:update_infotext()
  end
end

-- set the text describing what the villager currently does
-- the text should be a detailed information
function simple_working_villages.villager:set_state_info(text)
  assert(type(text) == "string","state info must be a string")
  self.state_info = text
end
