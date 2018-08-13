home: data.json index.mustache media
	mustache data.json index.mustache > index.html
media:
	mustache media.json media.mustache > media.html
.PHONY: media home
