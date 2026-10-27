local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality

local T = new_set({
  hooks = { pre_case = reset_plugin_state },
  parametrize = {
    { true, { "changed first" }, { "changed second" } },
    { false, { "first" }, { "changed second" } },
  },
})

T["writes buffers according to `write_all_buffers`"] = function(write_all_buffers, expected_first, expected_second)
  local first_path, first_buf = setup_test_file({ "first" })
  local second_path, second_buf = setup_test_file({ "second" })

  require("auto-save").setup({
    write_all_buffers = write_all_buffers,
    trigger_events = { defer_save = {} },
  })

  vim.api.nvim_buf_set_lines(first_buf, 0, -1, false, { "changed first" })
  vim.api.nvim_buf_set_lines(second_buf, 0, -1, false, { "changed second" })
  eq(vim.fn.readfile(first_path), { "first" })
  eq(vim.fn.readfile(second_path), { "second" })

  vim.cmd("enew")
  eq(vim.fn.readfile(first_path), expected_first)
  eq(vim.fn.readfile(second_path), expected_second)
end

return T
