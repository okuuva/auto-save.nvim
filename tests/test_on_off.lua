local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality

local T = new_set({ hooks = {
  pre_case = reset_plugin_state,
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

T["off() stops saving and on() resumes it"] = function()
  local auto_save = require("auto-save")
  local path, buf = setup_test_file({ "initial" })
  auto_save.setup({ trigger_events = { defer_save = {} } })

  auto_save.off()
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "changed while disabled" })
  vim.cmd("enew!")
  eq(vim.fn.readfile(path), { "initial" })

  auto_save.on()
  vim.cmd("buffer " .. buf)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "changed while enabled" })
  vim.cmd("enew!")
  eq(vim.fn.readfile(path), { "changed while enabled" })
end

return T
