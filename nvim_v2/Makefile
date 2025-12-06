#. ==dotfiles/nvim_v2==

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
nvim_config := $(XDG_CONFIG_HOME)/nvim

.PHONY: debug-paths
debug-paths:
	$(info Paths:)
	$(info - nvim_config: $(nvim_config))
	$(info - XDG_CONFIG_HOME: $(XDG_CONFIG_HOME))
	@:

## Programs

.PHONY: debug-programs
debug-programs:
	$(info Programs:)
	@:

#. DEVELOPMENT ENVIRONMENT TARGETS

BREW ?= brew

.PHONY: install-tools
install-tools: #> Install neovim and related tools
	$(BREW) bundle install

#. STANDARD TARGETS

.PHONY: all
all:
	@:

.PHONY: clean
clean:
	@:

.PHONY: install
install: $(nvim_config) #> Install configuration
	@:

.PHONY: test
test:
	@:

.PHONY: uninstall
uninstall: #> Uninstall configuration
	$(RM) $(nvim_config)

$(nvim_config): | $(XDG_CONFIG_HOME)
	ln -f -s $(srcdir) $(nvim_config)

$(XDG_CONFIG_HOME):
	@mkdir -p $(XDG_CONFIG_HOME)

#. SUPPORT TARGETS

.PHONY: debug
.NOTPARALLEL: debug
debug: _debug-prefix debug-paths debug-programs debug-sources #> Show debugging information
	@:

.PHONY: _debug-prefix
_debug-prefix:
	$(info ==dotfiles/nvim_v2==)
	@:
