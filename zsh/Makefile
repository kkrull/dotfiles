# Project

.PHONY: default
default: all

## Environment

### Paths

env_dest := $(HOME)/.zshenv

.PHONY: debug-paths
debug-paths:
	$(info zsh_paths:)
	$(info - env_dest: $(env_dest))
	@:

### Programs

### Sources

srcdir := $(abspath .)

.PHONY: debug-sources
debug-sources:
	$(info zsh_sources:)
	$(info - srcdir: $(srcdir))
	@:

#. STANDARD TARGETS

.PHONY: all
all: #> Build all sources (if any)
	@:

.PHONY: check
check: #> Run self-tests
	@:

.PHONY: clean
clean: #> Remove local build files (if any)
	@:

.PHONY: install
install: #> Install configuration
	$(file >$(env_dest),ZDOTDIR=$(srcdir))
	$(file >>$(env_dest),source $$ZDOTDIR/.zshenv)
	@echo Created $(env_dest)

.PHONY: test
test:
	@:

.PHONY: uninstall
uninstall: #> Uninstall configuration
	rm -f "$(env_dest)"

#. OTHER TARGETS

.PHONY: debug
.NOTPARALLEL: debug
debug: debug-paths debug-sources #> Show build information
	@:

# https://stackoverflow.com/a/47107132/112682
.PHONY: help
help: #> Show this help
	@sed -n \
		-e '/@sed/!s/#[.] */_margin_\n/p' \
		-e '/@sed/!s/:.*#> /:/p' \
		$(MAKEFILE_LIST) \
	| column -ts : | sed -e 's/_margin_//'
