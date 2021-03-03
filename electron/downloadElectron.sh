#!/bin/bash

set -e

VERSION="$1"

if [ "$VERSION" == "" ]
then
	echo
	echo "usage:"
	echo "$ downloadElectron.sh <version>"
	echo
	exit 1
fi

echo "downloadElectron.sh: version: $VERSION"

ZIP_URLS=(
	"https://github.com/electron/electron/releases/download/v$VERSION/electron-v$VERSION-win32-ia32.zip"
	"https://github.com/electron/electron/releases/download/v$VERSION/electron-v$VERSION-win32-x64.zip"
	"https://github.com/electron/electron/releases/download/v$VERSION/electron-v$VERSION-darwin-x64.zip"
	"https://github.com/electron/electron/releases/download/v$VERSION/electron-v$VERSION-linux-x64.zip"
)

for ZIP_URL in ${ZIP_URLS[*]}
do
	ZIP_NAME="$(basename $ZIP_URL)"

	echo "downloadElectron.sh: downloading: $ZIP_NAME"

	rm -f "$ZIP_NAME"
	curl "$ZIP_URL" -L -o "$ZIP_NAME"

	if [ -f "/usr/bin/xattr" ]
	then
		echo "downloadElectron.sh: removing com.apple.quarantine fs metadata"

		xattr -r -d "com.apple.quarantine" "$ZIP_NAME"
		xattr -r -d "com.apple.metadata:kMDItemWhereFroms" "$ZIP_NAME"
	fi
done

echo "downloadElectron.sh: done"
