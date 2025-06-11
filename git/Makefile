#. ==dotfiles/git==

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

XDG_CONFIG_HOME ?= $(HOME)/.config
git_config := $(XDG_CONFIG_HOME)/git

.PHONY: debug-paths
debug-paths:
	$(info Paths:)
	$(info - git_config: $(git_config))
	$(info - XDG_CONFIG_HOME: $(XDG_CONFIG_HOME))
	@:

## Programs

.PHONY: debug-programs
debug-programs:
	$(info Programs:)
	@:

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

.PHONY: install
install: $(git_config) #> Install configuration
	@:

.PHONY: test
test:
	@:

.PHONY: uninstall
uninstall: #> Uninstall configuration
	$(RM) $(git_config)

$(git_config):
	ln -f -s $(srcdir) $(git_config)

#. SUPPORT TARGETS

.PHONY: debug
.NOTPARALLEL: debug
debug: _debug-prefix debug-paths debug-programs debug-sources #> Show debugging information
	@:

.PHONY: _debug-prefix
_debug-prefix:
	$(info ==dotfiles/git==)
	@:
