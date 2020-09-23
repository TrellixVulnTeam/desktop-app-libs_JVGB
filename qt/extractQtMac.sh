#!/bin/bash

set -e

#-------------------------------------------------------------------------------------------------

if [ ! -d "$1/lib/QtCore.framework" ]; then
	echo "* extractQtMac.sh: \"qtbase\" path not provided"
	echo "*     Usage: ./extractQtMac.sh /path/to/qt/qtbase"
	exit 1
fi

echo "extractQtMac.sh: \"qtbase\" path: $1"

#-------------------------------------------------------------------------------------------------

rm -rf lib
rm -rf bin
mkdir -p "lib"
mkdir -p "lib/sqldrivers"
mkdir -p "bin"

rm -f "qt.conf"
echo $'[Paths]\nPlugins = Frameworks' > "qt.conf"

#-------------------------------------------------------------------------------------------------

cp "$1/bin/moc" "bin"
chmod +x "bin/moc"

pushd "lib"

cp "$1/lib/QtCore.framework/Versions/5/QtCore"       "libQt5Core.dylib"
cp "$1/lib/QtNetwork.framework/Versions/5/QtNetwork" "libQt5Network.dylib"
cp "$1/lib/QtSql.framework/Versions/5/QtSql"         "libQt5Sql.dylib"

install_name_tool -id "@rpath/libQt5Core.dylib"    "libQt5Core.dylib"
install_name_tool -id "@rpath/libQt5Network.dylib" "libQt5Network.dylib"
install_name_tool -id "@rpath/libQt5Sql.dylib"     "libQt5Sql.dylib"

install_name_tool -change "@rpath/QtCore.framework/Versions/5/QtCore" "@rpath/libQt5Core.dylib" "libQt5Network.dylib"
install_name_tool -change "@rpath/QtCore.framework/Versions/5/QtCore" "@rpath/libQt5Core.dylib" "libQt5Sql.dylib"

chmod +x *.dylib
otool -L *.dylib

popd

pushd "lib/sqldrivers"

cp "$1/plugins/sqldrivers/libqsqlite.dylib" "libqsqlite.dylib"

install_name_tool -change "@rpath/QtCore.framework/Versions/5/QtCore" "@rpath/libQt5Core.dylib" "libqsqlite.dylib"
install_name_tool -change "@rpath/QtSql.framework/Versions/5/QtSql"   "@rpath/libQt5Sql.dylib"  "libqsqlite.dylib"

chmod +x *.dylib
otool -L *.dylib

popd

#-------------------------------------------------------------------------------------------------

echo "extractQtMac.sh: done"
