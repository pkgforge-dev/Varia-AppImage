<div align="center">

# Varia AppImage 🐧

[![GitHub Downloads](https://img.shields.io/github/downloads/pkgforge-dev/Varia-AppImage/total?logo=github&label=GitHub%20Downloads)](https://github.com/pkgforge-dev/Varia-AppImage/releases/latest)
[![CI Build Status](https://github.com//pkgforge-dev/Varia-AppImage/actions/workflows/appimage.yml/badge.svg)](https://github.com/pkgforge-dev/Varia-AppImage/releases/latest)
[![Latest Stable Release](https://img.shields.io/github/v/release/pkgforge-dev/Varia-AppImage)](https://github.com/pkgforge-dev/Varia-AppImage/releases/latest)

<p align="center">
  <img src="https://raw.githubusercontent.com/giantpinkrobots/varia/refs/heads/next/data/icons/hicolor/scalable/apps/io.github.giantpinkrobots.varia.svg" width="128" />
</p>

| Latest Stable Release | Upstream URL |
| :---: | :---: |
| [Click here](https://github.com/pkgforge-dev/Varia-AppImage/releases/latest) | [Click here](https://giantpinkrobots.github.io/varia/) |

</div>

---

AppImage made using [sharun](https://github.com/VHSgunzo/sharun) and its wrapper [quick-sharun](https://github.com/pkgforge-dev/Anylinux-AppImages/blob/main/useful-tools/quick-sharun.sh), which makes it easy and reliable to turn any binary into a portable package without using containers or similar tricks. 

**This AppImage bundles everything and it should work on any Linux distro, including old and musl-based ones.**

This AppImage doesn't require FUSE to run at all, thanks to the [uruntime](https://github.com/VHSgunzo/uruntime).

This AppImage is also supplied with the seamless self-updater by default, so any updates to this application won't be missed.  
Self-updater doesn't run if AppImage managers like [am](https://github.com/ivan-hc/AM) or [soar](https://github.com/pkgforge/soar) exist, which manage AppImage integration and updates.

<details>
  <summary><b><i>Filesize efficiency compared to flatpak</i></b></summary>
    <img src="https://github.com/user-attachments/assets/29576c50-b39c-46c3-8c16-a54999438646" alt="Inspiration Image">
  </a>
</details>

More at: [AnyLinux-AppImages](https://pkgforge-dev.github.io/Anylinux-AppImages/)

---

## Known quirks
- If portable `.config` and/or `.home` directory is used, app fails to launch due to it not detecting `XDG_DOWNLOAD_DIR`.  
  Additionally, if portable `.share` directory is used and flatpak Firefox or Chromium-based browser is installed,  
  link for the extension in settings won't open due to app thinking that flatpak is in the portable share directory.  
  https://github.com/giantpinkrobots/varia/issues/236
- Autostart option in settings doesn't work.  
  Copying the desktop file manually to `$XDG_CONFIG_HOME/autostart/` makes it work.  
  https://github.com/pkgforge-dev/Varia-AppImage/issues/3
- Varia doesn't send the notification when download starts using the browser extension.  
  Tested on Firefox.  
  https://github.com/pkgforge-dev/Varia-AppImage/issues/4
