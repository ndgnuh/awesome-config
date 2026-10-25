.PHONY: docs check
PREFIX ?= "$(HOME)/.local/"

draftfile ?= "draft.lua"

draft:
	echo $(draftfile)
	sleep 1
	find -name "*.lua" -or -name "*.so" | entr -rc ./somewm-eval.sh $(draftfile)

fonts:
	cp assets/fonts/material-symbols-rounded.ttf $(PREFIX)/share/fonts/

docs-watch:
	find -name "*.lua" \
		-o -name "*.ld" \
		-o -name "*.ltp" \
		-o -name "*.css" \
		-o -name "*.md" \
		-o -name "Makefile" \
		| entr -rc make docs

docs:
	ldoc . --unsafe_no_sandbox --multimodule

docs-lunadoc:
	lunadoc -d public `find ndgnuh -name "*lua"` `find libs -name "*.lua"`

ez_watch:
	find -name "*.c" \
		-or -name "Makefile" \
		-or -name "*.lua" | entr -rc make ez

ez:
	clang \
		$(shell pkg-config --cflags --libs lua5.3)\
		-Wall -Wextra -std=c99 \
		-FPIC -shared \
		ez.c -o ez.so
	lua eztest.lua

check:
	luajit tests/test_overdrip_re.lua
	luajit tools/check_overdrip.lua
