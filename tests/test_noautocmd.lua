local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality

local T = new_set({ hooks = {
  pre_case = function()
    reset_plugin_state()
  end,
} })

T["skips write autocmds when `noautocmd` is true"] = function()
  local path = vim.fn.tempname()
  vim.fn.writefile({ "initial" }, path)
  vim.cmd("edit " .. vim.fn.fnameescape(path))
  local buf = vim.api.nvim_get_current_buf()
  local write_autocmd_ran = false
  local group = vim.api.nvim_create_augroup("TestNoautocmd", { clear = true })
  vim.api.nvim_create_autocmd("BufWritePre", {
    buffer = buf,
    group = group,
    callback = function()
      write_autocmd_ran = true
    end,
  })

  require("auto-save").setup({
    noautocmd = true,
    trigger_events = { defer_save = {} },
  })

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "changed" })
  vim.cmd("enew")

  eq(vim.fn.readfile(path), { "changed" })
  eq(write_autocmd_ran, false)

  vim.cmd("silent! bwipeout! " .. buf)
  vim.api.nvim_del_augroup_by_id(group)
  os.remove(path)
end

T["runs write autocmds when `noautocmd` is false"] = function()
  local path = vim.fn.tempname()
  vim.fn.writefile({ "initial" }, path)
  vim.cmd("edit " .. vim.fn.fnameescape(path))
  local buf = vim.api.nvim_get_current_buf()
  local write_autocmd_ran = false
  local group = vim.api.nvim_create_augroup("TestNoautocmd", { clear = true })
  vim.api.nvim_create_autocmd("BufWritePre", {
    buffer = buf,
    group = group,
    callback = function()
      write_autocmd_ran = true
    end,
  })

  require("auto-save").setup({
    noautocmd = false,
    trigger_events = { defer_save = {} },
  })

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "changed" })
  vim.cmd("enew")

  eq(vim.fn.readfile(path), { "changed" })
  eq(write_autocmd_ran, true)

  vim.cmd("silent! bwipeout! " .. buf)
  vim.api.nvim_del_augroup_by_id(group)
  os.remove(path)
end

return T
