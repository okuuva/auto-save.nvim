local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality

local T = new_set({
  hooks = { pre_case = reset_plugin_state },
  parametrize = {
    { true, { 2, 0 } },
    { false, { 3, 0 } },
  },
})

T["preserves marks while saving according to `lockmarks`"] = function(lockmarks, expected_mark)
  local path, buf = setup_test_file({ "one", "two", "three" })
  vim.api.nvim_buf_set_mark(buf, "a", 2, 0, {})

  local group = vim.api.nvim_create_augroup("TestLockmarks", { clear = true })
  MiniTest.finally(function()
    vim.api.nvim_del_augroup_by_id(group)
  end)
  vim.api.nvim_create_autocmd("BufWritePre", {
    buffer = buf,
    group = group,
    callback = function()
      vim.api.nvim_buf_set_lines(buf, 0, 0, false, { "before" })
    end,
  })

  require("auto-save").setup({
    lockmarks = lockmarks,
    trigger_events = { defer_save = {} },
  })

  vim.api.nvim_buf_set_lines(buf, 2, 3, false, { "changed" })
  vim.cmd("enew")

  eq(vim.fn.readfile(path), { "before", "one", "two", "changed" })
  eq(vim.api.nvim_buf_get_mark(buf, "a"), expected_mark)
end

return T
