# { emojiset.name } themes
{{ for theme in themes -}}
## { theme.name } theme

| Emoji | Name |
| --- | --- |
    {{- for emoji in emojis -}}
        {-newline-}
        {{- if emoji.is_animation -}}
            | <img width="48" height="48" src="https://github.com/bunnegirl/bunnemoji/blob/master/original/{ theme.name }/{ theme.prefix }{ emoji.name }.webp"> | `:{ theme.prefix }{ emoji.name }:` |
        {{- else -}}
            | <img width="48" height="48" src="https://github.com/bunnegirl/bunnemoji/blob/master/original/{ theme.name }/{ theme.prefix }{emoji.name}.png"> | `:{ theme.prefix }{ emoji.name }:` |
        {{- endif }}
    {{- endfor -}}
    {{- if not @last -}}
        {-newline-}
        {-newline-}
        {-newline-}
    {{- endif -}}
{{- endfor -}}
