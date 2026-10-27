local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality

local T = new_set({ hooks = {
  pre_case = reset_plugin_state,
} })

T["cancels pending deferred save on `cancel_deferred_save` event"] = function()
  local path = setup_test_file({ "initial" })

  require("auto-save").setup({ debounce_delay = 100 })

  -- InsertLeave (on <Esc>) defers a save, no save yet
  local keys = vim.api.nvim_replace_termcodes("ihello<Esc>", true, false, true)
  vim.api.nvim_feedkeys(keys, "x", true)
  eq(vim.fn.readfile(path), { "initial" })

  -- InsertEnter (default `cancel_deferred_save` event) cancels the pending save
  -- File stays untouched even after the debounce delay has passed
  vim.cmd("doautocmd InsertEnter")
  vim.wait(300, function()
    return false
  end)
  eq(vim.fn.readfile(path), { "initial" })
end

T["cancels a pending save even when condition has become false"] = function()
  local path, buf = setup_test_file({ "initial" })
  local allowed = true

  require("auto-save").setup({
    debounce_delay = 100,
    condition = function()
      return allowed
    end,
    trigger_events = {
      immediate_save = {},
      defer_save = { "InsertLeave" },
      cancel_deferred_save = { "InsertEnter" },
    },
  })

  local keys = vim.api.nvim_replace_termcodes("ihello<Esc>", true, false, true)
  vim.api.nvim_feedkeys(keys, "x", true)
  eq(vim.fn.readfile(path), { "initial" })
  allowed = false
  vim.cmd("doautocmd InsertEnter")

  -- Re-allow saving so a missed cancellation cannot be hidden by the recheck.
  allowed = true
  vim.wait(300, function()
    return false
  end)

  eq(vim.fn.readfile(path), { "initial" })
  eq(vim.bo[buf].modified, true)
end

return T
