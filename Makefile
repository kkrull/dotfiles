# Project

.PHONY: default
default: all

## Environment

uname_s := $(shell uname -s)
ifeq ($(OS),Windows_NT)
	detected_os := Windows
else
	detected_os := $(uname_s)
endif

.PHONY: debug-env
debug-env:
	$(info environment:)
	$(info - detected_os: $(detected_os))
	$(info - OS: $(OS))
	@:

### Paths

### Programs

### Sources

subdirs := git tmux vim-macos zsh
ifeq ($(detected_os),Windows)
 	subdirs := git tmux vim-wsl zsh
endif

.PHONY: debug-sources
debug-sources:
	$(info sources:)
	$(info - subdirs: $(subdirs))
	@:

#. STANDARD TARGETS

.PHONY: all
all: #> Build all sources (if any)
	$(foreach dir,$(subdirs),$(MAKE) -C $(dir) -w $@ &&) true

.PHONY: check
check: pre-commit-check #> Run self-tests
	$(foreach dir,$(subdirs),$(MAKE) -C $(dir) -w $@ &&) true

.PHONY: clean
clean: pre-commit-gc #> Remove local build files (if any)
	$(foreach dir,$(subdirs),$(MAKE) -C $(dir) -w $@ &&) true

.PHONY: install
install: #> Install configuration
	$(foreach dir,$(subdirs),$(MAKE) -C $(dir) -w $@ &&) true

.PHONY: uninstall
uninstall: #> Uninstall configuration
	$(foreach dir,$(subdirs),$(MAKE) -C $(dir) -w $@ &&) true

#. OTHER TARGETS

.PHONY: debug
.NOTPARALLEL: debug
debug: debug-env debug-sources #> Show build information for project
	@:

.PHONY: debug-all
.NOTPARALLEL: debug-all
debug-all: debug #> Show build information for subsystems
	$(foreach dir,$(subdirs),$(MAKE) -C $(dir) debug &&) true

# https://stackoverflow.com/a/47107132/112682
.PHONY: help
help: #> Show this help
	@sed -n \
		-e '/@sed/!s/#[.] */_margin_\n/p' \
		-e '/@sed/!s/:.*#> /:/p' \
		$(MAKEFILE_LIST) \
	| column -ts : | sed -e 's/_margin_//'

.PHONY: help-all
.NOTPARALLEL: help-all
help-all: help #> Show help for all Makefiles
	$(foreach dir,$(subdirs),$(MAKE) -C $(dir) -w help &&) true

#. PRE-COMMIT TARGETS

PRECOMMIT ?= pre-commit

.PHONY: pre-commit-gc
pre-commit-gc: #> Remove stale pre-commit files
	$(PRECOMMIT) gc

.PHONY: pre-commit-install
pre-commit-install: #> Install Git pre-commit hook
	$(PRECOMMIT) install

.PHONY: pre-commit-run
pre-commit-run: #> Run pre-commit on all sources
	$(PRECOMMIT) run --all-files

.PHONY: pre-commit-update
pre-commit-update: #> Update pre-commit plugins
	$(PRECOMMIT) autoupdate
