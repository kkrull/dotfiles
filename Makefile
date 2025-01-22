# Project

.PHONY: default
default: all

## Environment

### Paths

### Programs

### Sources

#. STANDARD TARGETS

.PHONY: all
all: #> Build all sources (if any)
	$(MAKE) -C git $@
	$(MAKE) -C tmux $@
	$(MAKE) -C zsh $@

.PHONY: check
check: pre-commit-check #> Run self-tests
	$(MAKE) -C git $@
	$(MAKE) -C tmux $@
	$(MAKE) -C zsh $@

.PHONY: clean
clean: pre-commit-gc #> Remove local build files (if any)
	$(MAKE) -C git $@
	$(MAKE) -C tmux $@
	$(MAKE) -C zsh $@

.PHONY: install
install: #> Install configuration
	$(MAKE) -C git $@
	$(MAKE) -C tmux $@
	$(MAKE) -C zsh $@

.PHONY: uninstall
uninstall: #> Uninstall configuration
	$(MAKE) -C git $@
	$(MAKE) -C tmux $@
	$(MAKE) -C zsh $@

#. OTHER TARGETS

# https://stackoverflow.com/a/47107132/112682
.PHONY: help
help: #> Show this help
	@sed -n \
		-e '/@sed/!s/#[.] */_margin_\n/p' \
		-e '/@sed/!s/:.*#> /:/p' \
		$(MAKEFILE_LIST) \
	| column -ts : | sed -e 's/_margin_//'

.PHONY: help-all
help-all: help #> Show help for all Makefiles
	$(MAKE) -C git help
	$(MAKE) -C tmux help
	$(MAKE) -C zsh help

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
