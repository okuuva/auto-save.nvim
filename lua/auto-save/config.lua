--- @class Config
Config = {
  opts = {
    enabled = true, -- start auto-save when the plugin is loaded (i.e. when your package manager loads it)
    trigger_events = { -- See :h events
      --- @type TriggerEvent[]?
      immediate_save = { "BufLeave", "FocusLost" }, -- vim events that trigger an immediate save
      --- @type TriggerEvent[]?
      defer_save = { "InsertLeave", "TextChanged" }, -- vim events that trigger a deferred save (saves after `debounce_delay`)
      --- @type TriggerEvent[]?
      cancel_deferred_save = { "InsertEnter" }, -- vim events that cancel a pending deferred save
    },
    -- function that takes the buffer handle and determines whether to save the current buffer or not
    -- return true: if buffer is ok to be saved
    -- return false: if it's not ok to be saved
    -- if set to `nil` then no specific condition is applied
    --- @type nil|fun(buf: number): boolean
    condition = nil,
    write_all_buffers = false, -- write all buffers when the current one meets `condition`
    noautocmd = false, -- do not execute autocmds when saving
    lockmarks = false, -- lock marks when saving, see `:h lockmarks` for more details
    debounce_delay = 1000, -- delay after which a pending save is executed
    -- log debug messages to 'auto-save.log' file in neovim cache directory, set to `true` to enable
    debug = false, -- print debug messages, set to `true` to enable
  },
}

function Config:handle_deprecations(custom_opts)
  if custom_opts["execution_message"] then
    vim.notify(
      "The `execution_message` has been removed from the auto-save.nvim plugin. Check the Readme on how to add it yourself.",
      vim.log.levels.WARN
    )
    custom_opts["execution_message"] = nil
  end

  return custom_opts
end

function Config:set_options(custom_opts)
  custom_opts = custom_opts or {}

  custom_opts = self.handle_deprecations(custom_opts)

  self.opts = vim.tbl_deep_extend("keep", custom_opts, self.opts)
end

function Config:get_options()
  return self.opts
end

return Config
