#!/usr/bin/sh

LAYERS=$(xmlstarlet sel -t -v "//svg:g[@inkscape:groupmode = 'layer']/@id" bunne.svg)

mkdir -p ./export

for layer in $LAYERS
do
    inkscape --export-id $layer --export-filename=export/$layer.png --export-overwrite --export-id-only bunne.svg
done