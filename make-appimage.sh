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
export DEPLOY_GTK=1
export GTK_DIR=gtk-4.0
export ANYLINUX_LIB=1
export DEPLOY_LOCALE=1
export STARTUPWMCLASS=io.github.giantpinkrobots.varia # Default to Wayland's wmclass. For X11, GTK_CLASS_FIX will force the wmclass to be the Wayland one.
export GTK_CLASS_FIX=1

# Deploy dependencies
quick-sharun /usr/bin/varia \
             /usr/bin/varia-py.py \
             /usr/share/varia \
             /usr/bin/normalizer \
             /usr/bin/ffmpeg \
             /usr/bin/ffprobe \
             /usr/bin/aria2c \
             /usr/bin/aria2p \
             /usr/bin/yt-dlp \
             /usr/bin/deno \
             /usr/lib/libayatana* \
             /usr/share/gir-*/Ayatana* \
             /usr/lib/girepository-*/Ayatana* \
             /usr/lib/libgirepository*

# Bundle static 7zip
VER="$(curl -qfsSL "https://api.github.com/repos/ip7z/7zip/releases/latest" | jq -r '.tag_name' | tr -d '"'\''[:space:]')"
case "$ARCH" in
    aarch64)
      wget --retry-connrefused --tries=30 "https://github.com/ip7z/7zip/releases/download/$VER/7z${VER//./}-linux-arm64.tar.xz" -O /tmp/7z.tar.xz
      ;;
    x86_64)
      wget --retry-connrefused --tries=30 "https://github.com/ip7z/7zip/releases/download/$VER/7z${VER//./}-linux-x64.tar.xz" -O /tmp/7z.tar.xz
      ;;
esac
mkdir -p /tmp/7zip/
tar -xf /tmp/7z.tar.xz -C /tmp/7zip/
cp /tmp/7zip/7zzs ./AppDir/bin/7z
chmod +x ./AppDir/bin/7z
rm -r /tmp/7z.tar.xz /tmp/7zip/

# Download missing icons
TARGET_DIR="./AppDir/share/icons/hicolor/symbolic/ui/"
mkdir -p "$TARGET_DIR"
REPO="giantpinkrobots/varia"
BRANCH="next"
PATH_DIR="data/icons/hicolor/symbolic/ui"
URLS="$(curl -s "https://api.github.com/repos/$REPO/contents/$PATH_DIR?ref=$BRANCH" | jq -r '.[] | select(.type == "file") | .download_url')"
for url in $URLS; do
  wget -P "$TARGET_DIR" "$url"
done

# Patch varia's shell script to be POSIX and to use AppImage directories
cat << 'EOF' > ./AppDir/bin/varia
#!/bin/sh
"${APPDIR}/bin/python3" "${APPDIR}/bin/varia-py.py" "${APPDIR}/bin/aria2c" "${APPDIR}/bin/ffmpeg" "${APPDIR}/bin/7z" "${APPDIR}/bin/deno" NOSNAP "$@"
EOF

# Patch varia's python script to use AppImage directories
sed -i '/^pkgdatadir/c\pkgdatadir = os.getenv("SHARUN_DIR", "/usr") + "/share/varia"' ./AppDir/bin/varia-py.py
sed -i '/^localedir/c\localedir = os.getenv("SHARUN_DIR", "/usr") + "/share/locale"' ./AppDir/bin/varia-py.py

# Patch aria2p to be POSIX
cat << 'EOF' > ./AppDir/bin/aria2p
#!/bin/sh

PYTHON_SCRIPT='
import re
import sys
from aria2p.cli.main import main

if __name__ == "__main__":
    sys.argv[0] = re.sub(r"(-script\.pyw|\.exe)?$", "", sys.argv[0])
    sys.exit(main())
'

# Execute the Python script using Python interpreter
python -c "$PYTHON_SCRIPT"
EOF

# Turn AppDir into AppImage
quick-sharun --make-appimage
