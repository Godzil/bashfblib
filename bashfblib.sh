#!/bin/sh
# Dependency, shell, printf, dd

# TODO: Dependency on dd can be removed, but will be really slow
# TODO: Implement double buffering
# TODO: Propose no dependency on printf
NO_DD=0
USE_DOUBLE_BUFFERING=0
NO_PRINTF=0

# NEED TO FILL THIS INFORMATION
#   geometry 220 176 220 352 16
#   rgba 5/11,6/5,5/0,0/0
# TODO: Adding a dependency on fbset we may be able to autoset this:
SCREEN_WIDTH=220
SCREEN_HEIGHT=176
RED_DEPTH=5
GREEN_DEPTH=6
BLUE_DEPTH=5
RED_POS=11
GREEN_POS=5
BLUE_POS=0
TEMP=`mktemp`
SCREEN_FB=/dev/fb0
###

# AUTOCALCULATED VALUES
BIT_PER_PIXEL=$((${RED_DEPTH}+${GREEN_DEPTH}+${BLUE_DEPTH}))
BYTE_PER_PIXEL=$((${BIT_PER_PIXEL}/8))
SCREEN_STRIDE=$((${BYTE_PER_PIXEL}*${SCREEN_WIDTH}))
RED_MAX=$((2**${RED_DEPTH}))
GREEN_MAX=$((2**${GREEN_DEPTH}))
BLUE_MAX=$((2**${BLUE_DEPTH}))
RED_SHIFT=$((2**${RED_POS}))
GREEN_SHIFT=$((2**${GREEN_POS}))
BLUE_SHIFT=$((2**${BLUE_POS}))

drawpixel()
{
	x=$1; shift 1
	y=$1; shift 1
	r=$1; shift 1
	g=$1; shift 1
	b=$1; shift 1

	skip=$(($((${x}*${BYTE_PER_PIXEL}-1))+$((${y}*${SCREEN_STRIDE}))))

	rc=$((${r}*${RED_MAX}/256))
	gc=$((${g}*${GREEN_MAX}/256))
	bc=$((${b}*${BLUE_MAX}/256))

	rs=$((${rc}*${RED_SHIFT}))
	gs=$((${gc}*${GREEN_SHIFT}))
	bs=$((${bc}*${BLUE_SHIFT}))

	value=$((${rs}+${gs}+${bs}))

	echo -ne "" > ${TEMP}
	for i in `seq $((${BIT_PER_PIXEL}-8)) -8 0`; do
		val=$(($((${value}/$((2**$i))))&255))
		echo -ne "$(printf '\\x%x' ${val})" >> ${TEMP}
	done

	dd if=${TEMP} of=${SCREEN_FB} bs=1 seek=${skip} count=${BYTE_PER_PIXEL} 2&> /dev/null
}

fblib_cleanup()
{
	rm ${TEMP}
}
}
