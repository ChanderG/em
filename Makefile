PREFIX ?= /usr/local
BINDIR = $(PREFIX)/bin

install:
	# 755 is default
	install -D -m 755 em "$(DESTDIR)$(BINDIR)"/em

uninstall:
	rm -f "$(DESTDIR)$(BINDIR)"/em
