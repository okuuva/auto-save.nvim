local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality

local T = new_set({
  hooks = { pre_case = reset_plugin_state },
  parametrize = {
    { true, false },
    { false, true },
  },
})

T["runs write autocmds according to `noautocmd`"] = function(noautocmd, expected)
  local path, buf = setup_test_file({ "initial" })

  local write_autocmd_ran = false
  local group = vim.api.nvim_create_augroup("TestNoautocmd", { clear = true })
  MiniTest.finally(function()
    vim.api.nvim_del_augroup_by_id(group)
  end)
  vim.api.nvim_create_autocmd("BufWritePre", {
    buffer = buf,
    group = group,
    callback = function()
      write_autocmd_ran = true
    end,
  })

  require("auto-save").setup({
    noautocmd = noautocmd,
    trigger_events = { defer_save = {} },
  })

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "changed" })
  vim.cmd("enew")

  eq(vim.fn.readfile(path), { "changed" })
  eq(write_autocmd_ran, expected)
end

return T
