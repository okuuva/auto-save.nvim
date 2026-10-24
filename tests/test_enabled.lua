local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality

local T = new_set({ hooks = {
  pre_case = function()
    reset_plugin_state()
  end,
} })

T["does not save modified buffer when `enabled` is false"] = function()
  local path = vim.fn.tempname()
  vim.fn.writefile({ "initial" }, path)
  vim.cmd("edit " .. vim.fn.fnameescape(path))
  local buf = vim.api.nvim_get_current_buf()

  require("auto-save").setup({ enabled = false })

  -- No save happens after editing
  local keys = vim.api.nvim_replace_termcodes("ihello<Esc>", true, false, true)
  vim.api.nvim_feedkeys(keys, "x", true)
  eq(vim.fn.readfile(path), { "initial" })

  -- BufLeave does not save while the plugin is disabled
  vim.cmd("enew!")
  eq(vim.fn.readfile(path), { "initial" })

  vim.cmd("silent! bwipeout! " .. buf)
  os.remove(path)
end

return T
