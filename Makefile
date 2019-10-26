# Options:
# --future - publish posts with future dates
# -V - show verbose build log

.PHONY: clean

all: test

test: Gemfile
	bundle exec jekyll serve -H 127.0.0.1 -P 8080 -V --future

build: Gemfile
	bundle exec jekyll build -V --future

public: build
	rsync -r --delete-after _site/ getalt:/var/www/vhosts/getalt.org/

clean:
	git clean -fdx

