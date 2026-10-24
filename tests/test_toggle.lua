local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality

local T = new_set({ hooks = {
  pre_case = function()
    reset_plugin_state()
  end,
} })

T["ASToggle toggles auto-save"] = function()
  local auto_save = require("auto-save")
  auto_save.setup({ enabled = true })

  eq(auto_save.enabled(), true)
  vim.cmd("ASToggle")
  eq(auto_save.enabled(), false)
  vim.cmd("ASToggle")
  eq(auto_save.enabled(), true)
end

T["toggle() toggles auto-save"] = function()
  local auto_save = require("auto-save")
  auto_save.setup({ enabled = true })

  auto_save.toggle()
  eq(auto_save.enabled(), false)
  auto_save.toggle()
  eq(auto_save.enabled(), true)
end

return T
