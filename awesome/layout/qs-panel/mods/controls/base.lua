local wbutton = require("utils.button")
local dpi = Beautiful.xresources.apply_dpi
local templates = {}

function templates.default(opts)
  opts.state_label_on = opts.state_label_on or "Encendido"
  opts.state_label_off = opts.state_label_off or "Apagado"
  local base_settings = opts.settings
      and wbutton.text.state({
        text = "󰅂",
        font = Beautiful.font_icon,
        -- fg_press_on = Beautiful.foreground_alt,
        fg_normal = Beautiful.quicksettings_ctrl_btn_fg,
        fg_normal_on = Beautiful.quicksettings_ctrl_btn_fg_on,
        bg_normal = Beautiful.quicksettings_ctrl_btn_bg,
        bg_normal_on = Beautiful.quicksettings_ctrl_btn_bg_on,
        size = 14,
        on_release = function()
          opts.settings()
        end,
      })
      or nil

  local base_label = Wibox.widget({
    widget = Wibox.container.background,
    fg = Beautiful.quicksettings_ctrl_btn_fg .. "CF",
    {
      layout = Wibox.layout.fixed.horizontal,
      spacing = dpi(8),
      {
        widget = Wibox.widget.textbox,
        id = "icon",
        text = opts.icon,
        font = Beautiful.font_icon .. "14",
        halign = "center",
        valign = "center",
      },
      {
        widget = Wibox.widget.textbox,
        id = "label",
        text = opts.name,
        ellipsize = "none",
        wrap = "word",
        font = Beautiful.font_text .. "Medium 11",
        halign = "center",
        valign = "center",
      },
    },
  })

  local function turn_on_btn()
    base_label.fg = Beautiful.quicksettings_ctrl_btn_fg_on
    if base_settings then
      base_settings:turn_on()
    end
  end
  local function turn_off_btn()
    base_label.fg = Beautiful.quicksettings_ctrl_btn_fg .. "CF"
    if base_settings then
      base_settings:turn_off()
    end
  end
  local base_button = wbutton.elevated.state({
    child = base_label,
    fg_normal_on = Beautiful.quicksettings_ctrl_btn_fg_on,
    bg_normal = opts.bg or Beautiful.quicksettings_ctrl_btn_bg,
    bg_normal_on = Beautiful.quicksettings_ctrl_btn_bg_on,
    halign = opts.halign or "left",
    paddings = {
      left = dpi(10),
      right = dpi(8),
      top = dpi(8),
      bottom = dpi(8),
    },
    on_turn_on = function(...)
      turn_on_btn()
      if opts.on_fn then
        opts.on_fn(...)
      end
    end,
    on_turn_off = function(...)
      turn_off_btn()
      if opts.off_fn then
        opts.off_fn(...)
      end
    end,
    on_release = opts.on_release and function()
      opts.on_release()
    end,
  })

  local base_layout = Wibox.widget({
    widget = Wibox.container.background,
    shape = Beautiful.quicksettings_ctrl_btn_shape,
    {
      layout = Wibox.layout.align.horizontal,
      forced_height = dpi(42),
      nil,
      base_button,
      base_settings,
    },
  })
  function base_layout:turn_on()
    base_button:turn_on()
    turn_on_btn()
  end

  function base_layout:turn_off()
    base_button:turn_off()
    turn_off_btn()
  end

  function base_layout:set_text(text)
    Helpers.gc(base_label, "label").text = text
  end

  function base_layout:set_icon(icon)
    Helpers.gc(base_label, "icon"):set_text(icon)
  end

  function base_layout:get_state()
    return base_button._private.state
  end

  if opts.on_by_default then
    base_layout:turn_on()
  end

  return base_layout
end

function templates.simple(opts)
  local base_button = wbutton.text.state({
    text = opts.icon,
    font = Beautiful.font_icon,
    size = 15,
    shape = Beautiful.quicksettings_ctrl_btn_shape,
    -- shape = Gears.shape.circle,
    fg_normal_on = Beautiful.quicksettings_ctrl_btn_fg_on,
    fg_normal = Beautiful.quicksettings_ctrl_btn_fg .. "CF",
    bg_normal = Beautiful.quicksettings_ctrl_btn_bg,
    -- bg_normal = Helpers.color.lightness(
      -- Beautiful.color_method,
      -- Beautiful.color_method_factor,
      -- Beautiful.quicksettings_ctrl_btn_bg
    -- ),
    bg_normal_on = Beautiful.quicksettings_ctrl_btn_bg_on,
    halign = "center",
    paddings = dpi(17),
    on_turn_on = function(self)
      if opts.on_fn then
        opts.on_fn(self)
      end
    end,
    on_turn_off = function(self)
      if opts.off_fn then
        opts.off_fn(self)
      end
    end,
    on_release = opts.on_release and function(self)
      opts.on_release(self)
    end,
  })

  if opts.on_by_default then
    base_button:turn_on()
  end
  return base_button
end

return function(opts)
  if opts.type == "simple" then
    return templates.simple(opts)
  else
    return templates.default(opts)
  end
end
