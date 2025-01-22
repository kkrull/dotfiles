# Project

.PHONY: default
default: all

## Environment

uname_s := $(shell uname -s)

.PHONY: debug-env
debug-env:
	$(info - environment:)
	$(info   - OS: $(OS))
	$(info   - uname_s: $(uname_s))

### Paths

### Programs

### Sources

subdirs := git tmux zsh

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
debug: debug-env #> Show build information
	$(info dotfiles:)
	$(foreach dir,$(subdirs),$(MAKE) -C $(dir) $@ &&) true

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
