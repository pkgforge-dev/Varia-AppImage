#!/bin/sh

set -eu

ARCH=$(uname -m)

pacman -Syu --noconfirm python-charset-normalizer jq

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano ffmpeg-mini

echo "Building package and its dependencies..."
echo "---------------------------------------------------------------"
make-aur-package deno-stable-bin
make-aur-package python-emoji-country-flag
make-aur-package aria2p
# Switch to the official package when it updates
make-aur-package
