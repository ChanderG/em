PREFIX ?= /usr/local
BINDIR = $(PREFIX)/bin
SHRDIR = $(PREFIX)/share/em

install:
	# 755 is default
	install -D -m 755 em "$(DESTDIR)$(BINDIR)"/em
	install -D -m 755 exp.conf "$(DESTDIR)$(SHRDIR)"/exp.conf

uninstall:
	rm -f "$(DESTDIR)$(BINDIR)"/em
	rm -f "$(DESTDIR)$(SHRDIR)"
