# Options:
# --future - publish posts with future dates
# -V - show verbose build log

.PHONY: genimages clean

all: test

test: Gemfile
	bundle exec jekyll serve -H 127.0.0.1 -P 8080 -V --future

show: Gemfile
	bundle exec jekyll serve -H $(shell hostname) -P 8080 -V --future

build: Gemfile
	bundle exec jekyll build -V --future

public: build
	rsync -r --delete-after _site/ getalt:/var/www/vhosts/getalt.org/

# Generate YAML files with image lists grouped by solution. This
# thing is written in Ruby to better integrate with Jekyll-based
# infrastructure.
genimg:
	ruby scripts/genimg.rb

clean:
	git clean -fdx

