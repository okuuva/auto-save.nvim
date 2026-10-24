local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality

local T = new_set({ hooks = {
  pre_case = function()
    reset_plugin_state()
  end,
} })

T["saves modified buffer after debounce_delay after `defer_save` event"] = function()
  local path = vim.fn.tempname()
  vim.fn.writefile({ "initial" }, path)
  vim.cmd("edit " .. vim.fn.fnameescape(path))

  require("auto-save").setup({ debounce_delay = 100 })

  -- InsertLeave (on <Esc>) defers a save, no save yet
  local keys = vim.api.nvim_replace_termcodes("ihello<Esc>", true, false, true)
  vim.api.nvim_feedkeys(keys, "x", true)
  eq(vim.fn.readfile(path), { "initial" })

  -- Save lands after the debounce delay
  eq(
    vim.wait(2000, function()
      return vim.fn.readfile(path)[1] == "helloinitial"
    end),
    true
  )
  eq(vim.fn.readfile(path), { "helloinitial" })

  vim.cmd("silent! bwipeout!")
  os.remove(path)
end

T["resets debounce delay after repeated edits"] = function()
  local path = vim.fn.tempname()
  vim.fn.writefile({ "initial" }, path)
  vim.cmd("edit " .. vim.fn.fnameescape(path))
  local buf = vim.api.nvim_get_current_buf()

  require("auto-save").setup({
    debounce_delay = 1000,
    trigger_events = { cancel_deferred_save = {} },
  })

  local keys = vim.api.nvim_replace_termcodes("ihello<Esc>", true, false, true)
  vim.api.nvim_feedkeys(keys, "x", true)
  vim.wait(400, function()
    return false
  end)
  eq(vim.fn.readfile(path), { "initial" })

  keys = vim.api.nvim_replace_termcodes("Aagain<Esc>", true, false, true)
  vim.api.nvim_feedkeys(keys, "x", true)
  vim.wait(750, function()
    return false
  end)
  eq(vim.fn.readfile(path), { "initial" })

  eq(
    vim.wait(2000, function()
      return vim.fn.readfile(path)[1] == "helloinitialagain"
    end),
    true
  )
  eq(vim.fn.readfile(path), { "helloinitialagain" })

  vim.cmd("silent! bwipeout! " .. buf)
  os.remove(path)
end

return T
