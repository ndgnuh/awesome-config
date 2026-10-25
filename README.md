# My SomeWM configuration

(The AI wrote the README, but i wrote the code myself)

This is the `somewm` branch of my window manager config. It targets
[SomeWM](https://github.com/somewm/somewm), a Wayland compositor that keeps
AwesomeWM's Lua API. It is **not** an AwesomeWM (X11) config. The `master`
branch holds the older AwesomeWM setup.

The config lives in `~/.config/somewm/`, and SomeWM loads `rc.lua` from there.
The API is AwesomeWM's (`gears`, `awful`, `wibox`, `naughty`, `ruled`), but
anything tied to X11 (xprop, xdotool, picom, xrandr, client-side xkb) is gone.
Input, idle and locking are handled by the compositor instead.

## Features

- **Wayland-native input**: touchpad and keyboard are configured through
  `awful.input` (`ndgnuh/input_config.lua`), not `setxkbmap` or `xinput`.
- **Built-in lockscreen**: SomeWM's `lockscreen` module, available from the
  menu (`awesome.lock`).
- **Spawn-or-cycle focus groups**: `Mod4+1` … `Mod4+9` either start an app or
  cycle through its open windows on any tag or screen. Each group remembers
  the last window you used in it (`lib/spawn_or_cycle.lua`).
- **Task switcher**: `Mod4+j` / `Mod4+k` open a popup that lists every managed
  client (`ndgnuh/task_switcher_somewm.lua`).
- **Manual focus group**: mark windows with `Mod4+Shift+m` and cycle through
  the marked ones with `Mod4+m` (`ndgnuh/manual_focus_group.lua`).
- **Volatile tags**: a window can be moved to a temporary tag that is
  destroyed when it empties. `Mod4+Shift+v` does this, and moving a window to
  another screen with `Mod4+o` does it too.
- **Custom run prompt** (`Mod4+r`): a paged launcher. Its history is saved
  with `lib/survival.lua`, and it needs the `ez` C module (see below).
- **IBus integration**: switch input method with `Mod4+e` (English),
  `Mod4+v` (Bamboo, for Vietnamese) or `Mod4+a` (Anthy, for Japanese). The
  wibar shows the active engine. It is read through `ibus engine` as a
  workaround for missing LGI signal data on NixOS.
- **Floating client menu** (`Mod4+c`): toggle on-top, sticky, floating and
  maximized from a checkbox menu.
- **Wallpapers**: the primary screen uses the theme wallpaper. Secondary
  screens use a wallpaper picked with zenity or kdialog and cached between
  sessions (`lib/secondary_wallpaper.lua`).
- **Misc**: a "do not disturb" toggle, screenshots saved to
  `~/Pictures/Screenshots/` (Print, Shift/Ctrl+Print for interactive), media
  and brightness keys, `Mod4+0` to hide or show the current tag, and Lua
  errors logged with tracebacks to `~/.cache/somewm-errors.log`.
- **Autostart** (run once, survives reloads): `ibus-daemon`, `nm-applet`,
  `blueman-applet`, `udiskie`.

To see the bindings that have descriptions, open the hotkeys popup from the
menu (right-click the desktop, then somewm, then hotkeys). In this config
`Mod4+s` switches focus to the next screen and no longer shows that popup. The full list is in
`ndgnuh/keybindings.lua`.

## Layout of the repository

| Path | Purpose |
| --- | --- |
| `rc.lua` | Entry point, based on SomeWM's default `somewmrc.lua`: error handling, theme, menu, layouts, wallpaper, wibar, client keys/buttons, titlebars, notifications |
| `state.lua` | Runtime state, such as `first_run`, which is false after a restart |
| `icons.lua` | Icon presets loaded from `assets/icons/` |
| `ndgnuh/` | My personal setup: theme, wibar, keybindings, rules, run prompt, task switcher, IBus widget, input config |
| `ndgnuh/widgets/` | Personal widgets, such as `BatteryIcon` |
| `lib/` | Reusable helpers that are not tied to my setup (see below) |
| `lib/widgets/` | Generic widgets: `InkWell` |
| `monkey_patch/` | Extensions patched directly into `table`, `awesome` and `awful.client` |
| `rules/` | Data tables used by the client rules, such as floating/sticky classes |
| `ez.c` | Small Lua C module (`ls`, `map`, `range`, `apply`, `ic`, `nameof`) |
| `assets/` | Icons and wallpaper, stored in Git LFS |
| `attic/` | Old and experimental code, drafts and previous `rc.lua` versions. Untracked and not loaded |

### Notable helper libraries in `lib/`

- `overdrip.lua`: a small reactive state/provider library inspired by
  Riverpod. `providers/clients.lua` uses it to publish client states (all,
  focused, tiling clients, focused name/icon) to widgets.
- `icecream.lua`: an `ic(...)` debug printer that shows variable names. It is
  also exposed as `gears.debug.ic`.
- `popup_registry.lua`: creates one popup per screen, cached in a weak table and cleared on screen removal.
- `notifier_widget.lua`: a `gears.object` with auto property signals, used as
  a widget model.
- `resource.lua`: resolves paths inside the config dir, recolors icons, and
  provides color helpers (`hsl`, `rgbf`).
- `survival.lua`: serializes Lua values to files in the cache dir.
- `client.lua`: client utilities (`normalize`, `move_to_volatile`,
  `global_focus_previous`, `inspect`, …).

## Installation

1. Build and install SomeWM, which provides `somewm` and `somewm-client`. Its
   Lua library goes to `/usr/local/share/somewm/lua/`.
2. Clone this branch into the config directory:
   ```bash
   git clone -b somewm <repo-url> ~/.config/somewm
   cd ~/.config/somewm
   git lfs pull        # icons, wallpaper and other binaries are in LFS
   ```
3. Build the `ez` C module. The run prompt refuses to load without it:
   ```bash
   make ez
   ```
   `ez.so` is ignored by git and loaded from the config dir, because `rc.lua`
   adds `?.so` to `package.cpath`.
4. Install the runtime dependencies used by the config: `sakura` (terminal),
   `ibus` with the Bamboo/Anthy engines, `nm-applet`, `blueman`, `udiskie`,
   and `zenity` or `kdialog` for the wallpaper picker.
5. Start a SomeWM session.

> **Note:** SomeWM links against **LuaJIT (Lua 5.1)**, and `.luarc.json`
> assumes 5.1. The `ez` target in the `Makefile` currently uses
> `pkg-config lua5.3`, and it runs `eztest.lua`, which has moved to `attic/`.
> If `ez.so` fails to load, rebuild it against `luajit` or `lua5.1`.

## Development workflow

- **Live evaluation**: `somewm-eval.sh <file.lua>` runs a Lua file inside the
  running compositor through `somewm-client eval`. `make draft
  draftfile=foo.lua` reruns it with `entr` whenever a `.lua` or `.so` file
  changes, so you can try widgets without restarting.
- **Reload**: `Mod4+Ctrl+r` restarts SomeWM in place. Autostart entries use
  `awful.spawn.once` and are not started twice.
- **Debugging**: use `ic(...)` from `lib.icecream`, inspect the focused
  client with `Mod4+i`, and read `~/.cache/somewm-errors.log` for tracebacks.
- **LSP**: `.luarc.json` points lua-language-server at SomeWM's Lua library
  and declares the compositor globals (`awesome`, `client`, `screen`, …).
- **C module**: `make ez_watch` rebuilds `ez.so` whenever a C or Lua file
  changes.
- **Docs**: `make docs` runs ldoc (`make docs-watch` for live rebuilds). The
  ldoc config and templates are currently in `attic/docs`.
- **Fonts**: `make fonts` installs Material Symbols to `~/.local/share/fonts`.
- **Assets**: images, fonts, `.so` and video files go through Git LFS (see
  `.gitattributes`).

## Coming from the AwesomeWM branch

- Things that were X11-only (`xrandr.lua`, the fcitx and screen-capture
  drafts, the old exit screen, animations, and earlier `rc.lua` versions)
  were moved to `attic/` and are not loaded.
- Locking uses `awesome.lock()`, and idle handling uses
  `awesome.set_idle_timeout` / `awesome.idle_inhibit` (commented out in
  `rc.lua`). xautolock/i3lock are no longer used.
- Keyboard layout and touchpad settings use `awful.input.*`.
- SomeWM's own extras are left commented out in `rc.lua`, ready to enable:
  layout animations (`somewm.layout_animation`) and custom IPC commands
  (`awful.ipc.register`, called with `somewm-client run <name>`).
