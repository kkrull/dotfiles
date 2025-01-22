# Project

.PHONY: default
default: all

## Environment

### Paths

CONF_LINK := $(HOME)/.gitconfig
CONF_LINK_BACKUP := $(CONF_LINK).orig

IGNORE_LINK := $(HOME)/.gitignore
IGNORE_LINK_BACKUP := $(IGNORE_LINK).orig

### Programs

### Sources

SRC := $(shell git rev-parse --show-toplevel)/git
CONF_TARGET := $(SRC)/gitconfig
IGNORE_TARGET := $(SRC)/gitignore

#. STANDARD TARGETS

.PHONY: all
all: #> Build all sources (if any)
	@:

.PHONY: check
check: #> Run self-tests
	@:

.PHONY: clean
clean: #> Remove local build files (if any)
	@:

.PHONY: install
install: #> Install configuration
	rm -f "$(CONF_LINK_BACKUP)" "$(IGNORE_LINK_BACKUP)"

	[ ! -f "$(CONF_LINK)" ] || mv "$(CONF_LINK)" "$(CONF_LINK_BACKUP)"
	ln -s "$(CONF_TARGET)" "$(CONF_LINK)"

	[ ! -f "$(IGNORE_LINK)" ] || mv "$(IGNORE_LINK)" "$(IGNORE_LINK_BACKUP)"
	ln -s "$(IGNORE_TARGET)" "$(IGNORE_LINK)"

.PHONY: uninstall
uninstall: #> Uninstall configuration
	rm -f "$(CONF_LINK)" "$(IGNORE_LINK)"

#. OTHER TARGETS

# https://stackoverflow.com/a/47107132/112682
.PHONY: help
help: #> Show this help
	@sed -n \
		-e '/@sed/!s/#[.] */_margin_\n/p' \
		-e '/@sed/!s/:.*#> /:/p' \
		$(MAKEFILE_LIST) \
	| column -ts : | sed -e 's/_margin_//'
