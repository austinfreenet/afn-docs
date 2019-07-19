MARKDOWN=$(wildcard *.md)
HTML=$(MARKDOWN:%.md=%.html)

all: $(HTML)

%.html: %.md
	TITLE=$$(head $< | grep "^# " | sed 's/# //'); \
	pandoc -fgfm --metadata=pagetitle:"$$TITLE" --standalone -i $< -o $@

clean:
	rm -f $(HTML)
