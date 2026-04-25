#!/bin/sh

set -eu

ARCH=$(uname -m)
VERSION=$(pacman -Q varia | awk '{print $2; exit}')
export ARCH VERSION
export OUTPATH=./dist
export ADD_HOOKS="self-updater.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=/usr/share/icons/hicolor/scalable/apps/io.github.giantpinkrobots.varia.svg
export DESKTOP=/usr/share/applications/io.github.giantpinkrobots.varia.desktop
export DEPLOY_PYTHON=1
export DEPLOY_GTK=1
export GTK_DIR=gtk-4.0
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
             /usr/bin/bun \
             /usr/lib/libayatana* \
             /usr/share/gir-*/Ayatana* \
             /usr/lib/girepository-*/Ayatana* \
             /usr/lib/libgirepository* \
             /usr/lib/7zip/*

# Patch varia's shell script to be POSIX and to use AppImage directories
cat << 'EOF' > ./AppDir/bin/varia
#!/bin/sh
pythonexec="$APPDIR/bin/python"

aria2cexec="$APPDIR/bin/aria2c"
ffmpegexec="$APPDIR/bin/ffmpeg"
sevenzexec="$APPDIR/bin/7z"
jsruntimeexec="$APPDIR/bin/bun"
jsruntime="bun"
jsruntimeexecname="bun"

while [ $# -gt 0 ] ; do
  case $1 in
	-h|--help) echo "Options:
	--aria2cexec PATH		Path to aria2c executable
	--ffmpegexec PATH		Path to ffmpeg executable
	--sevenzexec PATH		Path to 7z executable
	--jsruntime NAME		JavaScript runtime name (read by yt-dlp, defaults to bun)
	--jsruntimeexec PATH	Path to JS runtime executable
	-h, --help				Show this help message"
	exit 0 ;;
	--aria2cexec) aria2cexec="$2"; shift ;;
	--ffmpegexec) ffmpegexec="$2"; shift ;;
	--sevenzexec) sevenzexec="$2"; shift ;;
  --jsruntime) jsruntime="$2"; shift ;;
	--jsruntimeexec) jsruntimeexec="$2"; shift ;;
	*) break ;;
  esac
  shift
done

if [ ! -f "$aria2cexec" ] || [ ! -f "$ffmpegexec" ] || [ ! -f "$sevenzexec" ] || [ ! -f "$jsruntimeexec" ]; then
	echo "Given paths for dependencies not found, searching the system for them..."
	aria2cexec="$(command -v aria2c)"
	ffmpegexec="$(command -v ffmpeg)"
	sevenzexec="$(command -v 7z)"
	jsruntimeexec="$(command -v $jsruntimeexecname)"
	if [ ! -f "$aria2cexec" ] || [ ! -f "$ffmpegexec" ] || [ ! -f "$sevenzexec" ] || [ ! -f "$jsruntimeexec" ]; then
		echo "aria2c and/or ffmpeg and/or 7z and/or the JS runtime (defaults to bun) not found. Exiting."
		exit 1
	fi
fi

echo "Selected JS Runtime name: ${jsruntime}"

$pythonexec "$APPDIR/bin/varia-py.py" "$aria2cexec" "$ffmpegexec" "$sevenzexec" "$jsruntime" "$jsruntimeexec" "NOSNAP" "$@"
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

# Test the final app
quick-sharun --test ./dist/*.AppImage
