#!/bin/sh

mem=$(free  | awk '/Mem:/ {print $4}')
swap=$(free | awk '/Swap:/ {print $3}')

if [ $mem -lt $swap ]; then
    echo "ERROR: not enough RAM to write swap back, nothing done" >&2
    exit 1
fi

sudo swapoff -a && sudo swapon -a

