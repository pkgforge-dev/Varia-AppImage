#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Building package and its dependencies..."
echo "---------------------------------------------------------------"
make-aur-package python-emoji-country-flag
make-aur-package aria2p
make-aur-package varia
pacman -Syu --noconfirm python-charset-normalizer libayatana-appindicator
pacman -Rns python-pystray

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano ffmpeg-mini
