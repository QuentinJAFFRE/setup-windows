-- WezTerm config — fancy edition
-- Source of truth: dotfiles/wezterm/.wezterm.lua  (deployed to ~/.wezterm.lua)

local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()

-- ---------------------------------------------------------------------------
-- Shell: PowerShell, not cmd.exe
-- ---------------------------------------------------------------------------
-- Prefer PowerShell 7 (pwsh) if installed, else fall back to Windows PowerShell 5.
local function default_prog()
  local pwsh = 'C:\\Program Files\\PowerShell\\7\\pwsh.exe'
  local f = io.open(pwsh, 'r')
  if f then f:close(); return { pwsh, '-NoLogo' } end
  return { 'powershell.exe', '-NoLogo' }
end
config.default_prog = default_prog()

-- Launch menu: quick-pick shells from the new-tab dropdown
config.launch_menu = {
  { label = 'PowerShell 7',          args = { 'pwsh.exe', '-NoLogo' } },
  { label = 'Windows PowerShell 5',  args = { 'powershell.exe', '-NoLogo' } },
  { label = 'Command Prompt',        args = { 'cmd.exe' } },
  { label = 'WSL (Ubuntu)',          args = { 'wsl.exe', '-d', 'Ubuntu' } },
}

-- ---------------------------------------------------------------------------
-- Appearance
-- ---------------------------------------------------------------------------
config.color_scheme = 'Tokyo Night'
config.font = wezterm.font_with_fallback {
  { family = 'JetBrainsMono Nerd Font', weight = 'Medium' },
  'JetBrains Mono',
  'Cascadia Code',
  'Segoe UI Emoji',
}
config.font_size = 11.5
config.line_height = 1.05
config.cell_width = 1.0
config.harfbuzz_features = { 'calt=1', 'liga=1', 'clig=1' } -- ligatures on

-- Window chrome
config.window_decorations = 'RESIZE'                -- no native title bar; keep resize border
config.window_background_opacity = 0.92
config.win32_system_backdrop = 'Acrylic'            -- mica-like blur on Win11
config.window_padding = { left = 12, right = 12, top = 8, bottom = 6 }
config.window_close_confirmation = 'NeverPrompt'
config.adjust_window_size_when_changing_font_size = false
config.initial_cols = 140
config.initial_rows = 38

-- Cursor
config.default_cursor_style = 'BlinkingBar'
config.cursor_blink_rate = 600
config.cursor_thickness = '2px'

-- Scrollback + UX
config.scrollback_lines = 50000
config.enable_scroll_bar = false
config.audible_bell = 'Disabled'
config.warn_about_missing_glyphs = false

-- Tab bar
config.use_fancy_tab_bar = true
config.tab_bar_at_bottom = false
config.hide_tab_bar_if_only_one_tab = true
config.show_new_tab_button_in_tab_bar = true
config.tab_max_width = 28

-- Custom tab title: index + program + cwd basename
wezterm.on('format-tab-title', function(tab, _, _, _, hover, max_width)
  local pane = tab.active_pane
  local title = pane.title or ''
  -- shorten cwd to last segment
  local cwd = ''
  if pane.current_working_dir then
    local p = pane.current_working_dir.file_path or tostring(pane.current_working_dir)
    cwd = p:gsub('[/\\]+$', ''):match('([^/\\]+)$') or ''
  end
  local label = string.format(' %d  %s ', tab.tab_index + 1, cwd ~= '' and cwd or title)
  if #label > max_width then label = label:sub(1, max_width - 1) .. '…' end
  local bg = hover and '#3b4261' or (tab.is_active and '#7aa2f7' or '#1a1b26')
  local fg = (tab.is_active and not hover) and '#1a1b26' or '#c0caf5'
  return { { Background = { Color = bg } }, { Foreground = { Color = fg } }, { Text = label } }
end)

-- Right status: workspace · time
wezterm.on('update-right-status', function(window, _)
  local ws = window:active_workspace()
  local date = wezterm.strftime('%a %H:%M')
  window:set_right_status(wezterm.format {
    { Foreground = { Color = '#7aa2f7' } }, { Text = ' ' .. ws .. '  ' },
    { Foreground = { Color = '#bb9af7' } }, { Text = ' ' .. date .. ' ' },
  })
end)

-- ---------------------------------------------------------------------------
-- Keys (match docs/cheatsheets/wezterm.md)
-- ---------------------------------------------------------------------------
config.disable_default_key_bindings = false
config.leader = nil  -- no leader; direct chords
config.keys = {
  -- Panes (per cheatsheet)
  { key = '"', mods = 'CTRL|SHIFT|ALT', action = act.SplitVertical   { domain = 'CurrentPaneDomain' } },
  { key = '%', mods = 'CTRL|SHIFT|ALT', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'LeftArrow',  mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection 'Left'  },
  { key = 'RightArrow', mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection 'Right' },
  { key = 'UpArrow',    mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection 'Up'    },
  { key = 'DownArrow',  mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection 'Down'  },
  { key = 'z', mods = 'CTRL|SHIFT', action = act.TogglePaneZoomState },
  { key = 'w', mods = 'CTRL|SHIFT', action = act.CloseCurrentPane { confirm = false } },

  -- Tabs
  { key = 't', mods = 'CTRL|SHIFT', action = act.SpawnTab 'CurrentPaneDomain' },
  { key = 'Tab',     mods = 'CTRL',        action = act.ActivateTabRelative(1)  },
  { key = 'Tab',     mods = 'CTRL|SHIFT',  action = act.ActivateTabRelative(-1) },

  -- Workspaces (project contexts)
  { key = 'w', mods = 'CTRL|SHIFT|ALT', action = act.ShowLauncherArgs { flags = 'FUZZY|WORKSPACES' } },
  { key = 'n', mods = 'CTRL|SHIFT|ALT', action = act.PromptInputLine {
      description = 'New workspace name:',
      action = wezterm.action_callback(function(window, pane, line)
        if line and line ~= '' then
          window:perform_action(act.SwitchToWorkspace { name = line }, pane)
        end
      end),
  } },

  -- Discovery / power tools
  { key = 'Space', mods = 'CTRL|SHIFT', action = act.ActivateCommandPalette },
  { key = 'x',     mods = 'CTRL|SHIFT', action = act.ActivateCopyMode },
  { key = 'f',     mods = 'CTRL|SHIFT', action = act.Search { CaseInSensitiveString = '' } },
  { key = 'p',     mods = 'CTRL|SHIFT', action = act.QuickSelect },
  { key = 'l',     mods = 'CTRL|SHIFT', action = act.ShowLauncher },

  -- Font size
  { key = '=', mods = 'CTRL', action = act.IncreaseFontSize },
  { key = '-', mods = 'CTRL', action = act.DecreaseFontSize },
  { key = '0', mods = 'CTRL', action = act.ResetFontSize },

  -- Clipboard (Windows-friendly)
  { key = 'c', mods = 'CTRL|SHIFT', action = act.CopyTo  'Clipboard' },
  { key = 'v', mods = 'CTRL|SHIFT', action = act.PasteFrom 'Clipboard' },

  -- Reload config without restart
  { key = 'r', mods = 'CTRL|SHIFT', action = act.ReloadConfiguration },
}

-- Mouse: paste on right-click, open links on ctrl-click
config.mouse_bindings = {
  { event = { Down = { streak = 1, button = 'Right' } }, mods = 'NONE',
    action = act.PasteFrom 'Clipboard' },
  { event = { Up = { streak = 1, button = 'Left' } }, mods = 'CTRL',
    action = act.OpenLinkAtMouseCursor },
}

-- Hyperlink rules: defaults + bare URLs without protocol
config.hyperlink_rules = wezterm.default_hyperlink_rules()
table.insert(config.hyperlink_rules, {
  regex = [[\b[\w.-]+\.(com|org|net|io|dev|ai|sh|gg)\S*\b]],
  format = 'https://$0',
})

return config
