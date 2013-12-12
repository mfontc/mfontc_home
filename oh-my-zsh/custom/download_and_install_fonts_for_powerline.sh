#!/bin/bash

echo -e "\ue0a0\ue0a1\ue0a2\ue0b0\ue0b1\ue0b2"

mkdir -p ~/tmp || exit 1
cd       ~/tmp || exit 1
sudo wget https://github.com/Lokaltog/powerline/raw/develop/font/PowerlineSymbols.otf || exit 1
sudo wget https://github.com/Lokaltog/powerline/raw/develop/font/10-powerline-symbols.conf || exit 1
sudo mv PowerlineSymbols.otf /usr/share/fonts/ || exit 1
sudo fc-cache -vf || exit 1
sudo mv 10-powerline-symbols.conf /etc/fonts/conf.d/ || exit 1

echo -e "\ue0a0\ue0a1\ue0a2\ue0b0\ue0b1\ue0b2"

