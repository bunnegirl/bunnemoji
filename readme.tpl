# { emojiset.name }

a set of emoji based on <a href="https://www.feuerfuchs.dev/en/projects/bunhd-emojis/">bunhd by feuerfuchs</a>.

you will find two versions of these emojis, trimmed which works well with discord and squared which works well with misskey. you may need to try both to get the best experience for your software.

this project was built using <a href="https://github.com/bunnegirl/emoji-crafter">emoji crafter</a>.


## the emoji

| Emoji | Name |
| --- | --- |
{{ for emoji in emojis }}| <img width="48" height="48" src="https://github.com/bunnegirl/bunnemoji/blob/master/original/bunne/bunne{emoji.name}.png"> | `:bunne{emoji.name}:` |
{{ endfor }}

## themes

aside from the bunne theme, additional themes are available, {{ for theme in themes }}{{ if not @first }}{theme.name}{{ if not @last}} and {{ endif}}{{ endif }}{{ endfor }}.
