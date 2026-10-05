#!/usr/bin/env zsh
# vim: ft=zsh ts=2 sw=2 sts=2 noexpandtab

which pwgen &> /dev/null || {
  echoEr "There are some missed packages in the system!"
  sudo apt-get update || exit 1
  sudo apt-get install pwgen || exit 1
}

pwgen --capitalize --numerals --secure --ambiguous 16 100
