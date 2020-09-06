#!/bin/env sh

help () {
	echo "Usage: "
	echo ""
	echo "    $(basename $0) <beautiful-key>"
}

if [ -z $1 ]; then
	help 1>&2
	exit
fi

colorkey=$1
luacode="return require('beautiful')['$1']"

printf "%s" $(awesome-client "$luacode" |
	sed 's/^ *//g' |
	awk '{print $2}' |
	sed 's/"//g')
