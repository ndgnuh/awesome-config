local awful = require"awful"
local gears = require"gears"
local wm = require"helper.wm"

local module, awesome, client = {}, awesome, client

local modkey = "Mod4"
local mod = {modkey}
local modshift = {modkey, "Shift"}
local modctrl = {modkey, "Control"}

globalkeys = gears.table.join(
  awful.key(mod, "j", function() ts:trigger() ts:emit_signal("forward") end),
  awful.key(mod, "k", function() ts:trigger() ts:emit_signal("backward") end),
  awful.key(mod, "s", hotkeys_popup.show_help,
    {description = "show help", group = "awesome"}),
  awful.key(mod, "Left", awful.tag.viewprev,
    {description = "view previous", group = "tag"}),
  awful.key(mod, "Right", awful.tag.viewnext,
    {description = "view next", group = "tag"}),
  awful.key(mod, "Escape", awful.tag.history.restore,
    {description = "go back", group = "tag"}),
  awful.key(mod, "w", function () mymainmenu:show() end,
    {description = "show main menu", group = "awesome"}),

  -- Layout manipulation
  awful.key(modshift, "j", function () awful.client.swap.byidx( 1) end,
    {description = "swap with next client by index", group = "client"}),
  awful.key(modshift, "k", function () awful.client.swap.byidx( -1) end,
    {description = "swap with previous client by index", group = "client"}),
  awful.key(modctrl, "j", function () awful.screen.focus_relative( 1) end,
    {description = "focus the next screen", group = "screen"}),
  awful.key(modctrl, "k", function () awful.screen.focus_relative(-1) end,
    {description = "focus the previous screen", group = "screen"}),
  awful.key(mod, "u", awful.client.urgent.jumpto,
    {description = "jump to urgent client", group = "client"}),
  -- awful.key(mod, "Tab",
  -- function ()
  -- awful.client.focus.history.previous()
  -- if client.focus then
  -- client.focus:raise()
  -- end
  -- end,
  -- {description = "go back", group = "client"}),

  -- Standard program
  awful.key(modctrl, "r", awesome.restart,
    {description = "reload awesome", group = "awesome"}),
  awful.key(modshift, "e", awesome.quit,
    {description = "quit awesome", group = "awesome"}),

  awful.key(mod, "l", function () awful.tag.incmwfact( 0.05) end,
    {description = "increase master width factor", group = "layout"}),
  awful.key(mod, "h", function () awful.tag.incmwfact(-0.05) end,
    {description = "decrease master width factor", group = "layout"}),
  awful.key(modshift, "h", function () awful.tag.incnmaster( 1, nil, true) end,
    {description = "increase the number of master clients", group = "layout"}),
  awful.key(modshift, "l", function () awful.tag.incnmaster(-1, nil, true) end,
    {description = "decrease the number of master clients", group = "layout"}),
  awful.key(modctrl, "h", function () awful.tag.incncol( 1, nil, true) end,
    {description = "increase the number of columns", group = "layout"}),
  awful.key(modctrl, "l", function () awful.tag.incncol(-1, nil, true) end,
    {description = "decrease the number of columns", group = "layout"}),
  -- awful.key(mod, "space", function () awful.layout.inc( 1) end,
  -- {description = "select next", group = "layout"}),
  awful.key(modshift, "space", function () awful.layout.inc(-1) end,
    {description = "select previous", group = "layout"}),

  awful.key(modshift, "n",
    function ()
      local c = awful.client.restore()
      -- Focus restored client
      if c then
        c:emit_signal(
          "request::activate", "key.unminimize", {raise = true}
          )
      end
    end,
    {description = "restore minimized", group = "client"}),

  -- Prompt
  awful.key(mod, "r",
    function()
      awful.spawn(string.format('rofi -show run', os.getenv("HOME")))
    end,
    {description = "run prompt", group = "launcher"}),

  awful.key(mod, "x",
    function ()
      awful.prompt.run {
        prompt = "Run Lua code: ",
        textbox = awful.screen.focused().mypromptbox.widget,
        exe_callback = awful.util.eval,
        history_path = awful.util.get_cache_dir() .. "/history_eval"
      }
    end,
    {description = "lua execute prompt", group = "awesome"}),
  -- Menubar
  awful.key(mod, "p", function() menubar.show() end,
    {description = "show the menubar", group = "launcher"})
  )
