#. ==dotfiles/wezterm==

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
wezterm_config := $(XDG_CONFIG_HOME)/wezterm

.PHONY: debug-paths
debug-paths:
	$(info Paths:)
	$(info - wezterm_config: $(wezterm_config))
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
install: $(wezterm_config) #> Install configuration
	@:

.PHONY: test
test:
	@:

.PHONY: uninstall
uninstall: #> Uninstall configuration
	$(RM) $(wezterm_config)

$(wezterm_config): | $(XDG_CONFIG_HOME)
	ln -f -s $(srcdir) $(wezterm_config)

$(XDG_CONFIG_HOME):
	@mkdir -p $(XDG_CONFIG_HOME)

#. SUPPORT TARGETS

.PHONY: debug
.NOTPARALLEL: debug
debug: _debug-prefix debug-paths debug-programs debug-sources #> Show debugging information
	@:

.PHONY: _debug-prefix
_debug-prefix:
	$(info ==dotfiles/wezterm==)
	@:
