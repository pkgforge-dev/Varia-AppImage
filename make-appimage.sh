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
             /usr/bin/varia-py.py \
             /usr/share/varia \
             /usr/bin/normalizer \
             /usr/bin/ffmpeg \
             /usr/bin/ffprobe \
             /usr/bin/aria2c \
             /usr/bin/aria2p \
             /usr/bin/yt-dlp \
             /usr/lib/libgirepository*

# Patch varia's shell script to be POSIX and to use AppImage directories
cat << 'EOF' > ./AppDir/bin/varia
#!/bin/sh
pythonexec="$(command -v python3)"
# For some reason, SHARUN_DIR is not exposed here, so I need to get it manually
sharunbindir="${pythonexec%/*}"
"$pythonexec" "${sharunbindir}/varia-py.py" "${sharunbindir}/aria2c" "${sharunbindir}/ffmpeg" NOSNAP "$@"
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
