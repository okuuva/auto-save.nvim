local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality

local T = new_set({ hooks = {
  pre_case = function()
    reset_plugin_state()
  end,
} })

T["preserves marks while saving when `lockmarks` is true"] = function()
  local path = vim.fn.tempname()
  vim.fn.writefile({ "one", "two", "three" }, path)
  vim.cmd("edit " .. vim.fn.fnameescape(path))
  local buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_mark(buf, "a", 2, 0, {})

  local group = vim.api.nvim_create_augroup("TestLockmarks", { clear = true })
  vim.api.nvim_create_autocmd("BufWritePre", {
    buffer = buf,
    group = group,
    callback = function()
      vim.api.nvim_buf_set_lines(buf, 0, 0, false, { "before" })
    end,
  })

  require("auto-save").setup({
    lockmarks = true,
    trigger_events = { defer_save = {} },
  })

  vim.api.nvim_buf_set_lines(buf, 2, 3, false, { "changed" })
  vim.cmd("enew")

  eq(vim.fn.readfile(path), { "before", "one", "two", "changed" })
  eq(vim.api.nvim_buf_get_mark(buf, "a"), { 2, 0 })

  vim.cmd("silent! bwipeout! " .. buf)
  vim.api.nvim_del_augroup_by_id(group)
  os.remove(path)
end

T["moves marks while saving when `lockmarks` is false"] = function()
  local path = vim.fn.tempname()
  vim.fn.writefile({ "one", "two", "three" }, path)
  vim.cmd("edit " .. vim.fn.fnameescape(path))
  local buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_mark(buf, "a", 2, 0, {})

  local group = vim.api.nvim_create_augroup("TestLockmarks", { clear = true })
  vim.api.nvim_create_autocmd("BufWritePre", {
    buffer = buf,
    group = group,
    callback = function()
      vim.api.nvim_buf_set_lines(buf, 0, 0, false, { "before" })
    end,
  })

  require("auto-save").setup({
    lockmarks = false,
    trigger_events = { defer_save = {} },
  })

  vim.api.nvim_buf_set_lines(buf, 2, 3, false, { "changed" })
  vim.cmd("enew")

  eq(vim.fn.readfile(path), { "before", "one", "two", "changed" })
  eq(vim.api.nvim_buf_get_mark(buf, "a"), { 3, 0 })

  vim.cmd("silent! bwipeout! " .. buf)
  vim.api.nvim_del_augroup_by_id(group)
  os.remove(path)
end

return T
