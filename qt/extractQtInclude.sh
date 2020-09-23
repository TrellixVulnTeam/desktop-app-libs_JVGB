#!/bin/bash

set -e

#-------------------------------------------------------------------------------------------------

if [ ! -d "$1/include" ]; then
	echo "* extractQtInclude.sh: \"qtbase\" path not provided"
	echo "*     Usage: ./extractQtInclude.sh /path/to/qt/qtbase"
	exit 1
fi

echo "extractQtInclude.sh: \"qtbase\" path: $1"

#-------------------------------------------------------------------------------------------------

rm -rf include
mkdir -p "include"

cp -r "$1/include/QtCore"    "include"
cp -r "$1/include/QtNetwork" "include"
cp -r "$1/include/QtSql"     "include"

#-------------------------------------------------------------------------------------------------

echo "extractQtInclude.sh: done"
