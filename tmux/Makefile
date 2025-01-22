# Project

.PHONY: default
default: all

## Environment

### Paths

CONF_LINK := $(HOME)/.tmux.conf
CONF_LINK_BACKUP := $(CONF_LINK).orig

### Programs

### Sources

CONF_TARGET := $(shell git rev-parse --show-toplevel)/tmux/tmux.conf

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
	rm -f "$(CONF_LINK_BACKUP)"
	[ ! -f "$(CONF_LINK)" ] || mv "$(CONF_LINK)" "$(CONF_LINK_BACKUP)"
	ln -s "$(CONF_TARGET)" "$(CONF_LINK)"

.PHONY: uninstall
uninstall: #> Uninstall configuration
	rm -f "$(CONF_LINK)"

#. OTHER TARGETS

# https://stackoverflow.com/a/47107132/112682
.PHONY: help
help: #> Show this help
	@sed -n \
		-e '/@sed/!s/#[.] */_margin_\n/p' \
		-e '/@sed/!s/:.*#> /:/p' \
		$(MAKEFILE_LIST) \
	| column -ts : | sed -e 's/_margin_//'
