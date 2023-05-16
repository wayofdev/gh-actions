NPM_BIN ?= pnpm
NPM_RUNNER ?= $(NPM_BIN)

# Self documenting Makefile code
# ------------------------------------------------------------------------------------
ifneq ($(TERM),)
	BLACK := $(shell tput setaf 0)
	RED := $(shell tput setaf 1)
	GREEN := $(shell tput setaf 2)
	YELLOW := $(shell tput setaf 3)
	LIGHTPURPLE := $(shell tput setaf 4)
	PURPLE := $(shell tput setaf 5)
	BLUE := $(shell tput setaf 6)
	WHITE := $(shell tput setaf 7)
	RST := $(shell tput sgr0)
else
	BLACK := ""
	RED := ""
	GREEN := ""
	YELLOW := ""
	LIGHTPURPLE := ""
	PURPLE := ""
	BLUE := ""
	WHITE := ""
	RST := ""
endif
MAKE_LOGFILE = /tmp/gh-actions.log
MAKE_CMD_COLOR := $(BLUE)

default: all

help: ## Show this menu
	echo ${MAKEFILE_LIST}

	@echo 'Management commands for package:'
	@echo 'Usage:'
	@echo '    ${MAKE_CMD_COLOR}make${RST}                       Shows this help message'
	@grep -E '^[a-zA-Z_0-9%-]+:.*?## .*$$' Makefile | awk 'BEGIN {FS = ":.*?## "}; {printf "    ${MAKE_CMD_COLOR}make %-21s${RST} %s\n", $$1, $$2}'
	@echo
	@echo '    📑 Logs are stored in      $(MAKE_LOGFILE)'
	@echo
	@echo '    📦 Package                 gh-actions (github.com/wayofdev/gh-actions)'
	@echo '    🤠 Author                  Andrij Orlenko (github.com/lotyp)'
	@echo '    🏢 ${YELLOW}Org                     wayofdev (github.com/wayofdev)${RST}'
.PHONY: help

# Default action
# Defines default command when `make` is executed without additional parameters
# ------------------------------------------------------------------------------------
all: help
.PHONY: all


# System Actions
# ------------------------------------------------------------------------------------
i: ## Install dependencies
	$(NPM_RUNNER) i
.PHONY: i

install: i ## Same as `make i`
.PHONY: install

validate: ## Validate all github action files
	@echo "Validating github actions..."
	action-validator .github/workflows/apply-labels.yml
	action-validator .github/workflows/auto-merge-release.yml
	action-validator .github/workflows/build-image.yml
	action-validator .github/workflows/create-arch-diagram.yml
	action-validator .github/workflows/create-release.yml
	action-validator .github/workflows/shellcheck.yml
.PHONY: validate

hooks: ## Install git hooks from pre-commit-config
	pre-commit install
	pre-commit autoupdate
.PHONY: hooks
