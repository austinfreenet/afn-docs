MARKDOWN=$(wildcard *.md)
HTML=$(MARKDOWN:%.md=%.html)

all: $(HTML)

%.html: %.md
	markdown $< > $@

publish:
	rsync -av $(HTML) hw:/var/www/fattuba.com/afn/

clean:
	rm -f $(HTML)
