## Top-level tasks

default: install

## tmux

CONF_LINK := $(HOME)/.tmux.conf
CONF_LINK_BACKUP := $(CONF_LINK).orig
CONF_TARGET := $(shell git rev-parse --show-toplevel)/tmux/tmux.conf

.PHONY: install
install:
	rm -f "$(CONF_LINK_BACKUP)"
	[ ! -f "$(CONF_LINK)" ] || mv "$(CONF_LINK)" "$(CONF_LINK_BACKUP)"
	ln -s "$(CONF_TARGET)" "$(CONF_LINK)"

.PHONY: uninstall
uninstall:
	rm -f "$(CONF_LINK)"
