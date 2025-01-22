default: all

## Top-level tasks

.PHONY: all
all:
	@:

## zsh

ENV_FILE := $(HOME)/.zshenv
RC_PATH := $(shell git rev-parse --show-toplevel)/zsh

.PHONY: install
install:
	$(file >$(ENV_FILE),ZDOTDIR=$(RC_PATH))
	$(file >>$(ENV_FILE),source $$ZDOTDIR/.zshenv)
	@echo Created $(ENV_FILE)

.PHONY: uninstall
uninstall:
	rm -f "$(ENV_FILE)"
