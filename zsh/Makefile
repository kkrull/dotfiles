#. ==dotfiles/zsh==

## Project

.PHONY: default
default: all

include ../make.d/help.mk

## Project

## Sources

srcdir := $(abspath .)

.PHONY: debug-sources
debug-sources:
	$(info Sources:)
	$(info - srcdir: $(srcdir))
	@:

## Artifacts

## Paths

env_dest := $(HOME)/.zshenv

.PHONY: debug-paths
debug-paths:
	$(info Paths:)
	$(info - env_dest: $(env_dest))
	@:

## Programs

#. DEVELOPMENT ENVIRONMENT TARGETS

.PHONY: install-tools
install-tools:
	@:

#. STANDARD TARGETS

.PHONY: all
all:
	@:

.PHONY: clean
clean:
	@:

# TODO KDK: Use `install` to install symlinks in $XDG_CONFIG_HOME or $HOME/.config
.PHONY: install
install: #> Install configuration
	$(file >$(env_dest),ZDOTDIR=$(srcdir))
	$(file >>$(env_dest),source $$ZDOTDIR/.zshenv)
	@echo Created $(env_dest)

.PHONY: test
test:
	@:

.PHONY: uninstall
uninstall: #> Uninstall configuration
	rm -f "$(env_dest)"

#. SUPPORT TARGETS

.PHONY: debug
.NOTPARALLEL: debug
debug: _debug-prefix debug-paths debug-sources #> Show debugging information
	@:

.PHONY: _debug-prefix
_debug-prefix:
	$(info ==dotfiles/zsh==)
	@:
