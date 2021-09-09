#!/usr/bin/sh

EMOJI_URL="https://github.com/bunnegirl/bunnemoji/blob/master"
EMOJI=$(xmlstarlet sel -t -v "/svg:svg/svg:g[@inkscape:groupmode = 'layer']/@inkscape:label" ./bunne.svg)

rm readme.md
cp readme.tpl readme.md
echo "" >> readme.md

for file in ./themes/*.css
do
    theme=$(basename -s .css $file)
    temp_dir="./themes/$theme/tmp"
    squared_dir="./themes/$theme/squared"
    trimmed_dir="./themes/$theme/trimmed"

    mkdir -p $temp_dir
    mkdir -p $squared_dir
    mkdir -p $trimmed_dir

    echo ""
    echo "exporting $theme theme"
    echo ""

    echo "" >> readme.md
    echo "### $theme theme" >> readme.md
    echo "" >> readme.md
    echo "| Emoji | Name |" >> readme.md
    echo "| --- | --- |" >> readme.md

    # Copy the main svg with the current theme css
    sed "s/@import url(themes\/bunne.css);/@import url(..\/..\/$theme.css);/" bunne.svg > $temp_dir/bunne.svg

    for emoji in $(sort <<<"${EMOJI[*]}")
    do
        themoji=$(echo $emoji | sed "s/^bunne/$theme/")

        is_animated=$(xmlstarlet sel -t -v "boolean(/svg:svg/svg:g[@inkscape:label = '$emoji' and .//svg:g[@inkscape:groupmode = 'layer']])" ./bunne.svg)

        echo "emoji $themoji:"

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

                inkscape --export-id $frame --export-filename=$temp_dir/$themoji-$FRAME.png --export-overwrite --export-id-only --export-area=-35:-35:291:291 $temp_dir/bunne.svg &> /dev/null
            done

            echo " - exporting as webp"

            # Export squared webp
            ffmpeg -y -r 12 -f image2 -s 326x326 -i $temp_dir/$themoji-%d.png -plays 0 $squared_dir/$themoji.webp &> /dev/null

            # Export trimmed webp
            convert $squared_dir/$themoji.webp -coalesce -trim -layers TrimBounds $trimmed_dir/$themoji.webp &> /dev/null

            echo " - exporting as gif"

            # Export squared gif
            ffmpeg -y -i $temp_dir/$themoji-%d.png -vf palettegen=reserve_transparent=1 $temp_dir/$themoji-palette.png &> /dev/null
            ffmpeg -y -r 12 -i $temp_dir/$themoji-%d.png -i $temp_dir/$themoji-palette.png -lavfi paletteuse=alpha_threshold=128 -gifflags -offsetting $squared_dir/$themoji.gif &> /dev/null

            # Export trimmed gif
            convert $squared_dir/$themoji.gif -coalesce -trim -layers TrimBounds $trimmed_dir/$themoji.gif &> /dev/null

            # Add emoji to readme
            echo "| <img width=\"48\" height=\"48\" src=\"$EMOJI_URL/themes/$theme/squared/$themoji.webp\"> | \`:$themoji:\` |" >> readme.md

        # Export static emoji
        else
            id=$(xmlstarlet sel -t -v "//svg:g[@inkscape:label = '$emoji']/@id" ./bunne.svg)

            echo " - exporting as png"

            # Export squared png
            inkscape --export-id $id --export-filename=$squared_dir/$themoji.png --export-overwrite --export-id-only --export-area=-35:-35:291:291 $temp_dir/bunne.svg &> /dev/null

            # Export trimmed png
            convert $squared_dir/$themoji.png -coalesce -trim -layers TrimBounds $trimmed_dir/$themoji.png &> /dev/null

            # Add emoji to readme
            echo "| <img width=\"48\" height=\"48\" src=\"$EMOJI_URL/themes/$theme/squared/$themoji.png\"> | \`:$themoji:\` |" >> readme.md
        fi
    done
done
