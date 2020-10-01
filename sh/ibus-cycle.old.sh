#!/bin/sh
# chỉnh bộ gõ ở đây {{{ #
engines="xkb:us::eng, Bamboo"
# }}} chỉnh bộ gõ ở đây #


engines=$(echo $engines | sed s'/\s//g')
first_engine=$(echo $engines | cut -d ',' -f 1)
cur_next_engines=$(echo $engines \
	| tr ',' '\n' \
	| grep  $(ibus engine) -A 1 \
)
# echo $cur_next_engines
next_engine=$(echo $cur_next_engines \
	| tr ' ' '\n' \
	| tail -n 1 \
)

if [ "$cur_next_engines" = "$next_engine" ]; then
	next_engine=$first_engine
fi

# echo $next_engine
ibus engine $next_engine
