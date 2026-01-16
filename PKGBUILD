# Maintainer: Mahdi Sarikhani <mahdisarikhani@outlook.com>
# Contributor: jdigi78 <jdigiovanni78 at gmail dot com>

pkgname=varia
pkgver=2026.1.5
pkgrel=2
pkgdesc="Download manager based on aria2"
arch=('any')
url="https://giantpinkrobots.github.io/varia"
license=('MPL-2.0')
depends=('7zip'
         'aria2'
         'aria2p'
         'bash'
         'dconf'
         'deno'
         'ffmpeg'
         'glib2'
         'gtk4'
         'hicolor-icon-theme'
         'libadwaita'
         'libayatana-appindicator'
         'pango'
         'python'
         'python-appdirs'
         'python-dbus-next'
         'python-emoji-country-flag'
         'python-gobject'
         'python-pillow'
         'python-requests'
         'yt-dlp')
makedepends=('meson')
source=("${pkgname}-${pkgver}-2.tar.gz::https://github.com/giantpinkrobots/varia/archive/refs/tags/v${pkgver}-2.tar.gz")
sha256sums=('a3ee96cdc0d12fa562b07497de31e9d8780a200c34b4d37c07f5bc511d39bd30')

build() {
    arch-meson "${pkgname}-${pkgver}" build
    meson compile -C build
}

package() {
    meson install -C build --destdir "${pkgdir}"
}
