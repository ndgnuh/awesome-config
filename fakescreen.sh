#!/bin/sh

DISPLAY=:1
if [ -z $1 ]; then
  DISPLAY=:0 Xephyr -br -ac -noreset -screen 800x600 "$DISPLAY"
else
  DISPLAY=$DISPLAY $@
fi
