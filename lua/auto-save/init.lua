local M = {}

local cnf = require("auto-save.config")
local colors = require("auto-save.utils.colors")
local echo = require("auto-save.utils.echo")
local autocmds = require("auto-save.utils.autocommands")
local logger
local autosave_running
local api = vim.api
local fn = vim.fn
local cmd = vim.cmd
local o = vim.o
local AUTO_SAVE_COLOR = "MsgArea"
local BLACK = "#000000"
local WHITE = "#ffffff"

autocmds.create_augroup({ clear = true })

local timers_by_buffer = {}

local function cancel_timer(buf)
  local timer = timers_by_buffer[buf]
  if timer ~= nil then
    timer:close()
    timers_by_buffer[buf] = nil

    logger.log(buf, "Timer canceled")
  end
end

local function debounce(lfn, duration)
  local function inner_debounce(buf)
    -- instead of canceling the timer we could check if there is one already running for this buffer and restart it (`:again`)
    cancel_timer(buf)
    local timer = vim.defer_fn(function()
      lfn(buf)
      timers_by_buffer[buf] = nil
    end, duration)
    timers_by_buffer[buf] = timer

    logger.log(buf, "Timer started")
  end
  return inner_debounce
end

local function echo_execution_message()
  local msg = type(cnf.opts.execution_message.message) == "function" and cnf.opts.execution_message.message()
    or cnf.opts.execution_message.message
  api.nvim_echo({ { msg, AUTO_SAVE_COLOR } }, true, {})
  if cnf.opts.execution_message.cleaning_interval > 0 then
    fn.timer_start(cnf.opts.execution_message.cleaning_interval, function()
      cmd([[echon '']])
    end)
  end
end

--- Determines if the given buffer is modifiable and if the condition from the config yields true for it
--- @param buf number
--- @return boolean
local function should_be_saved(buf)
  if fn.getbufvar(buf, "&modifiable") ~= 1 then
    return false
  end

  if cnf.opts.condition ~= nil then
    return cnf.opts.condition(buf)
  end

  logger.log(buf, "Should save buffer")

  return true
end

local function save(buf)
  if not api.nvim_buf_get_option(buf, "modified") then
    logger.log(buf, "Abort saving buffer")

    return
  end

  autocmds.exec_autocmd("AutoSaveWritePre", buf)

  if cnf.opts.write_all_buffers then
    cmd("silent! wall")
  else
    api.nvim_buf_call(buf, function()
      cmd("silent! write")
    end)
  end

  autocmds.exec_autocmd("AutoSaveWritePost", buf)
  logger.log(buf, "Saved buffer")

  if cnf.opts.execution_message.enabled == true then
    echo_execution_message()
  end
end

local function immediate_save(buf)
  cancel_timer(buf)
  save(buf)
end

local save_func = nil
local function defer_save(buf)
  -- is it really needed to cache this function
  -- TODO: remove?
  if save_func == nil then
    save_func = (cnf.opts.debounce_delay > 0 and debounce(save, cnf.opts.debounce_delay) or save)
  end
  save_func(buf)
end

function M.on()
  local augroup = autocmds.create_augroup({ clear = true })

  api.nvim_create_autocmd(cnf.opts.trigger_events.immediate_save, {
    callback = function(opts)
      if should_be_saved(opts.buf) then
        immediate_save(opts.buf)
      end
    end,
    group = augroup,
    desc = "Immediately save a buffer",
  })
  api.nvim_create_autocmd(cnf.opts.trigger_events.defer_save, {
    callback = function(opts)
      if should_be_saved(opts.buf) then
        defer_save(opts.buf)
      end
    end,
    group = augroup,
    desc = "Save a buffer after the `debounce_delay`",
  })
  api.nvim_create_autocmd(cnf.opts.trigger_events.cancel_defered_save, {
    callback = function(opts)
      if should_be_saved(opts.buf) then
        cancel_timer(opts.buf)
      end
    end,
    group = augroup,
    desc = "Cancel a pending save timer for a buffer",
  })

  api.nvim_create_autocmd({ "VimEnter", "ColorScheme", "UIEnter" }, {
    callback = function()
      vim.schedule(function()
        if cnf.opts.execution_message.dim > 0 then
          MSG_AREA = colors.get_hl("MsgArea")
          if MSG_AREA.foreground ~= nil then
            MSG_AREA.background = (MSG_AREA.background or colors.get_hl("Normal")["background"])
            local foreground = (
              o.background == "dark"
                and colors.darken(
                  (MSG_AREA.background or BLACK),
                  cnf.opts.execution_message.dim,
                  MSG_AREA.foreground or BLACK
                )
              or colors.lighten(
                (MSG_AREA.background or WHITE),
                cnf.opts.execution_message.dim,
                MSG_AREA.foreground or WHITE
              )
            )

            colors.highlight("AutoSaveText", { fg = foreground })
            AUTO_SAVE_COLOR = "AutoSaveText"
          end
        end
      end)
    end,
    group = augroup,
  })

  autosave_running = true
end

function M.off()
  autocmds.create_augroup({ clear = true })

  autosave_running = false
end

function M.toggle()
  if autosave_running then
    M.off()
    echo("off")
  else
    M.on()
    echo("on")
  end
end

function M.setup(custom_opts)
  cnf:set_options(custom_opts)
  logger = require("auto-save.utils.logging").new(cnf:get_options())
end

return M
