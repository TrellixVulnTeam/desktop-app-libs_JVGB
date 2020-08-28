#!/bin/bash

set -e

NAME="$1"
VERSION="$2"

if [ "$NAME" = "" ]
then
	echo
	echo "usage:"
	echo "$ downloadNpmModule.sh <name>"
	echo "$ downloadNpmModule.sh <name> <version>"
	echo
	exit 1
fi

if [ "$VERSION" = "" ]
then
	VERSION="latest"
fi

echo "downloadNpmModule.sh: name: \"$NAME\", version: \"$VERSION\""

mkdir -p "$NAME"
pushd "$NAME"

mkdir -p "tmp"
rm -rf "tmp/*"
pushd "tmp"

echo "downloadNpmModule.sh: installing NPM module"
npm  --save-exact --no-bin-links --ignore-scripts install "$NAME@$VERSION"

for DIFF_FILE in ../*.diff
do
	if [[ -f "$DIFF_FILE" ]]
	then
		echo "downloadNpmModule.sh: applying patch: $DIFF_FILE"
		patch -p0 < "$DIFF_FILE"
	fi
done

if [ -x "$(command -v diarrhea)" ]
then
	echo "downloadNpmModule.sh: pruning NPM modules"
	yes | diarrhea --verbose --ignore "*/binding.gyp"
fi

if [ "$VERSION" = "latest" ]
then
	VERSION=$(node -e "console.log(require('./package-lock.json').dependencies['$NAME'].version);")
	if [ "$VERSION" = "" ]
	then
		echo "downloadNpmModule.sh: failed to read version from \"package-lock.json\""
		exit 1
	fi
	echo "downloadNpmModule.sh: resolved version: \"$VERSION\""
fi

popd

rm -rf "$VERSION"
mv "tmp" "$VERSION"

popd

echo "downloadNpmModule.sh: done"
