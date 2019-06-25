local spawnonce = require("awful").spawn.once
-- not an built in module of awesome
spawnonce("ibus-daemon -rdx")
spawnonce("compton")
spawnonce("nm-applet")
spawnonce("xfce4-power-manager")
-- spawnonce("redshift -l 21.0472686:105.8583874")
spawnonce("xrandr --output HDMI1 --auto --left-of eDP1")
