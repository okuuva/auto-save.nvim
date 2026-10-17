local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality

local T = new_set({ hooks = {
  pre_case = function()
    reset_plugin_state()
  end,
} })

T["on() enables auto-save"] = function()
  local auto_save = require("auto-save")
  auto_save.setup({ enabled = false })

  eq(auto_save.enabled(), false)
  auto_save.on()
  eq(auto_save.enabled(), true)
end

T["off() disables auto-save"] = function()
  local auto_save = require("auto-save")
  auto_save.setup({ enabled = true })

  eq(auto_save.enabled(), true)
  auto_save.off()
  eq(auto_save.enabled(), false)
end

return T
