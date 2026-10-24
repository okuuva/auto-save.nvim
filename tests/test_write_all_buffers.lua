local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality

local T = new_set({ hooks = {
  pre_case = function()
    reset_plugin_state()
  end,
} })

T["saves all modified buffers when `write_all_buffers` is true"] = function()
  local first_path = vim.fn.tempname()
  local second_path = vim.fn.tempname()
  vim.fn.writefile({ "first" }, first_path)
  vim.fn.writefile({ "second" }, second_path)

  vim.cmd("edit " .. vim.fn.fnameescape(first_path))
  local first_buf = vim.api.nvim_get_current_buf()
  vim.cmd("edit " .. vim.fn.fnameescape(second_path))
  local second_buf = vim.api.nvim_get_current_buf()

  require("auto-save").setup({
    write_all_buffers = true,
    trigger_events = { defer_save = {} },
  })

  vim.api.nvim_buf_set_lines(first_buf, 0, -1, false, { "changed first" })
  vim.api.nvim_buf_set_lines(second_buf, 0, -1, false, { "changed second" })
  eq(vim.fn.readfile(first_path), { "first" })
  eq(vim.fn.readfile(second_path), { "second" })

  vim.cmd("enew")
  eq(vim.fn.readfile(first_path), { "changed first" })
  eq(vim.fn.readfile(second_path), { "changed second" })

  vim.cmd("silent! bwipeout! " .. first_buf)
  vim.cmd("silent! bwipeout! " .. second_buf)
  os.remove(first_path)
  os.remove(second_path)
end

T["saves only the current buffer when `write_all_buffers` is false"] = function()
  local first_path = vim.fn.tempname()
  local second_path = vim.fn.tempname()
  vim.fn.writefile({ "first" }, first_path)
  vim.fn.writefile({ "second" }, second_path)

  vim.cmd("edit " .. vim.fn.fnameescape(first_path))
  local first_buf = vim.api.nvim_get_current_buf()
  vim.cmd("edit " .. vim.fn.fnameescape(second_path))
  local second_buf = vim.api.nvim_get_current_buf()

  require("auto-save").setup({
    write_all_buffers = false,
    trigger_events = { defer_save = {} },
  })

  vim.api.nvim_buf_set_lines(first_buf, 0, -1, false, { "changed first" })
  vim.api.nvim_buf_set_lines(second_buf, 0, -1, false, { "changed second" })
  eq(vim.fn.readfile(first_path), { "first" })
  eq(vim.fn.readfile(second_path), { "second" })

  vim.cmd("enew")
  eq(vim.fn.readfile(first_path), { "first" })
  eq(vim.fn.readfile(second_path), { "changed second" })

  vim.cmd("silent! bwipeout! " .. first_buf)
  vim.cmd("silent! bwipeout! " .. second_buf)
  os.remove(first_path)
  os.remove(second_path)
end

return T
