# Project

.PHONY: default
default: all

## Environment

### Paths

ENV_FILE := $(HOME)/.zshenv

### Programs

### Sources

RC_PATH := $(shell git rev-parse --show-toplevel)/zsh

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
	$(file >$(ENV_FILE),ZDOTDIR=$(RC_PATH))
	$(file >>$(ENV_FILE),source $$ZDOTDIR/.zshenv)
	@echo Created $(ENV_FILE)

.PHONY: uninstall
uninstall: #> Uninstall configuration
	rm -f "$(ENV_FILE)"

#. OTHER TARGETS

# https://stackoverflow.com/a/47107132/112682
.PHONY: help
help: #> Show this help
	@sed -n \
		-e '/@sed/!s/#[.] */_margin_\n/p' \
		-e '/@sed/!s/:.*#> /:/p' \
		$(MAKEFILE_LIST) \
	| column -ts : | sed -e 's/_margin_//'
