#!/bin/sh

engine0="Bamboo"
engine1="xkb:us::eng"

index=-1
current_engine=$(ibus engine)

if [ -z $current_engine ]; then
	ibus-daemon -rdxs
	ibus engine 'xkb:us::eng'
fi

engine="something"

# search in the list of engines
while [ "$engine" != "" ]; do
	index=$((index + 1))
	eval engine="\$engine$index"
	if [ "$current_engine" = "$engine" ]; then
		engine=""
	fi
done

# next engine
index=$((index + 1))
eval engine="\$engine$index"
if [ "$engine" = "" ]; then
	engine="$engine0"
fi
ibus engine "$engine"

echo -n "$(ibus engine | sed 's/\n$//g')" 
