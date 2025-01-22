# Project

.PHONY: default
default: all

## Environment

### Paths

conf_dest := $(HOME)/.tmux.conf
conf_backup := $(conf_dest).orig

.PHONY: debug-paths
debug-paths:
	$(info Paths:)
	$(info - conf_backup: $(conf_backup))
	$(info - conf_dest: $(conf_dest))

### Programs

### Sources

srcdir := $(abspath .)
conf_source := $(srcdir)/tmux.conf

.PHONY: debug-sources
debug-sources:
	$(info Sources:)
	$(info - srcdir: $(srcdir))
	$(info - conf_source: $(conf_source))

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
	rm -f "$(conf_backup)"
	[ ! -f "$(conf_dest)" ] || mv "$(conf_dest)" "$(conf_backup)"
	ln -s "$(conf_source)" "$(conf_dest)"

.PHONY: uninstall
uninstall: #> Uninstall configuration
	rm -f "$(conf_dest)"

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
