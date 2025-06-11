#. ==dotfiles/tmux==

.PHONY: default
default: all

include ../make.d/help.mk

## Project

## Sources

srcdir := $(realpath .)

.PHONY: debug-sources
debug-sources:
	$(info Sources:)
	$(info - srcdir: $(srcdir))
	@:

## Artifacts

## Paths

tmux_config := $(HOME)/.tmux.conf

.PHONY: debug-paths
debug-paths:
	$(info Paths:)
	$(info - tmux_config: $(tmux_config))
	@:

## Programs

INSTALL ?= install
INSTALLFLAGS :=

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
install: $(tmux_config) #> Install configuration
	@:

.PHONY: test
test:
	@:

.PHONY: uninstall
uninstall: #> Uninstall configuration
	$(RM) $(tmux_config)

$(tmux_config):
	ln -f -s $(srcdir)/tmux.conf $(tmux_config)

#. SUPPORT TARGETS

.PHONY: debug
.NOTPARALLEL: debug
debug: _debug-prefix debug-paths debug-programs debug-sources #> Show debugging information
	@:

.PHONY: _debug-prefix
_debug-prefix:
	$(info ==dotfiles/tmux==)
	@:
