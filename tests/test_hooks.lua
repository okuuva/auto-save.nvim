local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality

local T = new_set({ hooks = {
  pre_case = function()
    reset_plugin_state()
  end,
} })

T["fires auto-save lifecycle hooks"] = function()
  local events = {}
  local path = vim.fn.tempname()
  vim.fn.writefile({ "initial" }, path)
  vim.cmd("edit " .. vim.fn.fnameescape(path))
  local buf = vim.api.nvim_get_current_buf()

  local group = vim.api.nvim_create_augroup("TestAutoSaveHooks", { clear = true })
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

  vim.cmd("silent! bwipeout! " .. buf)
  vim.api.nvim_del_augroup_by_id(group)
  os.remove(path)
end

return T
