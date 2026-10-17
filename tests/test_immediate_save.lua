local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality

local T = new_set({ hooks = {
  pre_case = function()
    reset_plugin_state()
  end,
} })

T["saves modified buffer immediately after `immediate_save` event"] = function()
  local path = vim.fn.tempname()
  vim.fn.writefile({ "initial" }, path)
  vim.cmd("edit " .. vim.fn.fnameescape(path))
  local buf = vim.api.nvim_get_current_buf()

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

  vim.cmd("silent! bwipeout! " .. buf)
  os.remove(path)
end

return T
