# Project

.PHONY: default
default: all

## Environment

### Paths

home_conf_dest := $(HOME)/.vimrc
home_conf_backup := $(home_conf_dest).orig

neovim_conf_dir := $(HOME)/.config/nvim
neovim_conf_dest := $(neovim_conf_dir)/init.vim
neovim_conf_backup := $(home_conf_dest).orig

$(neovim_conf_dir):
	mkdir -p $(neovim_conf_dir)

.PHONY: debug-paths
debug-paths:
	$(info vim_paths:)
	$(info - home_conf_backup: $(home_conf_backup))
	$(info - home_conf_dest: $(home_conf_dest))
	$(info - neovim_conf_backup: $(neovim_conf_backup))
	$(info - neovim_conf_dest: $(neovim_conf_dest))
	@:

### Programs

### Sources

srcdir := $(abspath .)
conf_source := $(srcdir)/vimrc

.PHONY: debug-sources
debug-sources:
	$(info vim_sources:)
	$(info - srcdir: $(srcdir))
	$(info - conf_source: $(conf_source))
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
install: | $(neovim_conf_dir) #> Install configuration
	rm -f "$(home_conf_backup)" "$(neovim_conf_backup)"

	[ ! -f "$(home_conf_dest)" ] || mv "$(home_conf_dest)" "$(home_conf_backup)"
	ln -s "$(conf_source)" "$(home_conf_dest)"

	[ ! -f "$(neovim_conf_dest)" ] || mv "$(neovim_conf_dest)" "$(neovim_conf_backup)"
	ln -s "$(conf_source)" "$(neovim_conf_dest)"

.PHONY: uninstall
uninstall: #> Uninstall configuration
	rm -f "$(home_conf_dest)"

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
