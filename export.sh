#!/usr/bin/sh

LAYERS=$(xmlstarlet sel -t -v "//svg:g[@inkscape:groupmode = 'layer']/@id" bunne.svg)

mkdir -p ./export/trimmed
mkdir -p ./export/squared

for layer in $LAYERS
do
    inkscape --export-id $layer --export-filename=export/trimmed/$layer.png --export-overwrite --export-id-only bunne.svg
    inkscape --export-id $layer --export-filename=export/squared/$layer.png --export-overwrite --export-id-only --export-area=-35:-35:291:291 bunne.svg
done