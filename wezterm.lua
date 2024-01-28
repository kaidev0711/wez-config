-- Pull in the wezterm API
local wezterm = require 'wezterm'
local mux = wezterm.mux
local act = wezterm.action

local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

wezterm.on('gui-startup', function()
 local tab, pane, window = mux.spawn_window({})
 window:gui_window():maximize()
end)

config.hyperlink_rules = wezterm.default_hyperlink_rules()

config.default_prog = { '/bin/zsh',"-l" }
config.font = wezterm.font { 
  family = 'Hack Nerd Font',  
  scale = 1.24,
  weight = "Medium"
}
config.front_end = "WebGpu"

config.color_scheme = 'Catppuccin Mocha'
config.font_size = 16.0
config.scrollback_lines = 3000
config.default_workspace = "main"
config.default_cursor_style = "SteadyUnderline"
config.use_fancy_tab_bar = false
config.window_padding = {
    left = 3, right = 3,
    top = 3, bottom = 3,
}
config.inactive_pane_hsb = {
  saturation = 0.9,
  brightness = 0.8,
}
config.status_update_interval = 1000
config.adjust_window_size_when_changing_font_size = true
config.audible_bell = "Disabled"
config.tab_max_width = 25
config.tab_bar_at_bottom = true
config.hide_tab_bar_if_only_one_tab = true
config.hide_mouse_cursor_when_typing = true
config.enable_tab_bar = true
config.exit_behavior = "Close"
config.window_close_confirmation = 'NeverPrompt'
config.show_new_tab_button_in_tab_bar = false
config.show_tab_index_in_tab_bar = false
config.window_decorations = "RESIZE"
config.check_for_updates = true
config.check_for_updates_interval_seconds = 86400

-- config.window_background_opacity = 0.8


-- keyamps
-- config.disable_default_key_bindings = true
-- wezterm.on('update-right-status', function(window, pane)
--   local name = window:active_key_table()
--   if name then
--     name = 'TABLE: ' .. name
--   end
--   window:set_right_status(name or '')
-- end)

local monitor = act.SwitchToWorkspace({
		name = "monitor",
		spwn = {
			args = { "btop" },
		},
})


config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
  { key = "-", mods = "LEADER",       action = act.SplitVertical { domain = "CurrentPaneDomain" } },
  { key = "|", mods = "LEADER|SHIFT", action = act.SplitHorizontal { domain = "CurrentPaneDomain" } },
  { key = "h", mods = "LEADER",       action = act.ActivatePaneDirection("Left") },
  { key = "j", mods = "LEADER",       action = act.ActivatePaneDirection("Down") },
  { key = "k", mods = "LEADER",       action = act.ActivatePaneDirection("Up") },
  { key = "l", mods = "LEADER",       action = act.ActivatePaneDirection("Right") },
  { key = "x", mods = "LEADER",       action = act.CloseCurrentPane { confirm = true } },
  { key = "n", mods = "LEADER",       action = act.SpawnTab("CurrentPaneDomain") },
  { key = 'r', mods = 'LEADER',       action = act.ActivateKeyTable { name = 'resize_pane',one_shot = false,} },
  { key = "m", mods = "LEADER",       action = act.ActivateKeyTable { name = "move_tab", one_shot = false } },
  { key = "w", mods = "LEADER",       action = act.ShowLauncherArgs { flags = "FUZZY|WORKSPACES" } },



}

for i = 1, 9 do
  table.insert(config.keys, {
    key = tostring(i),
    mods = "LEADER",
    action = act.ActivateTab(i - 1)
  })
end

config.key_tables = {
  resize_pane = {
    { key = "h",      action = act.AdjustPaneSize { "Left", 1 } },
    { key = "j",      action = act.AdjustPaneSize { "Down", 1 } },
    { key = "k",      action = act.AdjustPaneSize { "Up", 1 } },
    { key = "l",      action = act.AdjustPaneSize { "Right", 1 } },
    { key = "Escape", action = "PopKeyTable" },
    { key = "Enter",  action = "PopKeyTable" },
  },
  move_tab = {
    { key = "h",      action = act.MoveTabRelative(-1) },
    { key = "j",      action = act.MoveTabRelative(-1) },
    { key = "k",      action = act.MoveTabRelative(1) },
    { key = "l",      action = act.MoveTabRelative(1) },
    { key = "Escape", action = "PopKeyTable" },
    { key = "Enter",  action = "PopKeyTable" },
  }
}


wezterm.on("update-right-status", function(window, pane)
  -- Workspace name
  local stat = window:active_workspace()
  -- It's a little silly to have workspace name all the time
  -- Utilize this to display LDR or current key table name
  if window:active_key_table() then stat = window:active_key_table() end
  if window:leader_is_active() then stat = "LDR" end

  -- Current working directory
  local basename = function(s)
    -- Nothign a little regex can't fix
    return string.gsub(s, "(.*[/\\])(.*)", "%2")
  end
  local cwd = basename(pane:get_current_working_dir())
  -- Current command
  local cmd = basename(pane:get_foreground_process_name())

  -- Time
  local time = wezterm.strftime("%H:%M")

  -- Let's add color to one of the components
  window:set_right_status(wezterm.format({
    -- Wezterm has a built-in nerd fonts
    { Text = wezterm.nerdfonts.oct_table .. "  " .. stat },
    { Text = " | " },
    { Text = wezterm.nerdfonts.md_folder .. "  " .. cwd },
    { Text = " | " },
    { Foreground = { Color = "FFB86C" } },
    { Text = wezterm.nerdfonts.fa_code .. "  " .. cmd },
    "ResetAttributes",
    { Text = " | " },
    { Text = wezterm.nerdfonts.md_clock .. "  " .. time },
    { Text = " |" },
  }))
end)

table.insert(config.hyperlink_rules, {
  regex = '^/[^/\r\n]+(?:/[^/\r\n]+)*:\\d+:\\d+',
  format = '$EDITOR:$0',
})

table.insert(config.hyperlink_rules, {
  regex = '[^\\s]+\\.rs:\\d+:\\d+',
  format = '$EDITOR:$0',
})


require("tab_title").setup()


-- and finally, return the configuration to wezterm
return config
