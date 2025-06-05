#. HOMEBREW TARGETS

BREW ?= brew

.PHONY: homebrew-bundle-install
homebrew-bundle-install: #> Install packages with Homebrew (if present)
	@type $(BREW) &> /dev/null || exit 0
	$(BREW) bundle install
