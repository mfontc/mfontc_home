#!/usr/bin/env zsh
# vim: ft=zsh ts=2 sw=2 sts=2 noexpandtab

fast_chr() {
  local __octal
  local __char
  printf -v __octal '%03o' $1
  printf -v __char \\${__octal}
  REPLY=${__char}
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

_test() {
  _from=$1; _to=$2; j=0
  for (( i=$_from; i<$_to; i++ )); do
    (( j == 0 ))    && printf "\n0x%x" ${i}
    (( j++ >= 31 )) && j=0
    printf "  "

    unichr ${i}
  done
  echo
}

from=$1
to=$2

if [ -n "$from" ]; then
  if [ -n "$to" ]; then
    _test 0x${from} 0x${to}
    exit 0
  fi
fi

## test harness
_test 0x2000 0x2100
_test 0x2100 0x2200
_test 0x2200 0x2300
_test 0x2300 0x2400
_test 0x2400 0x2500
_test 0x2500 0x2600
_test 0x2600 0x2700
_test 0x2700 0x2800
_test 0x2800 0x2900
_test 0x2900 0x2a00
_test 0x2a00 0x2b00
_test 0x2b00 0x2c00
_test 0x2c00 0x2d00
_test 0x2d00 0x2e00
_test 0x2e00 0x2e53

_test 0xe0a0 0xe0c0

echo -e "\nHelp:\n  $0 00a0 ffff"
