local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality

local T = new_set({ hooks = {
  pre_case = function()
    reset_plugin_state()
  end,
} })

T["cancels pending deferred save on `cancel_deferred_save` event"] = function()
  local path = vim.fn.tempname()
  vim.fn.writefile({ "initial" }, path)
  vim.cmd("edit " .. vim.fn.fnameescape(path))

  require("auto-save").setup({ debounce_delay = 100 })

  -- InsertLeave (on <Esc>) defers a save, no save yet
  local keys = vim.api.nvim_replace_termcodes("ihello<Esc>", true, false, true)
  vim.api.nvim_feedkeys(keys, "x", true)
  eq(vim.fn.readfile(path), { "initial" })

  -- InsertEnter (default `cancel_deferred_save` event) cancels the pending save
  -- File stays untouched even after the debounce delay has passed
  vim.cmd("doautocmd InsertEnter")
  vim.wait(300, function() return false end)
  eq(vim.fn.readfile(path), { "initial" })

  vim.cmd("silent! bwipeout!")
  os.remove(path)
end

return T
