# Builds the ts man pages.
#
# For this to work, History.md must have the current version and release date
# on it's first line like:
#
#   version / YYYY-MM-DD
#
manpages:
	. ts; make man/man1/ts.1 VERSION=$$ts_version DATE=$$ts_release_date

ronn/bin/ronn:
	git clone git://github.com/thinkerbot/ronn.git

man/man1/ts.1: README.md History.md ronn/bin/ronn
	mkdir -p man/man1
	ruby -Ironn/lib ronn/bin/ronn -r --pipe --organization="$(VERSION)" --date="$(DATE)" $< > $@
