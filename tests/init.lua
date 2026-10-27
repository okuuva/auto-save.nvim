-- Disable automatic plugin loading
vim.opt.loadplugins = false

-- The plugin itself
vim.opt.runtimepath:prepend(vim.fn.getcwd())

-- mini.test
vim.opt.runtimepath:append(vim.fn.getcwd() .. "/tests/.deps/mini.nvim")

-- Explicitly load the plugin and mini.test
vim.cmd("runtime plugin/auto-save.lua")
require("mini.test").setup()

-- Reset plugin state so every test starts from pristine defaults.
-- `auto-save.config` mutates `Config.opts` across `setup` calls, and the
-- `auto-save` module caches the debounced save function.
_G.reset_plugin_state = function()
  package.loaded["auto-save"] = nil
  package.loaded["auto-save.config"] = nil
end

--- Create a temporary file, open it and schedule its cleanup after the test.
--- @param lines string[]
--- @param path? string
--- @return string path
--- @return integer buf
_G.setup_test_file = function(lines, path)
  path = path or vim.fn.tempname()
  vim.fn.writefile(lines, path)
  vim.cmd("edit " .. vim.fn.fnameescape(path))
  local buf = vim.api.nvim_get_current_buf()

  MiniTest.finally(function()
    vim.cmd("silent! bwipeout! " .. buf)
    os.remove(path)
  end)

  return path, buf
end
