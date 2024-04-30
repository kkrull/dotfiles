## Top-level tasks

default: install

## git

CONF_LINK := $(HOME)/.gitconfig
CONF_LINK_BACKUP := $(CONF_LINK).orig
CONF_TARGET := $(shell git rev-parse --show-toplevel)/git/gitconfig

IGNORE_LINK := $(HOME)/.gitignore
IGNORE_LINK_BACKUP := $(IGNORE_LINK).orig
IGNORE_TARGET := $(shell git rev-parse --show-toplevel)/git/gitignore

.PHONY: install
install:
	rm -f "$(CONF_LINK_BACKUP)" "$(IGNORE_LINK_BACKUP)"

	[ ! -f "$(CONF_LINK)" ] || mv "$(CONF_LINK)" "$(CONF_LINK_BACKUP)"
	ln -s "$(CONF_TARGET)" "$(CONF_LINK)"

	[ ! -f "$(IGNORE_LINK)" ] || mv "$(IGNORE_LINK)" "$(IGNORE_LINK_BACKUP)"
	ln -s "$(IGNORE_TARGET)" "$(IGNORE_LINK)"

.PHONY: remove
remove:
	rm -f "$(CONF_LINK)" "$(IGNORE_LINK)"
