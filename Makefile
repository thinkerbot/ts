# Builds the ts man pages.
manpages:
	. ts; make man/man1/ts.1 VERSION=$$ts_version DATE=$$ts_release_date

ronn/bin/ronn:
	if ! [ -d ronn ]; then git clone git://github.com/thinkerbot/ronn.git; fi

man/man1/ts.1: README.md ronn/bin/ronn
	mkdir -p man/man1
	ruby -Ironn/lib ronn/bin/ronn -r --pipe --organization="$(VERSION)" --date="$(DATE)" $< > $@

/bin/sh.bak:
	sudo cp /bin/sh /bin/sh.bak

sh: /bin/sh.bak
	sudo cp /bin/sh.bak /bin/sh

bash: /bin/sh.bak
	sudo cp $$(command -v bash) /bin/sh

dash: /bin/sh.bak
	sudo cp $$(command -v dash) /bin/sh

zsh: /bin/sh.bak
	sudo cp $$(command -v zsh) /bin/sh

csh: /bin/sh.bak
	sudo cp $$(command -v csh) /bin/sh

ksh: /bin/sh.bak
	sudo cp $$(command -v ksh) /bin/sh
