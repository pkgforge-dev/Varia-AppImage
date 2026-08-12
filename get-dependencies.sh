#!/bin/sh

set -eu

ARCH=$(uname -m)

pacman -Syu --noconfirm python-charset-normalizer python-appdirs

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano ffmpeg-mini

echo "Building quickjs..."
echo "---------------------------------------------------------------"
git clone https://github.com/bellard/quickjs ./quickjs && (
	cd ./quickjs
	make -s
	make -s install PREFIX=/usr
)

echo "Building package and its dependencies..."
echo "---------------------------------------------------------------"
make-aur-package deno-stable-bin
make-aur-package python-emoji-country-flag
make-aur-package aria2p
make-aur-package varia

# yt-dlp gives a warning that only deno is supported by default
sed -i -e "s|default=\['deno'\]|default=['quickjs']|" /usr/lib/python*/site-packages/yt_dlp/options.py
pacman -Rdd --noconfirm deno-stable-bin
