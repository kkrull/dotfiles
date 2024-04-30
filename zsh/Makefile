## Top-level tasks

default: install

## zsh

ENV_FILE := $(HOME)/.zshenv
ENV_FILE_BACKUP := $(ENV_FILE).orig
RC_PATH := $(shell git rev-parse --show-toplevel)/zsh

.PHONY: install
install:
	rm -f "$(ENV_FILE_BACKUP)"
	[ ! -f "$(ENV_FILE)" ] || mv "$(ENV_FILE)" "$(ENV_FILE_BACKUP)"

	$(file >$(ENV_FILE),ZDOTDIR=$(RC_PATH))
	$(file >>$(ENV_FILE),source ZDOTDIR.zshenv)

.PHONY: remove
remove:
	rm -f "$(ENV_FILE)"
