#!/usr/bin/sh

EMOJI_URL="https://github.com/bunnegirl/bunnemoji/blob/master"
EMOJI=$(xmlstarlet sel -t -v "/svg:svg/svg:g[@inkscape:groupmode = 'layer']/@inkscape:label" ./bunne.svg)

mkdir -p ./frames
mkdir -p ./trimmed
mkdir -p ./squared
rm readme.md
cp readme.tpl readme.md
echo "" >> readme.md

for emoji in $(sort <<<"${EMOJI[*]}")
do
    is_animated=$(xmlstarlet sel -t -v "boolean(/svg:svg/svg:g[@inkscape:label = '$emoji' and .//svg:g[@inkscape:groupmode = 'layer']])" ./bunne.svg)

    # Export animated emoji
    if [[ $is_animated == "true" ]]
    then
        FRAMES=$(xmlstarlet sel -t -v "//svg:g[@inkscape:label = '$emoji']/svg:g/@id" ./bunne.svg)
        FRAME=0

        # Export each frame
        for frame in $FRAMES
        do
            ((FRAME++))

            inkscape --export-id $frame --export-filename=./frames/$emoji-$FRAME.png --export-overwrite --export-id-only --export-area=-35:-35:291:291 ./bunne.svg
        done

        # Export squared webp
        ffmpeg -y -r 12 -f image2 -s 326x326 -i ./frames/$emoji-%d.png -plays 0 ./squared/$emoji.webp

        # Export trimmed webp
        convert squared/$emoji.webp -coalesce -trim -layers TrimBounds ./trimmed/$emoji.webp

        # Export squared gif
        ffmpeg -y -i ./frames/$emoji-%d.png -vf palettegen=reserve_transparent=1 ./frames/$emoji-palette.png
        ffmpeg -y -r 12 -i ./frames/$emoji-%d.png -i ./frames/$emoji-palette.png -lavfi paletteuse=alpha_threshold=128 -gifflags -offsetting ./squared/$emoji.gif

        # Export trimmed gif
        convert squared/$emoji.gif -coalesce -trim -layers TrimBounds ./trimmed/$emoji.gif

        # Add emoji to readme
        echo "| <img width=\"48\" height=\"48\" src=\"$EMOJI_URL/squared/$emoji.webp\"> | \`:$emoji:\` |" >> readme.md

    # Export static emoji
    else
        id=$(xmlstarlet sel -t -v "//svg:g[@inkscape:label = '$emoji']/@id" ./bunne.svg)

        # Export squared png
        inkscape --export-id $id --export-filename=./squared/$emoji.png --export-overwrite --export-id-only --export-area=-35:-35:291:291 ./bunne.svg

        # Export trimmed png
        convert squared/$emoji.png -coalesce -trim -layers TrimBounds ./trimmed/$emoji.png

        # Add emoji to readme
        echo "| <img width=\"48\" height=\"48\" src=\"$EMOJI_URL/squared/$emoji.png\"> | \`:$emoji:\` |" >> readme.md
    fi
done