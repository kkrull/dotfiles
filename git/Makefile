## Top-level tasks

default: git-install

## git

.PHONY: git-install
git-install:
	rm -f "$(HOME)/.gitconfig.orig" "$(HOME)/.gitignore.orig"
	[ ! -f "$(HOME)/.gitconfig" ] || mv "$(HOME)/.gitconfig" "$(HOME)/.gitconfig.orig"
	[ ! -f "$(HOME)/.gitignore" ] || mv "$(HOME)/.gitignore" "$(HOME)/.gitignore.orig"

	ln -s $$(git rev-parse --show-toplevel)/git/gitconfig "$(HOME)/.gitconfig"
	ln -s $$(git rev-parse --show-toplevel)/git/gitignore "$(HOME)/.gitignore"

.PHONY: git-remove
git-remove:
	rm -f "$(HOME)/.gitconfig" "$(HOME)/.gitignore"
