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

    echo "emoji $emoji:"

    # Export animated emoji
    if [[ $is_animated == "true" ]]
    then
        FRAMES=$(xmlstarlet sel -t -v "//svg:g[@inkscape:label = '$emoji']/svg:g/@id" ./bunne.svg)
        FRAME=0

        # Export each frame
        for frame in $FRAMES
        do
            ((FRAME++))

            echo " - exporting frame $FRAME"

            inkscape --export-id $frame --export-filename=./frames/$emoji-$FRAME.png --export-overwrite --export-id-only --export-area=-35:-35:291:291 ./bunne.svg &> /dev/null
        done

        echo " - exporting as webp"

        # Export squared webp
        ffmpeg -y -r 12 -f image2 -s 326x326 -i ./frames/$emoji-%d.png -plays 0 ./squared/$emoji.webp &> /dev/null

        # Export trimmed webp
        convert squared/$emoji.webp -coalesce -trim -layers TrimBounds ./trimmed/$emoji.webp &> /dev/null

        echo " - exporting as gif"

        # Export squared gif
        ffmpeg -y -i ./frames/$emoji-%d.png -vf palettegen=reserve_transparent=1 ./frames/$emoji-palette.png &> /dev/null
        ffmpeg -y -r 12 -i ./frames/$emoji-%d.png -i ./frames/$emoji-palette.png -lavfi paletteuse=alpha_threshold=128 -gifflags -offsetting ./squared/$emoji.gif &> /dev/null

        # Export trimmed gif
        convert squared/$emoji.gif -coalesce -trim -layers TrimBounds ./trimmed/$emoji.gif &> /dev/null

        # Add emoji to readme
        echo "| <img width=\"48\" height=\"48\" src=\"$EMOJI_URL/squared/$emoji.webp\"> | \`:$emoji:\` |" >> readme.md

    # Export static emoji
    else
        id=$(xmlstarlet sel -t -v "//svg:g[@inkscape:label = '$emoji']/@id" ./bunne.svg)

        echo " - exporting as png"

        # Export squared png
        inkscape --export-id $id --export-filename=./squared/$emoji.png --export-overwrite --export-id-only --export-area=-35:-35:291:291 ./bunne.svg &> /dev/null

        # Export trimmed png
        convert squared/$emoji.png -coalesce -trim -layers TrimBounds ./trimmed/$emoji.png &> /dev/null

        # Add emoji to readme
        echo "| <img width=\"48\" height=\"48\" src=\"$EMOJI_URL/squared/$emoji.png\"> | \`:$emoji:\` |" >> readme.md
    fi
done