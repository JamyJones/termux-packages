#!/bin/bash

set -e -u

: "${TERMUX_PKG_TMPDIR:="/tmp"}"

# Install desired parts of the Android SDK:
. $(cd "$(dirname "$0")"; pwd)/properties.sh
TERMUX_SDK_REVISION=9123335
TERMUX_NDK_VERSION="27c"
ANDROID_SDK_FILE=commandlinetools-linux-${TERMUX_SDK_REVISION}_latest.zip
ANDROID_SDK_SHA256=0bebf59339eaa534f4217f8aa0972d14dc49e7207be225511073c661ae01da0a
if [ "$TERMUX_NDK_VERSION" = "27c" ]; then
	ANDROID_NDK_FILE=android-ndk-r${TERMUX_NDK_VERSION}-linux.zip
	ANDROID_NDK_SHA256=59c2f6dc96743b5daf5d1626684640b20a6bd2b1d85b13156b90333741bad5cc
elif [ "$TERMUX_NDK_VERSION" = 23c ]; then
	ANDROID_NDK_FILE=android-ndk-r${TERMUX_NDK_VERSION}-linux.zip
	ANDROID_NDK_SHA256=6ce94604b77d28113ecd588d425363624a5228d9662450c48d2e4053f8039242
else
	echo "ERROR: unknown NDK version $TERMUX_NDK_VERSION" >&2
	exit 1
fi

if [ ! -d "$ANDROID_HOME" ]; then
	mkdir -p "$ANDROID_HOME"
	cd "$ANDROID_HOME/.."
	rm -Rf "$(basename "$ANDROID_HOME")"

	# https://developer.android.com/studio/index.html#command-tools
	echo "Downloading Android SDK..."
	curl -L --fail --retry 3  https://dl.google.com/android/repository/${ANDROID_SDK_FILE} \
		-o tools-$TERMUX_SDK_REVISION.zip
	echo "$ANDROID_SDK_SHA256 tools-$TERMUX_SDK_REVISION.zip
" | sha256sum  -c -
	rm -Rf android-sdk-$TERMUX_SDK_REVISION
	unzip -q tools-$TERMUX_SDK_REVISION.zip -d ./android-sdk
fi

if [ ! -d "$NDK" ]; then
	mkdir -p "$NDK"
	cd "$NDK/.."
	rm -Rf "$(basename "$NDK")"

	# https://developer.android.com/ndk/downloads
	echo "Downloading Android NDK..."
	curl -L --fail --retry 3 https://dl.google.com/android/repository/${ANDROID_NDK_FILE} \
		-o ndk-r${TERMUX_NDK_VERSION}.zip
		echo "$ANDROID_NDK_SHA256 ndk-r${TERMUX_NDK_VERSION}.zip" | sha256sum -c -
	rm -Rf android-ndk-r$TERMUX_NDK_VERSION
	unzip -q ndk-r${TERMUX_NDK_VERSION}.zip -d ./android-ndk
  cd android-ndk
  cp -r android-ndk-r27c/* .
  rm -Rf android-ndk-r27c
  cd -

	# Remove unused parts
	rm -Rf ./sources/cxx-stl/system
fi
export SDK_MANAGER="$ANDROID_HOME/cmdline-tools/bin/sdkmanager"
export NDK=$NDK

echo "INFO: Using sdkmanager ... $SDK_MANAGER"
echo "INFO: Using NDK ... $NDK"

yes | $SDK_MANAGER --sdk_root="$ANDROID_HOME" --licenses

# The android platforms are used in the ecj and apksigner packages:
yes | $SDK_MANAGER --sdk_root="$ANDROID_HOME" \
		"platform-tools" \
		"build-tools;${TERMUX_ANDROID_BUILD_TOOLS_VERSION}" \
		"platforms;android-23"
