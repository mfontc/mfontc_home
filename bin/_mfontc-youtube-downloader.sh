#!/bin/sh
# vim:ft=zsh ts=4 sw=4 sts=4 noexpandtab

which youtube-dl > /dev/null 2>&1 || {
	sudo apt-get update
	sudo apt-get install youtube-dl
}

youtube-dl --rate-limit=1.5M $*

