local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality

local T = new_set({ hooks = {
  pre_case = reset_plugin_state,
} })

T["fires auto-save lifecycle hooks"] = function()
  local events = {}
  local group = vim.api.nvim_create_augroup("TestAutoSaveHooks", { clear = true })
  MiniTest.finally(function()
    vim.api.nvim_del_augroup_by_id(group)
  end)
  local path, buf = setup_test_file({ "initial" })

  for _, event in ipairs({ "AutoSaveEnable", "AutoSaveWritePre", "AutoSaveWritePost", "AutoSaveDisable" }) do
    local name = event
    vim.api.nvim_create_autocmd("User", {
      pattern = name,
      group = group,
      callback = function(opts)
        local event_data = { name = name }
        if name == "AutoSaveWritePre" or name == "AutoSaveWritePost" then
          event_data.saved_buffer = opts.data and opts.data.saved_buffer
          event_data.file_contents = vim.fn.readfile(path)
        end
        table.insert(events, event_data)
      end,
    })
  end

  local auto_save = require("auto-save")
  auto_save.setup({ trigger_events = { defer_save = {} } })
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "changed" })
  vim.cmd("enew")
  auto_save.off()

  eq(events, {
    { name = "AutoSaveEnable" },
    { name = "AutoSaveWritePre", saved_buffer = buf, file_contents = { "initial" } },
    { name = "AutoSaveWritePost", saved_buffer = buf, file_contents = { "changed" } },
    { name = "AutoSaveDisable" },
  })
  eq(vim.fn.readfile(path), { "changed" })
end

return T
