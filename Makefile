#. ==dotfiles==

.PHONY: default
default: all

## Sources

## Artifacts

## Paths

## Programs

.PHONY: debug-programs
debug-programs:
	$(info Programs:)
	@:

## Project

# https://stackoverflow.com/a/17845120/112682
SUBDIRS := \
	git \
	ideavim \
	karabiner \
	tmux \
	zsh

.PHONY: $(SUBDIRS)
$(SUBDIRS):
	$(MAKE) -C $@ $(MAKECMDGOALS)

.PHONY: debug-project
debug-project:
	$(info Project:)
	$(info - SUBDIRS: $(SUBDIRS))
	@:

# include make.d/direnv.mk
include make.d/help.mk
# include make.d/homebrew.mk
include make.d/pre-commit.mk

#. DEVELOPMENT ENVIRONMENT TARGETS

.PHONY: install-tools
install-tools: pre-commit-install $(SUBDIRS)
	@:

#. STANDARD TARGETS

.PHONY: all
all: $(SUBDIRS) #> Build all projects
	@:

.PHONY: clean
clean: pre-commit-gc $(SUBDIRS) #> Remove local build files
	@:

.PHONY: install
install: $(SUBDIRS) #> Link dotfiles to XDG config directory
	@:

.PHONY: test
test: pre-commit-run $(SUBDIRS) #> Run checks and tests
	@:

.PHONY: uninstall
uninstall: $(SUBDIRS) #> Unlink dotfiles from XDG config directory
	@:

#. SUPPORT TARGETS

.PHONY: debug
.NOTPARALLEL: debug
debug: _debug-prefix debug-programs debug-project $(SUBDIRS) #> Show debugging information
	@:

.PHONY: _debug-prefix
_debug-prefix:
	$(info ==dotfiles==)
	@:
