<p align="center">
  <h2 align="center">🧶 auto-save.nvim</h2>
</p>

<p align="center">
  Automatically save your changes in NeoVim
</p>

<p align="center">
  <a href="https://github.com/okuuva/auto-save.nvim/stargazers">
    <img alt="Stars" src="https://img.shields.io/github/stars/okuuva/auto-save.nvim?style=for-the-badge&logo=starship&color=C9CBFF&logoColor=D9E0EE&labelColor=302D41"></a>
  <a href="https://github.com/okuuva/auto-save.nvim/issues">
    <img alt="Issues" src="https://img.shields.io/github/issues/okuuva/auto-save.nvim?style=for-the-badge&logo=bilibili&color=F5E0DC&logoColor=D9E0EE&labelColor=302D41"></a>
  <a href="https://github.com/okuuva/auto-save.nvim">
    <img alt="Repo Size" src="https://img.shields.io/github/repo-size/okuuva/auto-save.nvim?color=%23DDB6F2&label=SIZE&logo=codesandbox&style=for-the-badge&logoColor=D9E0EE&labelColor=302D41"/></a>
</p>

### 📋 Features

- automatically save your changes so the world doesn't collapse
- highly customizable:
  - conditionals to assert whether to save or not
  - execution message (it can be dimmed and personalized)
  - events that trigger auto-save
- debounce the save with a delay
- multiple callbacks
- automatically clean the message area

### 📚 Requirements

- Neovim >= 0.5.0

### 📦 Installation

Install the plugin with your favourite package manager:

<details>
  <summary><a href="https://github.com/folke/lazy.nvim">Lazy.nvim</a></summary>

```lua
{
  "okuuva/auto-save.nvim",
  cmd = "ASToggle", -- optional for lazy loading on command
  event = { "InsertLeave", "TextChanged" } -- optional for lazy loading on trigger events
  opts = {
    -- your config goes here
    -- or just leave it empty :)
  },
},
```

</details>

<details>
  <summary><a href="https://github.com/wbthomason/packer.nvim">Packer.nvim</a></summary>

```lua
use({
  "okuuva/auto-save.nvim",
  config = function()
   require("auto-save").setup {
     -- your config goes here
     -- or just leave it empty :)
   }
  end,
})
```

</details>

<details>
  <summary><a href="https://github.com/junegunn/vim-plug">vim-plug</a></summary>

```vim
Plug 'okuuva/auto-save.nvim'
lua << EOF
  require("auto-save").setup {
    -- your config goes here
    -- or just leave it empty :)
  }
EOF
```

</details>

### ⚙️ Configuration

**auto-save** comes with the following defaults:

```lua
{
  enabled = true, -- start auto-save when the plugin is loaded (i.e. when your package manager loads it)
  execution_message = {
    enabled = true,
    message = function() -- message to print on save
      return ("AutoSave: saved at " .. vim.fn.strftime("%H:%M:%S"))
    end,
    dim = 0.18, -- dim the color of `message`
    cleaning_interval = 1250, -- (milliseconds) automatically clean MsgArea after displaying `message`. See :h MsgArea
  },
  trigger_events = { -- See :h events
    immediate_save = { "BufLeave", "FocusLost" }, -- vim events that trigger an immediate save
    defer_save = { "InsertLeave", "TextChanged" }, -- vim events that trigger a deferred save (saves after `debounce_delay`)
    cancel_defered_save = { "InsertEnter" }, -- vim events that cancel a pending deferred save
  },
  -- function that takes the buffer handle and determines whether to save the current buffer or not
  -- return true: if buffer is ok to be saved
  -- return false: if it's not ok to be saved
  -- if set to `nil` then no specific condition is applied
  condition = nil,
  write_all_buffers = false, -- write all buffers when the current one meets `condition`
  debounce_delay = 1000, -- delay after which a pending save is executed
  callbacks = { -- functions to be executed at different intervals
    enabling = nil, -- ran when enabling auto-save
    disabling = nil, -- ran when disabling auto-save
    before_saving = nil, -- ran before doing the actual save
    after_saving = nil -- ran after doing the actual save
  }
}
```

#### Condition
The condition field of the configuration allows the user to exclude **auto-save** from saving specific buffers.
There is a helper functions provided for not saving specified file types:

```lua
{
  condition = function(buf)
    local fn = vim.fn
    local utils = require("auto-save.utils.data")

    -- don't save for `sql` file types
    if utils.not_in(fn.getbufvar(buf, "&filetype"), {'sql'}) then
      return true
    end
    return false
  end
}
```

Buffers that are `nomodifiable` are not saved by default.

### 🪴 Usage

Besides running auto-save at startup (if you have `enabled = true` in your config), you may as well:

- `ASToggle`: toggle auto-save

You may want to set up a key mapping for toggling:

```lua
vim.api.nvim_set_keymap("n", "<leader>n", ":ASToggle<CR>", {})
```

or as part of the `lazy.nvim` plugin spec:

```lua
{
  "okuuva/auto-save.nvim",
  keys = {
    { "<leader>n", ":ASToggle<CR>", desc = "Toggle auto-save" },
  },
  ...
},

```


### 🤝 Contributing

- All pull requests are welcome.
- If you encounter bugs please open an issue.
- Please use [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) when commiting.
  - See [@commitlint/config-conventional](https://github.com/conventional-changelog/commitlint/tree/master/@commitlint/config-conventional) for more details.

### 👋 Acknowledgements

This plugin wouldn't exist without [Pocco81](https://github.com/Pocco81)'s work on the [original](https://github.com/Pocco81/auto-save.nvim).
