# Project

.PHONY: default
default: all

## Environment

### Paths

conf_dest := $(HOME)/.gitconfig
conf_backup := $(conf_dest).orig

ignore_dest := $(HOME)/.gitignore
ignore_backup := $(ignore_dest).orig

.PHONY: debug-paths
debug-paths:
	$(info vim_paths:)
	$(info - conf_backup: $(conf_backup))
	$(info - conf_dest: $(conf_dest))
	$(info - ignore_backup: $(ignore_backup))
	$(info - ignore_dest: $(ignore_dest))
	@:

### Programs

### Sources

srcdir := $(abspath .)
conf_source := $(srcdir)/gitconfig
ignore_source := $(srcdir)/gitignore

.PHONY: debug-sources
debug-sources:
	$(info vim_sources:)
	$(info - srcdir: $(srcdir))
	$(info - conf_source: $(conf_source))
	$(info - ignore_source: $(ignore_source))
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
	rm -f "$(conf_backup)" "$(ignore_backup)"

	[ ! -f "$(conf_dest)" ] || mv "$(conf_dest)" "$(conf_backup)"
	ln -s "$(conf_source)" "$(conf_dest)"

	[ ! -f "$(ignore_dest)" ] || mv "$(ignore_dest)" "$(ignore_backup)"
	ln -s "$(ignore_source)" "$(ignore_dest)"

.PHONY: uninstall
uninstall: #> Uninstall configuration
	rm -f "$(conf_dest)" "$(ignore_dest)"

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
