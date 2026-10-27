local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality

local T = new_set({ hooks = {
  pre_case = reset_plugin_state,
} })

T["does not save modified buffer when `enabled` is false"] = function()
  local path = setup_test_file({ "initial" })

  require("auto-save").setup({ enabled = false })

  -- No save happens after editing
  local keys = vim.api.nvim_replace_termcodes("ihello<Esc>", true, false, true)
  vim.api.nvim_feedkeys(keys, "x", true)
  eq(vim.fn.readfile(path), { "initial" })

  -- BufLeave does not save while the plugin is disabled
  vim.cmd("enew!")
  eq(vim.fn.readfile(path), { "initial" })
end

return T
