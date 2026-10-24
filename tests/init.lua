-- The plugin itself
vim.opt.runtimepath:prepend(vim.fn.getcwd())

-- mini.test
vim.opt.runtimepath:append(vim.fn.getcwd() .. "/tests/.deps/mini.nvim")
require("mini.test").setup()

-- Reset plugin state so every test starts from pristine defaults.
-- `auto-save.config` mutates `Config.opts` across `setup` calls, and the
-- `auto-save` module caches the debounced save function.
_G.reset_plugin_state = function()
  package.loaded["auto-save"] = nil
  package.loaded["auto-save.config"] = nil
end
