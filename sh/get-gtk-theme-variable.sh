#!/bin/env sh

if [ -z $1 ]; then
	output="gtk-theme-dump.txt"
else
	output="$1"
fi

luacmd='do
	local gdb = require("gears.debug")
	local btf = require("beautiful")
	local d1 = gdb.dump_return(btf.gtk.get_theme_variables())
	local d2 = gdb.dump_return(btf.gtk)
	return d1 .. "\n" .. d2
end'

awesome-client "$luacmd" > $output
