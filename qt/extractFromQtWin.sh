#!/bin/bash

set -e

#-------------------------------------------------------------------------------------------------

if [ ! -f "$1/bin/Qt5Core.dll" ]; then
	echo "* extractFromQtWin.sh: \"qtbase\" path not provided"
	echo "*     Usage: ./extractFromQtWin.sh /path/to/qt/qtbase"
	exit 1
fi

echo "extractFromQtWin.sh: \"qtbase\" path: $1"

#-------------------------------------------------------------------------------------------------

rm -rf lib
rm -rf bin
mkdir -p "lib"
mkdir -p "bin"
mkdir -p "bin/sqldrivers"

rm -f "qt.conf"
echo $'[Paths]\nPlugins = .' > "qt.conf"

#-------------------------------------------------------------------------------------------------

cp "$1/bin/moc.exe" "bin"

cp "$1/lib/Qt5Core.lib"    "lib"
cp "$1/lib/Qt5Network.lib" "lib"
cp "$1/lib/Qt5Sql.lib"     "lib"
cp "$1/lib/qtmain.lib"     "lib"

cp "$1/bin/Qt5Core.dll"    "bin"
cp "$1/bin/Qt5Network.dll" "bin"
cp "$1/bin/Qt5Sql.dll"     "bin"

cp "$1/plugins/sqldrivers/qsqlite.dll" "bin/sqldrivers"

#-------------------------------------------------------------------------------------------------

echo "extractFromQtWin.sh: done"
