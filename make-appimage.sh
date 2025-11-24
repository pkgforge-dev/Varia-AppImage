#!/bin/sh

set -eu

ARCH=$(uname -m)
VERSION=$(pacman -Q varia | awk '{print $2; exit}')
export ARCH VERSION
export OUTPATH=./dist
export ADD_HOOKS="self-updater.bg.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=/usr/share/icons/hicolor/scalable/apps/io.github.giantpinkrobots.varia.svg
export DESKTOP=/usr/share/applications/io.github.giantpinkrobots.varia.desktop
export DEPLOY_SYS_PYTHON=1
export DEPLOY_OPENGL=1
export DEPLOY_GTK=1
export GTK_DIR=gtk-4.0
export ANYLINUX_LIB=1
export DEPLOY_LOCALE=1
export STARTUPWMCLASS=varia # For Wayland, this is 'io.github.giantpinkrobots.varia', so this needs to be changed in desktop file manually by the user in that case until some potential automatic fix exists for this

# Deploy dependencies
quick-sharun /usr/bin/varia \
             /usr/bin/aria2c \
             /usr/bin/aria2p \
             /usr/lib/libgirepository*

# Turn AppDir into AppImage
quick-sharun --make-appimage
