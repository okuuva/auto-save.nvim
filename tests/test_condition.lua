local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality

local excluded_filetypes = { "gitcommit" }
local excluded_filenames = { "do-not-autosave-me.lua" }

local function save_condition(buf)
  if
    vim.tbl_contains(excluded_filetypes, vim.fn.getbufvar(buf, "&filetype"))
    or vim.tbl_contains(excluded_filenames, vim.fn.expand("%:t"))
  then
    return false
  end
  return true
end

local T = new_set({ hooks = {
  pre_case = reset_plugin_state,
} })

T["condition works with excluded filetypes"] = function()
  local path, buf = setup_test_file({ "initial" })
  vim.bo[buf].filetype = "gitcommit"

  require("auto-save").setup({
    condition = save_condition,
    trigger_events = { defer_save = {} },
  })

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "changed" })
  vim.cmd("enew!")
  eq(vim.fn.readfile(path), { "initial" })
end

T["condition works with excluded filenames"] = function()
  local dir = vim.fn.tempname()
  vim.fn.mkdir(dir, "p")
  local path, buf = setup_test_file({ "initial" }, dir .. "/do-not-autosave-me.lua")
  MiniTest.finally(function()
    vim.fn.delete(dir, "d")
  end)

  require("auto-save").setup({
    condition = save_condition,
    trigger_events = { defer_save = {} },
  })

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "changed" })
  vim.cmd("enew!")
  eq(vim.fn.readfile(path), { "initial" })
end

T["condition works with special buffers"] = function()
  local buf = vim.api.nvim_create_buf(true, false)
  vim.bo[buf].buftype = "nofile"
  vim.api.nvim_set_current_buf(buf)

  local save_started = false
  local buf_leave_ran = false
  local group = vim.api.nvim_create_augroup("TestCondition", { clear = true })
  MiniTest.finally(function()
    vim.api.nvim_del_augroup_by_id(group)
    vim.cmd("silent! bwipeout! " .. buf)
  end)
  vim.api.nvim_create_autocmd("BufLeave", {
    buffer = buf,
    group = group,
    callback = function()
      buf_leave_ran = true
    end,
  })
  vim.api.nvim_create_autocmd("User", {
    pattern = "AutoSaveWritePre",
    group = group,
    callback = function(opts)
      save_started = opts.data.saved_buffer == buf
    end,
  })

  require("auto-save").setup({
    condition = function(buffer)
      if vim.fn.getbufvar(buffer, "&buftype") ~= "" then
        return false
      end
      return true
    end,
    trigger_events = { defer_save = {} },
  })

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "changed" })
  vim.cmd("enew!")
  eq(buf_leave_ran, true)
  eq(save_started, false)
end

T["condition allows non-excluded buffers"] = function()
  local path, buf = setup_test_file({ "initial" })

  require("auto-save").setup({
    condition = save_condition,
    trigger_events = { defer_save = {} },
  })

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "changed" })
  vim.cmd("enew")
  eq(vim.fn.readfile(path), { "changed" })
end

return T
