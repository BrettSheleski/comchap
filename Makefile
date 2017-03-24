NAME=comchap
VERSION=0.0.1

PKG_DIR=pkg
PKG_NAME=$(NAME)-$(VERSION)
PKG=$(PKG_DIR)/$(PKG_NAME).tar.gz
SIG=$(PKG_DIR)/$(PKG_NAME).asc

INSTALL_DIRS=`find $(PKG_DIR) -type d 2>/dev/null`
INSTALL_FILES=`find $(PKG_DIR) -type f 2>/dev/null`
DOC_FILES=*.md *.txt

PREFIX?=/usr/local
DOC_DIR=$(PREFIX)/share/doc/$(PKG_NAME)

pkg:
	mkdir -p $(PKG_DIR)/lib 
	mkdir -p $(PKG_DIR)/docs
	cp comchap  $(PKG_DIR)/lib
	cp comcut $(PKG_DIR)/lib
	cp $(DOC_FILES) $(PKG_DIR)/docs

$(PKG): pkg
	git archive --output=$(PKG) --prefix=$(PKG_NAME)/ HEAD

build: $(PKG)

$(SIG): $(PKG)
	gpg --sign --detach-sign --armor $(PKG)

sign: $(SIG)

clean:
	rm -Rf $(PKG_DIR)

all: $(PKG) $(SIG)

test:

tag:
	git tag v$(VERSION)
	git push --tags

release: $(PKG) $(SIG) tag

install:
	mkdir -p $(PREFIX)/lib/$(NAME)
	cp -rp $(PKG_DIR)/lib/* $(PREFIX)/lib/$(NAME)
	mkdir -p $(DOC_DIR)
	cp -r $(PKG_DIR)/docs $(DOC_DIR)/
	ln -sf $(PREFIX)/lib/$(NAME)/comchap $(PREFIX)/bin
	ln -sf $(PREFIX)/lib/$(NAME)/comcut $(PREFIX)/bin

uninstall:
	rm -rf $(PREFIX)/lib/$(NAME)
	rm -rf $(DOC_DIR)
	rm -f $(PREFIX)/bin/comchap $(PREFIX)/bin/comcut


.PHONY: build sign clean test tag release install uninstall all
