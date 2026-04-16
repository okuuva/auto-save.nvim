<!-- panvimdoc-ignore-start -->
<p align="center">
  <h1 align="center">🧶 auto-save.nvim</h1>
</p>

<p align="center">
  <b>auto-save.nvim</b> is a lua plugin for automatically saving your changed buffers in Neovim<br>
  Forked from <a href="https://github.com/Pocco81/auto-save.nvim">auto-save.nvim</a> as active development has stopped
</p>

<p align="center">
  <a href="https://github.com/okuuva/auto-save.nvim/stargazers">
    <img alt="Stars" src="https://img.shields.io/github/stars/okuuva/auto-save.nvim?style=for-the-badge">
  </a>
  <a href="https://github.com/okuuva/auto-save.nvim/issues">
    <img alt="Issues" src="https://img.shields.io/github/issues/okuuva/auto-save.nvim?style=for-the-badge">
  </a>
  <a href="https://github.com/okuuva/auto-save.nvim/blob/main/LICENSE">
    <img alt="License" src="https://img.shields.io/github/license/okuuva/auto-save.nvim?style=for-the-badge">
  </a>
  <a href="https://github.com/okuuva/auto-save.nvim">
    <img alt="Repo Size" src="https://img.shields.io/github/repo-size/okuuva/auto-save.nvim?style=for-the-badge"/>
  </a>
</p>

<!-- panvimdoc-ignore-end -->

## 📋 Features

- automatically save your changes so the world doesn't collapse
- highly customizable:
  - conditionals to assert whether to save or not
  - events that trigger auto-save
- debounce the save with a delay
- hook into the lifecycle with autocommands
- automatically clean the message area

## 📚 Requirements

- Neovim >= 0.8.0

## 📦 Installation

Install the plugin with your favourite package manager:

### [Lazy.nvim]("https://github.com/folke/lazy.nvim")

```lua
{
  "okuuva/auto-save.nvim",
  version = '^1.1.0', -- see https://devhints.io/semver, alternatively use '*' to use the latest tagged release
  cmd = "ASToggle", -- optional for lazy loading on command
  event = { "InsertLeave", "TextChanged" }, -- optional for lazy loading on trigger events
  opts = {
    -- your config goes here
    -- or just leave it empty :)
  },
},
```

### [Packer.nvim]("https://github.com/wbthomason/packer.nvim")

```lua
use({
  "okuuva/auto-save.nvim",
  tag = 'v1*',
  config = function()
   require("auto-save").setup({
     -- your config goes here
     -- or just leave it empty :)
   })
  end,
})
```

### [vim-plug]("https://github.com/junegunn/vim-plug")

```vim
Plug 'okuuva/auto-save.nvim', { 'tag': 'v1*' }
lua << EOF
  require("auto-save").setup({
    -- your config goes here
    -- or just leave it empty :)
  })
EOF
```

</details>

## ⚙️ Configuration

**auto-save** comes with the following defaults:

```lua
{
  enabled = true, -- start auto-save when the plugin is loaded (i.e. when your package manager loads it)
  trigger_events = { -- See :h events
    immediate_save = { "BufLeave", "FocusLost", "QuitPre", "VimSuspend" }, -- vim events that trigger an immediate save
    defer_save = { "InsertLeave", "TextChanged" }, -- vim events that trigger a deferred save (saves after `debounce_delay`)
    cancel_deferred_save = { "InsertEnter" }, -- vim events that cancel a pending deferred save
  },
  -- function that takes the buffer handle and determines whether to save the current buffer or not
  -- return true: if buffer is ok to be saved
  -- return false: if it's not ok to be saved
  -- if set to `nil` then no specific condition is applied
  condition = nil,
  write_all_buffers = false, -- write all buffers when the current one meets `condition`
  noautocmd = false, -- do not execute autocmds when saving
  lockmarks = false, -- lock marks when saving, see `:h lockmarks` for more details
  debounce_delay = 1000, -- delay after which a pending save is executed
 -- log debug messages to 'auto-save.log' file in neovim cache directory, set to `true` to enable
  debug = false,
}
```

### Trigger Events

The `trigger_events` field of the configuration allows the user to customize at which events **auto-save** saves.
While the default are very sane and should be enough for most usecases, finetuning for extended possibilities is supported.

It is also possible to pass a pattern to a trigger event, if you only want to execute the event on special file patterns:

``` lua
{
  trigger_events = {
    immediate_save = {
      { "BufLeave", pattern = { "*.c", "*.h" } }
    }
  }
}
```

### Condition

The `condition` field of the configuration allows the user to exclude **auto-save** from saving specific buffers.

Here is an example that disables auto-save for specified file types and specific
filenames:

```lua
-- some recommended exclusions. you can use `:lua print(vim.bo.filetype)` to
-- get the filetype string of the current buffer
local excluded_filetypes = {
  -- this one is especially useful if you use neovim as a commit message editor
  "gitcommit",
  -- most of these are usually set to non-modifiable, which prevents autosaving
  -- by default, but it doesn't hurt to be extra safe.
  "NvimTree",
  "Outline",
  "TelescopePrompt",
  "alpha",
  "dashboard",
  "lazygit",
  "neo-tree",
  "oil",
  "prompt",
  "toggleterm",
}

local excluded_filenames = {
  "do-not-autosave-me.lua"
}

local function save_condition(buf)
  if
    vim.tbl_contains(excluded_filetypes, vim.fn.getbufvar(buf, "&filetype"))
    or vim.tbl_contains(excluded_filenames, vim.fn.expand("%:t"))
  then
    return false
  end
  return true
end


-- in your config table
{
  condition = save_condition
}
```

You may also exclude `special-buffers` see (`:h buftype` and `:h special-buffers`):

```lua
{
  condition = function(buf)
    -- don't save for special-buffers
    if vim.fn.getbufvar(buf, "&buftype") ~= '' then
      return false
    end
    return true
  end
}
```

Buffers that are `nomodifiable` are not saved by default.

## 🚀 Usage

Besides running auto-save at startup (if you have `enabled = true` in your config), you may as well:

- `ASToggle`: toggle auto-save

You may want to set up a key mapping for toggling:

```lua
vim.api.nvim_set_keymap("n", "<leader>n", "<cmd>ASToggle<CR>", {})
```

or as part of the `lazy.nvim` plugin spec:

```lua
{
  "okuuva/auto-save.nvim",
  keys = {
    { "<leader>n", "<cmd>ASToggle<CR>", desc = "Toggle auto-save" },
  },
  ...
},
```

## ↩️  Events / Callbacks

The plugin fires events at various points during its lifecycle which users can hook into:

- `AutoSaveWritePre` Just before a buffer is getting saved
- `AutoSaveWritePost` Just after a buffer is getting saved
- `AutoSaveEnable` Just after enabling the plugin
- `AutoSaveDisable` Just after disabling the plugin

It will always supply the current buffer in the `data.saved_buffer`

An example to print a message with the file name after a file got saved:

```lua
local group = vim.api.nvim_create_augroup('autosave', {})

vim.api.nvim_create_autocmd('User', {
    pattern = 'AutoSaveWritePost',
    group = group,
    callback = function(opts)
        if opts.data.saved_buffer ~= nil then
            local filename = vim.api.nvim_buf_get_name(opts.data.saved_buffer)
            vim.notify('AutoSave: saved ' .. filename .. ' at ' .. vim.fn.strftime('%H:%M:%S'), vim.log.levels.INFO)
        end
    end,
})
```

Another example to print a message when enabling/disabling autosave:

```lua
local group = vim.api.nvim_create_augroup('autosave', {})

vim.api.nvim_create_autocmd('User', {
    pattern = 'AutoSaveEnable',
    group = group,
    callback = function(opts)
        vim.notify('AutoSave enabled', vim.log.levels.INFO)
    end,
})

vim.api.nvim_create_autocmd('User', {
    pattern = 'AutoSaveDisable',
    group = group,
    callback = function(opts)
        vim.notify('AutoSave disabled', vim.log.levels.INFO)
    end,
})
```

If you want more Events, feel free to open an issue.

### Combine with formatting

There are some caveats on how to (auto-)format a buffer while using this plugin.
Most of the info here comes from the excellent plugin [stevearc/conform.nvim](https://github.com/stevearc/conform.nvim), especially the [recipes](https://github.com/stevearc/conform.nvim/blob/master/doc/recipes.md#autoformat-with-extra-features).

The easiest way is to format independent of the `modified` state and therefore independ of the auto-save.
Set up a shortcut for one of the following lua functions and format on demand
```
# When using stevearc/conform.nvim (use your own options)
require('conform').format({ async = true, lsp_format = 'fallback' })

# When using lsp formatting capabilities
vim.lsp.buf.format()
```

It is also possible to hook up formating to saving, which creates an auto-format workflow:
- Setup auto-format via autocommand on `BufWritePre` event or via another plugin (check the `format_on_save` option in `conform.nvim`).

Some tips:
- Set `noautocmd = true` in the `auto-save.nvim` options to format only when saving manually
- If using `conform.nvim`, check its `undojoin` option.
It merges the formatting changes with the previous editing changes so that undo reverts both the editing changes and the formatting changes `conform.nvim` might've applied.
Some people find this more intuitive than undoing potential auto formatter changes and the actual changes with separate undos.

## 🍿 snacks.toggle Integration

If you are using [snacks.nvim](https://github.com/folke/snacks.nvim) and you want to add a toggle option for auto-save, simply add the following snippet after calling the plugin's setup function:

```lua
local autosave = require("auto-save")

require("snacks.toggle").new({
  name = "Auto Save",
  get = function()
    return autosave.enabled()
  end,
  set = function(state)
    if state then
      autosave.on()
    else
      autosave.off()
    end
  end,
}):map("<leader>uv")
```

### Example for configuring snacks.toggle with Lazy.nvim

```lua
{
  "okuuva/auto-save.nvim",
  ...
  config = function(_, opts)
    local autosave = require("auto-save")
    autosave.setup(opts)

    require("snacks.toggle").new({
      name = "Auto Save",
      get = function()
         return autosave.enabled()
      end,
      set = function(state)
          if state then
              autosave.on()
          else
              autosave.off()
          end
      end,
    }):map("<leader>uv") -- Or any other keymap (for details, check the snacks.toggle docs at https://github.com/folke/snacks.nvim/blob/main/docs/toggle.md)
  end,
},
```

## 🤝 Contributing

- All pull requests are welcome.
- If you encounter bugs please open an issue.
- Please use [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) when commiting.
  - See [@commitlint/config-conventional](https://github.com/conventional-changelog/commitlint/tree/master/@commitlint/config-conventional) for more details.

## 👋 Acknowledgements

This plugin wouldn't exist without [Pocco81](https://github.com/Pocco81)'s work on the [original](https://github.com/Pocco81/auto-save.nvim).
