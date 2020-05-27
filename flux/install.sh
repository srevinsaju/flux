#!/bin/bash

ROOT_UID=0

echo "d88888b db      db    db db    db"
echo "88      88      88    88  8b  d8"
echo "88ooo   88      88    88   8bd8 "
echo "88      88      88    88   dPYb "
echo "88      88booo. 88b  d88 .8P  Y8."
echo "YP      Y88888P ~Y8888P  YP    YP"
echo "================================="
echo "copyleft @srevinsaju 2020"
echo "================================="
# Destination directory
if [ "$UID" -eq "$ROOT_UID" ]; then
  DEST_DIR="/usr/share"
else
  DEST_DIR="$HOME/.local/share"
fi

rm -r $DEST_DIR/aurorae/themes/FluxDark || true
mkdir -p $DEST_DIR/aurorae/themes/FluxDark
cp -r ./Flux/* $DEST_DIR/aurorae/themes/FluxDark/.


rm -r $DEST_DIR/plasma/desktoptheme/FluxDark || true
rm -r $DEST_DIR/plasma/look-and-feel/FluxDark || true

mkdir -p $DEST_DIR/plasma/desktoptheme/FluxDark
mkdir -p $DEST_DIR/plasma/look-and-feel/FluxDark
cp -r ./flux_DS/* $DEST_DIR/plasma/desktoptheme/FluxDark/.
cp -r ./flux_LF/* $DEST_DIR/plasma/look-and-feel/FluxDark/.
echo "Done"

