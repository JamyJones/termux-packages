apt-get update -y && apt-get upgrade -y
apt-get install -y gcc g++ clang
TERMUX_PKG_HOMEPAGE=https://github.com/John4650-hub/my-Termux-packs
TERMUX_PKG_DESCRIPTION="A pdfViewer using pdfmium"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@john4650-hub"
TERMUX_PKG_VERSION=1.24.10
TERMUX_PKG_API_LEVEL=23
TERMUX_PKG_SRCURL=https://github.com/John4650-hub/my-Termux-packs/archive/refs/tags/$(curl -s https://api.github.com/repos/John4650-hub/my-Termux-packs/releases/latest | jq -r .tag_name).tar.gz
TERMUX_PKG_SHA256=SKIP_CHECKSUM
TERMUX_PKG_ESSENTIAL=true
TERMUX_PKG_DEPENDS="libpng"
TERMUX_PKG_BUILD_DEPENDS="openjpeg, freetype, harfbuzz, jbig2dec, gumbo-parser, zlib, libpng"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true

TERMUX_INCLUDE_DIR="$TERMUX_PREFIX/include"
TERMUX_LIB_DIR="$TERMUX_PREFIX/lib"
mkdir -p $TERMUX_INCLUDE_DIR  $TERMUX_LIB_DIR
#download pdfium-no-v8
install_incase_pdfmium(){
curl -L "https://github.com/bblanchon/pdfium-binaries/releases/latest/download/pdfium-android-arm.tgz" -o pdfium-android-arm.tgz
mkdir foo/ && cd foo
tar -xvzf ../pdfium-android-arm.tgz
cd ..
# get lib
cp -r foo/lib/ "$TERMUX_PREFIX",
# get headers
# ok
cp -r foo/include "$TERMUX_PREFIX"
}
cd $TERMUX_INCLUDE_DIR
mkdir argparse
curl -L "https://raw.githubusercontent.com/p-ranav/argparse/refs/heads/master/include/argparse/argparse.hpp" -o argparse/argparse.hpp
cd -
ls $TERMUX_INCLUDE_DIR
curl -LO "https://github.com/JamyJones/termux-packages/releases/download/33.0.0/mupdf-static_1.24.10_arm.deb"
curl -LO "https://github.com/JamyJones/termux-packages/releases/download/33.0.0/mupdf_1.24.10_arm.deb"
dpkg -x mupdf-static_1.24.10_arm.deb mupdf-static
dpkg -x mupdf_1.24.10_arm.deb mupdf-static
cp -r mupdf-static/data/data/com.termux/files/usr/* $TERMUX_PREFIX

