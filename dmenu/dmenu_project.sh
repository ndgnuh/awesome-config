#!/bin/zsh
pjdir=$HOME/projects;
dir="$(echo "cancel\n$(ls -1 $pjdir/)" | dmenu)";
sakura -d "$pjdir/$dir"
