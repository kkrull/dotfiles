#. DIRENV TARGETS

DIRENV ?= direnv

.PHONY: direnv-edit
direnv-edit: | .envrc.local #> Edit and load .envrc.local
	$(EDITOR) .envrc.local && $(DIRENV) allow

.PHONY: direnv-init
direnv-init: | .envrc.local #> Create .envrc.local from template
	@:

.envrc.local:
	cp .envrc.local.example .envrc.local
