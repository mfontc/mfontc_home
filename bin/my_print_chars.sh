#!/bin/bash

fast_chr() {
	local __octal
	local __char
	printf -v __octal '%03o' $1
	printf -v __char \\$__octal
	REPLY=$__char
}

unichr() {
	local c=$1  # ordinal of char
	local l=0   # byte ctr
	local o=63  # ceiling
	local p=128 # accum. bits
	local s=''  # output string

	(( c < 0x80 )) && { fast_chr "$c"; echo -n "$REPLY"; return; }

	while (( c > o )); do
		fast_chr $(( t = 0x80 | c & 0x3f ))
		s="$REPLY$s"
		(( c >>= 6, l++, p += o+1, o>>=1 ))
	done

	fast_chr $(( t = p | c ))
	echo -n "$REPLY$s"
}

test() {
	_from=$1; _to=$2; j=0
	for (( i=$_from; i<$_to; i++ )); do
		(( j == 0 ))    && printf "\n0x%x" $i
		(( j++ >= 31 )) && j=0
		printf "  "

		unichr $i
	done
	echo
}

from=$1
to=$2

if [ ! -z "$from" ]; then
	if [ ! -z "$to" ]; then
		test 0x$from 0x$to
		exit 0
	fi
fi

## test harness
test 0x2500 0x2600
test 0x2600 0x2700
test 0x2700 0x2800
test 0x2800 0x2900
test 0x2900 0x2a00
test 0x2a00 0x2b00

test 0xe0a0 0xe0c0

