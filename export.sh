#!/usr/bin/sh

STATIC=$(xmlstarlet sel -t -v "/svg:svg/svg:g[@inkscape:groupmode = 'layer' and not(.//svg:g[@inkscape:groupmode = 'layer'])]/@inkscape:label" bunne.svg)
ANIMATED=$(xmlstarlet sel -t -v "/svg:svg/svg:g[@inkscape:groupmode = 'layer' and .//svg:g[@inkscape:groupmode = 'layer']]/@inkscape:label" bunne.svg)

mkdir -p ./export/frames
mkdir -p ./export/trimmed
mkdir -p ./export/squared

for emoji in $STATIC
do
    # Export squared png
    inkscape --export-id $emoji --export-filename=export/squared/$emoji.png --export-overwrite --export-id-only --export-area=-35:-35:291:291 bunne.svg

    # Export trimmed png
    convert export/squared/$emoji.png -coalesce -trim -layers TrimBounds ./export/trimmed/$emoji.png
done

for emoji in $ANIMATED
do
    FRAMES=$(xmlstarlet sel -t -v "//svg:g[@inkscape:label = '$emoji']/svg:g/@id" bunne.svg)
    FRAME=0

    # Export each frame
    for frame in $FRAMES
    do
        ((FRAME++))

        inkscape --export-id $frame --export-filename=export/frames/$emoji-$FRAME.png --export-overwrite --export-id-only --export-area=-35:-35:291:291 bunne.svg
    done

    # Export squared webp
    ffmpeg -y -r 12 -f image2 -s 326x326 -i ./export/frames/$emoji-%d.png -plays 0 ./export/squared/$emoji.webp

    # Export trimmed webp
    convert export/squared/$emoji.webp -coalesce -trim -layers TrimBounds ./export/trimmed/$emoji.webp

    # Export squared gif
    ffmpeg -y -i ./export/frames/$emoji-%d.png -vf palettegen=reserve_transparent=1 ./export/frames/$emoji-palette.png
    ffmpeg -y -r 12 -i ./export/frames/$emoji-%d.png -i ./export/frames/$emoji-palette.png -lavfi paletteuse=alpha_threshold=128 -gifflags -offsetting ./export/squared/$emoji.gif

    # Export trimmed gif
    convert export/squared/$emoji.gif -coalesce -trim -layers TrimBounds ./export/trimmed/$emoji.gif
done