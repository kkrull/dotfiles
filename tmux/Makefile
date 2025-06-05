#. ==dotfiles/tmux==

.PHONY: default
default: all

include ../make.d/help.mk

## Project

## Sources

srcdir := $(realpath .)

.PHONY: source-info
source-info:
	$(info Sources:)
	$(info - srcdir: $(srcdir))
	@:

## Artifacts

## Paths

XDG_CONFIG_HOME ?= $(HOME)/.config
tmux_config := $(XDG_CONFIG_HOME)/tmux

.PHONY: debug-paths
debug-paths:
	$(info Paths:)
	$(info - tmux_config: $(tmux_config))
	$(info - XDG_CONFIG_HOME: $(XDG_CONFIG_HOME))
	@:

## Programs

INSTALL ?= install
INSTALLFLAGS :=

.PHONY: debug-programs
debug-programs:
	$(info Programs:)
	$(info - INSTALL: $(INSTALL))
	$(info - INSTALLFLAGS: $(INSTALLFLAGS))
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
install: #> Install configuration
	$(INSTALL) $(INSTALLFLAGS) -d $(XDG_CONFIG_HOME)
	ln -f -s $(srcdir) $(tmux_config)

.PHONY: test
test:
	@:

.PHONY: uninstall
uninstall: #> Uninstall configuration
	$(RM) $(tmux_config)

#. SUPPORT TARGETS

.PHONY: debug
.NOTPARALLEL: debug
debug: _debug-prefix debug-paths debug-programs debug-sources #> Show debugging information
	@:

.PHONY: _debug-prefix
_debug-prefix:
	$(info ==dotfiles/tmux==)
	@:
