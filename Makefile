PREFIX ?= /usr/local
BINDIR = $(PREFIX)/bin
SHRDIR = $(PREFIX)/share/em
BASHCOMPDIR = /etc/bash_completion.d

install:
	# 755 is default
	install -D -m 755 em "$(DESTDIR)$(BINDIR)"/em
	install -D -m 755 exp.conf "$(DESTDIR)$(SHRDIR)"/exp.conf
	install -D -m 755 em_completion "$(BASHCOMPDIR)"/em

uninstall:
	rm -f "$(DESTDIR)$(BINDIR)"/em
	rm -f "$(DESTDIR)$(SHRDIR)"
	rm -f "$(BASHCOMPDIR)"/em
