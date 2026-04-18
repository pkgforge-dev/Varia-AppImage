#!/bin/sh

set -eu

ARCH=$(uname -m)

pacman -Syu --noconfirm python-charset-normalizer python-appdirs

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano ffmpeg-mini

echo "Building package and its dependencies..."
echo "---------------------------------------------------------------"
make-aur-package bun-bin
make-aur-package python-emoji-country-flag
make-aur-package aria2p
make-aur-package varia

# yt-dlp gives a warning that only deno is supported by default
sed -i -e "s|default=\['deno'\]|default=['bun']|" /usr/lib/python*/site-packages/yt_dlp/options.py
