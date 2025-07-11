# Maintainer: mazixs <mazixs@example.com>
pkgname=cursor-app
pkgver=0.44.9
pkgrel=1
pkgdesc="The AI-first code editor"
arch=('x86_64')
url="https://cursor.so"
license=('custom')
depends=('gtk3' 'libxss' 'gconf' 'nss' 'alsa-lib')
optdepends=('libappindicator-gtk3: for system tray support')
provides=('cursor')
conflicts=('cursor')
source=("cursor-${pkgver}.AppImage::https://downloader.cursor.sh/linux/appImage/x64")
sha256sums=('SKIP')
noextract=("cursor-${pkgver}.AppImage")

prepare() {
    chmod +x "cursor-${pkgver}.AppImage"
}

build() {
    # Extract the AppImage
    "./cursor-${pkgver}.AppImage" --appimage-extract
}

package() {
    # Install the application
    install -dm755 "${pkgdir}/opt/${pkgname}"
    cp -a squashfs-root/* "${pkgdir}/opt/${pkgname}/"
    
    # Create symlink for the binary
    install -dm755 "${pkgdir}/usr/bin"
    ln -s "/opt/${pkgname}/cursor" "${pkgdir}/usr/bin/cursor"
    
    # Install desktop file
    install -Dm644 "squashfs-root/cursor.desktop" "${pkgdir}/usr/share/applications/cursor.desktop"
    
    # Fix desktop file
    sed -i 's|Exec=.*|Exec=/usr/bin/cursor %U|g' "${pkgdir}/usr/share/applications/cursor.desktop"
    sed -i 's|Icon=.*|Icon=cursor|g' "${pkgdir}/usr/share/applications/cursor.desktop"
    
    # Install icon
    for size in 16 32 48 64 128 256 512; do
        if [ -f "squashfs-root/usr/share/icons/hicolor/${size}x${size}/apps/cursor.png" ]; then
            install -Dm644 "squashfs-root/usr/share/icons/hicolor/${size}x${size}/apps/cursor.png" \
                "${pkgdir}/usr/share/icons/hicolor/${size}x${size}/apps/cursor.png"
        fi
    done
    
    # Install license
    install -Dm644 "squashfs-root/LICENSE" "${pkgdir}/usr/share/licenses/${pkgname}/LICENSE"
}