index.html: data.json index.mustache
	mustache data.json index.mustache > index.html