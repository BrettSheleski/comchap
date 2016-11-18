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
	rm -f $(PKG) $(SIG)

all: $(PKG) $(SIG)

test:

tag:
	git tag v$(VERSION)
	git push --tags

release: $(PKG) $(SIG) tag

install: 
	for dir in $(INSTALL_DIRS); do mkdir -p $(PREFIX)/lib/$(NAME)/$$dir; done
	for file in $(INSTALL_FILES); do cp $$file $(PREFIX)/lib/$(NAME)/$$file; done
	mkdir -p $(DOC_DIR)
	cp -r $(DOC_FILES) $(DOC_DIR)/
	ln -s $(PREFIX)/lib/$(NAME)/comchap $(PREFIX)/bin
	ln -s $(PREFIX)/lib/$(NAME)/comcut $(PREFIX)/bin

uninstall:
	for file in $(INSTALL_FILES); do rm -f $(PREFIX)/$$file; done
	rm -rf $(DOC_DIR)
	rm -f $(PREFIX)/bin/comchap $(PREFIX)/bin/comcut


.PHONY: build sign clean test tag release install uninstall all
