#!/bin/sh
if [ -z $cmd ]; then
	cmd="xbacklight"
fi

thearg=""
case $cmd in
	xbacklight)
		argget="-get"
		argset="-set"
		arginc="-inc"
		argdec="-dec"
		argext=""
		;;
	light)
		argget="-G"
		argset="-S"
		arginc="-A"
		argdec="-U"
		argext="-v 3"
		;;
	*)
		printf "unknown brightness command" 1>&2
		exit 2
		;;
esac

eval thearg="\$arg$1"
theval=$2
"$cmd" "$thearg" "$theval" 1> /dev/null
printf "%s" "$("$cmd" "$argget")"
