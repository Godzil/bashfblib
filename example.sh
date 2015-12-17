#!/bin/sh

# Include the library
. bashfblib.sh


# Usage: ./example.sh min max r g b

for y in `seq $1 $2`; do
	for x in `seq $1 $2`; do
		drawpixel $x $y $3 $4 $5
	done
done

fblib_cleanup
