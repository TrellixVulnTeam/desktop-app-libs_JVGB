#!/bin/bash

set -e

#-------------------------------------------------------------------------------------------------

if [ ! -d "$1/include" ]; then
	echo "* extractFromQtInclude.sh: \"qtbase\" path not provided"
	echo "*     Usage: ./extractFromQtInclude.sh /path/to/qt/qtbase"
	exit 1
fi

echo "extractFromQtInclude.sh: \"qtbase\" path: $1"

#-------------------------------------------------------------------------------------------------

rm -rf include
mkdir -p "include"

cp -r "$1/include/QtCore"    "include"
cp -r "$1/include/QtNetwork" "include"
cp -r "$1/include/QtSql"     "include"

#-------------------------------------------------------------------------------------------------

echo "extractFromQtInclude.sh: done"
