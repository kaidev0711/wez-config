local wezterm = require("wezterm")

-- Inspired by https://github.com/wez/wezterm/discussions/628#discussioncomment-1874614

local GLYPH_SEMI_CIRCLE_LEFT = ""
-- local GLYPH_SEMI_CIRCLE_LEFT = utf8.char(0xe0b6)
local GLYPH_SEMI_CIRCLE_RIGHT = ""
-- local GLYPH_SEMI_CIRCLE_RIGHT = utf8.char(0xe0b4)
local GLYPH_CIRCLE = ""
-- local GLYPH_CIRCLE = utf8.char(0xf111)
local GLYPH_ADMIN = ""
--local GLYPH_ADMIN = "ﱾ"
-- local GLYPH_ADMIN = utf8.char(0xfc7e)

local M = {}

M.cells = {}

M.colors = {
   default = {
      fg = "#24283b",
      bg = "#c0caf5",
   },
   is_active = {
      fg = "#24283b",
      bg = "#9ece6a",
   },
   hover = {
      fg = "#24283b",
      bg = "#c0caf5",
   },
}

M.set_process_name = function(s)
   local a = string.gsub(s, "(.*[/\\])(.*)", "%2")
   return a
end

M.set_title = function(process_name, base_title, max_width, inset)
   local title
   inset = inset or 6

   if process_name:len() > 0 then
      title = process_name .. " ~ " .. base_title
   else
      title = base_title
   end

   if title:len() > max_width - inset then
      local diff = title:len() - max_width + inset
      title = wezterm.truncate_right(title, title:len() - diff)
   end

   return title
end

M.check_if_admin = function(p)
   return true
end

---@param fg string
---@param bg string
---@param attribute table
---@param text string
M.push = function(bg, fg, attribute, text)
   table.insert(M.cells, { Background = { Color = bg } })
   table.insert(M.cells, { Foreground = { Color = fg } })
   table.insert(M.cells, { Attribute = attribute })
   table.insert(M.cells, { Text = text })
end

M.setup = function()
   wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
      M.cells = {}
      local bg
      local fg
      local process_name = M.set_process_name(tab.active_pane.foreground_process_name)
      local is_admin = M.check_if_admin(tab.active_pane.title)
      local title = M.set_title(process_name, tab.active_pane.title, max_width, (is_admin and 8))

      if tab.is_active then
         bg = M.colors.is_active.bg
         fg = M.colors.is_active.fg
      elseif hover then
         bg = M.colors.hover.bg
         fg = M.colors.hover.fg
      else
         bg = M.colors.default.bg
         fg = M.colors.default.fg
      end

      local has_unseen_output = false
      for _, pane in ipairs(tab.panes) do
         if pane.has_unseen_output then
            has_unseen_output = true
            break
         end
      end

      -- Left semi-circle
      M.push(fg, bg, { Intensity = "Bold" }, GLYPH_SEMI_CIRCLE_LEFT)

      -- Admin Icon
      if is_admin then
         M.push(bg, fg, { Intensity = "Bold" }, " " .. GLYPH_ADMIN)
      end

      -- Title
      M.push(bg, fg, { Intensity = "Bold" }, " " .. title)

      -- Unseen output alert
      if has_unseen_output then
         M.push(bg, "#f7768e", { Intensity = "Bold" }, " " .. GLYPH_CIRCLE .. " ")
      end

      -- Right semi-circle
      M.push(fg, bg, { Intensity = "Bold" }, GLYPH_SEMI_CIRCLE_RIGHT)

      return wezterm.format(M.cells)
   end)
end

return M
