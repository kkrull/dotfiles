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
