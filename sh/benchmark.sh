#!/bin/sh
if [ "$1" = "old" ]; then
	echo "benchmarking old script"
	for i in $(seq 1 1000); do
		./ibus-cycle.old.sh
	done
else
	echo "benchmarking new script"
	for i in $(seq 1 1000); do
		./ibus-cycle.sh
	done
fi
