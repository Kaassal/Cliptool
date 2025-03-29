PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin

install:
	# Check for xclip
	@which xclip >/dev/null 2>&1 || ( \
        echo "Installing xclip..."; \
        sudo apt install -y xclip \
    )
    
    	# Install ct as standalone script
	@install -Dm755 src/ct.py $(DESTDIR)$(BINDIR)/ct
	@echo "Installed to $(BINDIR)/ct"

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/ct

test:
	bats tests/test_functionality.sh

.PHONY: install uninstall test