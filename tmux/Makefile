## Top-level tasks

default: tmux-install

## git

.PHONY: tmux-install
tmux-install:
	rm -f "$(HOME)/.tmux.conf.orig"
	[ ! -f "$(HOME)/.tmux.conf" ] || mv "$(HOME)/.tmux.conf" "$(HOME)/.tmux.conf.orig"
	ln -s $$(git rev-parse --show-toplevel)/tmux/tmux.conf "$(HOME)/.tmux.conf"

.PHONY: tmux-remove
tmux-remove:
	rm -f "$(HOME)/.tmux.conf"
