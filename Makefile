CC=pandoc -s --highlight-style pygments \
		--data-dir=include --template=bhee \
		--title-prefix "Bheesham Persaud" \
		--mathjax

T=include/templates/bhee.html

WEB_SOURCE_DIRS:=$(shell find src/web -type d)
WEB_OUT_DIRS:=$(basename $(patsubst src/web/%,build/%,$(WEB_SOURCE_DIRS)))

WEB_SOURCE_FILES:=$(shell find src/web -type f)
WEB_OUT_FILES:=$(addsuffix .html,$(basename $(patsubst src/web/%,build/%,$(WEB_SOURCE_FILES))))

RES_SOURCE_FILES:=$(wildcard src/resume/*.sty) src/resume/main.tex

STATIC_SOURCE_FILES:=$(shell find include/static -type f)
STATIC_OUT_FILES:=$(patsubst include/static/%,build/%,$(STATIC_SOURCE_FILES))

default: website resume

website: $(WEB_OUT_FILES) $(STATIC_OUT_FILES)

resume: build/bheesham-persaud.pdf

build/bheesham-persaud.pdf: $(RES_SOURCE_FILES)
	cd src/resume; pdflatex main.tex
	cd src/resume; rm main.aux main.log main.out
	mv src/resume/main.pdf build/bheesham-persaud.pdf

$(STATIC_OUT_FILES): $(STATIC_SOURCE_FILES)
	cp -rf include/static/* build/

$(WEB_OUT_FILES): $(WEB_SOURCE_FILES)

build/%.html:: src/web/%.md $(T) $(WEB_OUT_DIRS)
	$(CC) $< -o $@

build/%.html:: src/web/%.org $(T) $(WEB_OUT_DIRS)
	$(CC) $< -o $@

build/%.html:: src/web/%.tex $(T) $(WEB_OUT_DIRS)
	$(CC) $< -o $@

$(WEB_OUT_DIRS):
	mkdir -p $@

scp:
	rsync -rvhmc --delete-excluded --del build/ bheesham.com:/srv/bheesham/

spell: $(RES_SOURCE_FILES)
	aspell -c -t src/resume/main.tex

clean:
	rm -rf build/*

.PHONY: clean default website resume scp spell
