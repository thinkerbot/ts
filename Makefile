# Builds the ts man pages.
manpages:
	. ./bin/ts; make man/man1/ts.1 VERSION=$$ts_version DATE=$$ts_release_date

ronn/bin/ronn:
	if ! [ -d ronn ]; then git clone git://github.com/thinkerbot/ronn.git; fi

man/man1/ts.1: README.md ronn/bin/ronn
	mkdir -p man/man1
	ruby -Ironn/lib ronn/bin/ronn -r --pipe --organization="$(VERSION)" --date="$(DATE)" $< > $@
