# Awesome config(s)
Multi rice based Awesomewm config

Table of contents:
- [Preview](#some-setups)
    - [Guns girl - Schooldayz](#guns-girl-schooldayz)
    - [Fancy](#fancy)
- [Usage](#usage)
    - [Directory structure](#the-directory-structure)
    - [The "api" module](#volume-battery-and-brightness-widget-with-api-module)
    - [Fast switching between setups](#quick-switching-between-setups)


## Preview
I haven't done much yet

| setup name | description |
| ----------| ---------|
| default | the default of awesomewm |
| basic | nearly default, but some configs are changed |
| friendly | mouse orientated, just in case some borrow my laptop? |
| guns girl | a setup based on a mobile game by [Mihoyo](https://www.mihoyo.com/) |
| fancy | me playing with cairo |

The 3 first setup is really default, and the latter two use `gtk` theme that came with `awesome`, so i'm only posting previews of other setup(s).

### Fancy
Basically me playing with cairo.
![preview](https://raw.githubusercontent.com/ndgnuh/awesome-config/gh-resources/fancy.png)

### Guns girl - Schooldayz
Based on a [mobile game](https://www.youtube.com/watch?v=Rk1cIG1iC8o) by Mihoyo. 
Change the `ign`, `iglevel` in the `ggz/init.lua` to whatever username and level you want. 
Replace `ggz/icons/avatar.png` and `ggz/icons/wallpaper.png` for the user image and the background (too lazy so i those in the `icons` folder :P should have changed the name to `resources`)
![preview](https://raw.githubusercontent.com/ndgnuh/awesome-config/gh-resources/awesome-ggz.png)


## Usage
### The directory tree:
```sh
├── api
│   ├── audio.lua
│   ├── battery.lua
│   ├── bluetooth.lua
│   ├── brightness.lua
│   └── init.lua
├── backup.lua
├── basic
│   └── init.lua
├── configset.lua
├── constant.lua
├── default
│   └── init.lua
├── defaulticon.png
├── defaulticon.svg
├── draft.lua
├── exit.lua
├── friendly
│   ├── init.lua
│   └── theme.lua
├── ggz
│   ├── icons
│   ├── init.lua
│   ├── mediapopup.lua
│   ├── theme.lua
│   └── widgets
├── material-dark
│   ├── bar.lua
│   ├── icons
│   ├── icons.lua
│   ├── init.lua
│   ├── rc
│   └── theme.lua
├── mediakeys.lua
├── mediapopup.lua
├── popup
│   └── init.lua
├── rc.lua
├── test.lua
├── themes
│   ├── default
│   └── gtk
└── tile
    └── init.lua

```
### volume, battery and brightness widget with `api` module
I'm too lazy to give it a cool name or something like that, so I'll call it `api`. The `api` do all the "behind the scene" stuff. It allows a widget to be udpated by connecting to a specific signal.
`api.bluetooh` isn't coded yet.
```sh
api
├── audio.lua
├── battery.lua
├── bluetooth.lua
├── brightness.lua
└── init.lua
```
Usage:
```lua
api = require("api")
api.<module-you-need>.attach(<your-widget>)
<your-widget>:connect_signal(api.<module>.signal.update, function(_, args)
  -- do what you want
  -- naughty.notify({ text = gears.debug.dump_return(args) }) to see what's in the args
 end)
 ```
 
 The `acpi.battery` is based on [someone else's work](https://github.com/lexa/awesome_upower_battery), which require `upower>=0.99` awesome>=4.2 with `dbus` and `lgi` enabled.
### Quick switching between setups
I have a file called `configset.lua`, which contains only 1 line:
```lua
require("ggz")
```
Here, `ggz` is one of my setup, themes, widget, tags, etc... I have a function which do `sed` and stuff, edit the `configset.lua` from one setup to another. The function is defined in `rc.lua`. I also create a `submenu` for `awful.menu` to quicky switch between setups.

If you want to migrate your setup to this kind of structure: backup your setup, clone this repo to `~/.config/awesome`, move your `rc.lua` to `~/.config/awesome/yoursetup.lua`, after that edit the `configset` menu in `rc.lua` and you are done.

### Other files
If i don't mention them, they are either one of the setups, trash files or wip.
