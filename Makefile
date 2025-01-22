## Top-level tasks

default: check

.PHONY: check
check: pre-commit-check

.PHONY: install
install:
	$(MAKE) -C git $@
	$(MAKE) -C tmux $@
	$(MAKE) -C zsh $@

.PHONY: uninstall
uninstall:
	$(MAKE) -C git $@
	$(MAKE) -C tmux $@
	$(MAKE) -C zsh $@

## pre-commit

.PHONY: pre-commit-check
pre-commit-check:
	pre-commit run --all-files

.PHONY: pre-commit-clean
pre-commit-clean:
	pre-commit gc

.PHONY: pre-commit-update
pre-commit-update:
	pre-commit autoupdate
