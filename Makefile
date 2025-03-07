PREFIX ?= /usr/local

install:
        install -Dm755 ct $(DESTDIR)$(PREFIX)/bin/ct

uninstall:
        rm -f $(DESTDIR)$(PREFIX)/bin/ct
