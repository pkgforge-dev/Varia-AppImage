#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Building package and its dependencies..."
echo "---------------------------------------------------------------"
make-aur-package aria2p
make-aur-package varia

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano
