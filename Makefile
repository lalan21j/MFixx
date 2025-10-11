# -*- makefile-gmake -*-
svg := $(wildcard svg/*.svg)
charmap := charmap.md

# Header template for generated HTML files
define html-header
<!DOCTYPE html>\
<html lang="en-AU">\
<head>\
<meta charset="utf-8"/>\
<meta name="viewport" content="initial-scale=1, minimum-scale=1"/>\
<meta name="color-scheme" content="light dark"/>\
<title>README</title>\
</head><body>
endef

# Clean that source code up
.PHONY: lint
lint: $(svg)
	dos2unix --keepdate --quiet $^
	perl -0777 -pi -e '\
		s/\s+(id|viewBox|xml:space)="[^"]*"/ /gmi; \
		s/<\?xml.*?\?>//gi; \
		s/<!--.*?-->//gm; \
		s/ style="enable-background:.*?;"//gmi; \
		s/"\s+>/">/g; \
		s/\x20{2,}/ /g; \
		s/[\t\n]+//gm;' $^

.PHONY: reset
reset:
	@git checkout -- svg/


# Convert each SVG's filename to lowercase
.PHONY: downcase
downcase: $(svg)
	@f=($(svg)); for i in "$${f[@]}"; do d=$$(echo "$$i" | tr '[A-Z]' '[a-z]'); mv "$$i" "$$d"; done


# Generate an HTML preview of readme file
README.html: README.md
	@ printf > $@ %s '$(html-header)' | sed 's/> \{1,\}</>\n</g'
	exts=`cmark-gfm --list-extensions \
	| grep -iFv 'Available extensions:' \
	| gsed ':a; 1 s/^/-e /; $! { N; s/\n/ -e /g; ba; }'`; \
	cmark-gfm --unsafe $$exts $^ >> $@
	@ printf >> $@ '%s\n' '</body></html>'


# Delete generated files
.PHONY: clean
clean:
	rm -f README.html
