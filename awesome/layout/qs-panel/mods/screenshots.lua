local screenshot_lib = require("utils.modules.screenshot")
local wbutton = require("utils.button")
local dpi = Beautiful.xresources.apply_dpi
local delay_count = 0
local hide_cursor = false
local new_bg =
    Helpers.color.lightness(Beautiful.color_method, Beautiful.color_method_factor, Beautiful.quicksettings_ctrl_btn_bg)

local function button(icon, fn, size)
  return wbutton.text.normal({
    text = icon,
    font = Beautiful.font_icon,
    size = size or 14,
    bg_normal = new_bg,
    shape = Beautiful.quicksettings_ctrl_btn_shape,
    paddings = dpi(10),
    on_release = fn,
  })
end
local function screenshot_notify(ss)
  local screenshot_open = Naughty.action({ name = "Abrir" })
  local screenshot_copy = Naughty.action({ name = "Copiar" })
  local screenshot_delete = Naughty.action({ name = "Eliminar" })
  ss:connect_signal("file::saved", function(self, file_name, file_path)
    screenshot_open:connect_signal("invoked", function()
      Awful.spawn.with_shell("feh " .. file_path .. file_name)
    end)
    screenshot_delete:connect_signal("invoked", function()
      Awful.spawn.with_shell("rm " .. file_path .. file_name)
    end)
    screenshot_copy:connect_signal("invoked", function()
      Awful.spawn.with_shell(
        "xclip -selection clipboard -t image/png " .. file_path .. file_name .. " &>/dev/null"
      )
    end)
    Naughty.notify({
      message = file_name,
      title = "Captura guardada.",
      image = file_path .. file_name,
      actions = { screenshot_copy, screenshot_open, screenshot_delete },
    })
  end)
end

local screenshot_normal = button("󰆟", function()
  local ss = screenshot_lib.normal({
    hide_cursor = hide_cursor,
    delay = delay_count,
  })
  awesome.emit_signal("panels::quicksettings", "hide")
  screenshot_notify(ss)
end)

local screenshot_selective = button("󰆞", function()
  local ss = screenshot_lib.select({
    hide_cursor = hide_cursor,
    delay = delay_count,
  })
  awesome.emit_signal("panels::quicksettings", "hide")
  screenshot_notify(ss)
end)

local delay_label = Wibox.widget({
  widget = Wibox.widget.textbox,
  text = delay_count,
  font = Beautiful.font_text .. "Regular 10",
  halign = "center",
  valign = "center",
})

local screenshot_options = wbutton.elevated.state({
  bg_normal = new_bg,
  bg_normal_on = new_bg,
  on_by_default = hide_cursor,
  shape = Beautiful.quicksettings_ctrl_btn_shape,
  paddings = {
    left = dpi(8),
    top = dpi(10),
    bottom = dpi(10),
  },
  halign = "left",
  child = {
    layout = Wibox.layout.fixed.horizontal,
    spacing = dpi(6),
    {
      widget = Wibox.widget.textbox,
      text = hide_cursor and "󰄴" or "󰏝",
      font = Beautiful.font_icon .. "13",
      id = "hide_cursor_icon",
      halign = "center",
      valign = "center",
    },
    {
      widget = Wibox.widget.textbox,
      markup = Helpers.text.colorize_text("Ocultar cursor", Beautiful.quicksettings_ctrl_btn_fg .. "CF"),
      font = Beautiful.font_text .. "Medium 11",
      halign = "left",
      valign = "center",
    },
  },
  on_turn_on = function(self)
    hide_cursor = true
    Helpers.gc(self, "hide_cursor_icon").text = "󰄴"
  end,
  on_turn_off = function(self)
    hide_cursor = false
    Helpers.gc(self, "hide_cursor_icon").text = "󰏝"
  end,
})

local screenshot_menu = Wibox.widget({
  widget = Wibox.container.background,
  bg = Beautiful.quicksettings_widgets_bg,
  shape = Beautiful.quicksettings_ctrl_btn_shape,
  {
    widget = Wibox.container.margin,
    margins = dpi(10),
    {
      layout = Wibox.layout.flex.horizontal,
      -- forced_num_rows = 2,
      -- vertical_homogeneous = false,
      -- horizontal_expand = true,
      -- vertical_expand = true,
      spacing = dpi(10),
      {
        layout = Wibox.layout.flex.vertical,
        spacing = dpi(10),
        screenshot_options,
        {
          widget = Wibox.container.background,
          shape = Beautiful.quicksettings_ctrl_btn_shape,
          bg = new_bg,
          {
            layout = Wibox.layout.flex.horizontal,
            button("󰅃", function()
              delay_count = delay_count + 1
              delay_label:set_text(delay_count)
            end, 15),
            delay_label,
            button("󰅀", function()
              if delay_count > 0 then
                delay_count = delay_count - 1
                delay_label:set_text(delay_count)
              end
            end, 15),
          },
        },
      },
      {
        layout = Wibox.layout.flex.horizontal,
        spacing = dpi(10),
        screenshot_normal,
        screenshot_selective,
      },
    },
  },
})

function screenshot_menu:reset()
  delay_count = 0
  delay_label:set_text(delay_count)
end

awesome.connect_signal("visible::quicksettings", function(vis)
  if vis == false then
    screenshot_menu:reset()
  end
end)

return screenshot_menu
