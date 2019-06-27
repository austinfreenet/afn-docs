MARKDOWN=$(wildcard *.md)
HTML=$(MARKDOWN:%.md=%.html)

all: $(HTML)

%.html: %.md
	pandoc -i $< -o $@

clean:
	rm -f $(HTML)
