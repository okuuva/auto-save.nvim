local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality

local T = new_set({ hooks = {
  pre_case = reset_plugin_state,
} })

T["saves modified buffer immediately after `immediate_save` event"] = function()
  local path = setup_test_file({ "initial" })

  -- disable deferred_save
  require("auto-save").setup({
    trigger_events = {
      defer_save = {},
    },
  })

  -- No save happens after editing
  local keys = vim.api.nvim_replace_termcodes("ihello<Esc>", true, false, true)
  vim.api.nvim_feedkeys(keys, "x", true)
  eq(vim.fn.readfile(path), { "initial" })

  -- Save happens after BufLeave
  vim.cmd("enew")
  eq(vim.fn.readfile(path), { "helloinitial" })
end

return T
