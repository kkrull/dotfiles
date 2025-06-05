#. ==dotfiles/git==

.PHONY: default
default: all

include ../make.d/help.mk

## Project

## Sources

srcdir := $(abspath .)
conf_source := $(srcdir)/gitconfig
ignore_source := $(srcdir)/gitignore

.PHONY: debug-sources
debug-sources:
	$(info Sources:)
	$(info - srcdir: $(srcdir))
	$(info - conf_source: $(conf_source))
	$(info - ignore_source: $(ignore_source))
	@:

## Artifacts

## Paths

conf_dest := $(HOME)/.gitconfig
conf_backup := $(conf_dest).orig

ignore_dest := $(HOME)/.gitignore
ignore_backup := $(ignore_dest).orig

.PHONY: debug-paths
debug-paths:
	$(info Paths:)
	$(info - conf_backup: $(conf_backup))
	$(info - conf_dest: $(conf_dest))
	$(info - ignore_backup: $(ignore_backup))
	$(info - ignore_dest: $(ignore_dest))
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
	rm -f "$(conf_backup)" "$(ignore_backup)"

	[ ! -f "$(conf_dest)" ] || mv "$(conf_dest)" "$(conf_backup)"
	ln -s "$(conf_source)" "$(conf_dest)"

	[ ! -f "$(ignore_dest)" ] || mv "$(ignore_dest)" "$(ignore_backup)"
	ln -s "$(ignore_source)" "$(ignore_dest)"

.PHONY: test
test:
	@:

.PHONY: uninstall
uninstall: #> Uninstall configuration
	rm -f "$(conf_dest)" "$(ignore_dest)"

#. SUPPORT TARGETS

.PHONY: debug
.NOTPARALLEL: debug
debug: _debug-prefix debug-paths debug-sources #> Show debugging information
	@:

.PHONY: _debug-prefix
_debug-prefix:
	$(info ==dotfiles/git==)
	@:
