#!/bin/sh

DISPLAY=:1
if [ -z $1 ]; then
  Xephyr -br -ac -noreset -screen 800x600 $DISPLAY
else
  DISPLAY=$DISPLAY $@
fi
