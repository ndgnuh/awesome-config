#!/bin/sh
input="$1"
if [ -z "$input" ];
then
    echo "No input file"
    exit 2
fi

if ! [ -f "$input" ]; then
    echo "File $input does not exist"
    exit 3
fi

rp=$(realpath "$input")
somewm-client eval "return dofile('$rp')"
