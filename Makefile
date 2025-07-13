# Docker binary to use, when executing docker tasks
DOCKER ?= docker

YAML_LINT_RUNNER ?= $(DOCKER) run --rm $$(tty -s && echo "-it" || echo) \
	-v $(shell pwd):/data \
	cytopia/yamllint:latest \
	-f colored .

ACTION_LINT_RUNNER ?= $(DOCKER) run --rm $$(tty -s && echo "-it" || echo) \
	-v $(shell pwd):/repo \
	 --workdir /repo \
	 rhysd/actionlint:latest \
	 -color

MARKDOWN_LINT_RUNNER ?= $(DOCKER) run --rm $$(tty -s && echo "-it" || echo) \
	-v $(shell pwd):/app \
	--workdir /app \
	davidanson/markdownlint-cli2-rules:latest

RENOVATE_RUNNER ?= $(DOCKER) run --rm $$(tty -s && echo "-it" || echo) \
	-v $(shell pwd):/usr/src/app \
	--workdir /usr/src/app \
	renovate/renovate:latest

#
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
MAKE_LOGFILE = /tmp/wayofdev-gh-actions.log
MAKE_CMD_COLOR := $(BLUE)

default: all

help: ## Show this menu
	@echo 'Management commands for package:'
	@echo 'Usage:'
	@echo '    ${MAKE_CMD_COLOR}make${RST}                       Installs pre-commit hooks and does linting'
	@grep -E '^[a-zA-Z_0-9%-]+:.*?## .*$$' Makefile | awk 'BEGIN {FS = ":.*?## "}; {printf "    ${MAKE_CMD_COLOR}make %-21s${RST} %s\n", $$1, $$2}'
	@echo
	@echo '    📑 Logs are stored in      $(MAKE_LOGFILE)'
	@echo
	@echo '    📦 Package                 gh-actions (github.com/wayofdev/gh-actions)'
	@echo '    🤠 Author                  Andrij Orlenko (github.com/lotyp)'
	@echo '    🏢 ${YELLOW}Org                     wayofdev (github.com/wayofdev)${RST}'
	@echo
.PHONY: help

.EXPORT_ALL_VARIABLES:

#
# Default action
# Defines default command when `make` is executed without additional parameters
# ------------------------------------------------------------------------------------
all: hooks lint
.PHONY: all

#
# Code Quality, Git, Linting
# ------------------------------------------------------------------------------------
hooks: ## Install git hooks from pre-commit-config
	pre-commit install
	pre-commit install --hook-type commit-msg
	pre-commit autoupdate
.PHONY: hooks

lint: lint-yaml lint-actions lint-md lint-renovate ## Lint all files
.PHONY: lint

lint-yaml: ## Lint all yaml files
	@$(YAML_LINT_RUNNER)
.PHONY: lint-yaml

lint-actions: ## Lint all github actions
	@$(ACTION_LINT_RUNNER)
.PHONY: lint-actions

lint-md: ## Lint all markdown files using markdownlint-cli2
	@$(MARKDOWN_LINT_RUNNER) --fix "**/*.md" "#CHANGELOG.md" | tee -a $(MAKE_LOGFILE)
.PHONY: lint-md

lint-md-dry: ## Lint all markdown files using markdownlint-cli2 in dry-run mode
	@$(MARKDOWN_LINT_RUNNER) "**/*.md" "#CHANGELOG.md" | tee -a $(MAKE_LOGFILE)
.PHONY: lint-md-dry

lint-renovate: ## Validate renovate configuration
	@echo "${GREEN}🤖 Validating renovate.json5 configuration...${RST}"
	@$(RENOVATE_RUNNER) renovate-config-validator renovate.json5 | tee -a $(MAKE_LOGFILE)
.PHONY: lint-renovate

renovate-dry-run: ## Run renovate in dry-run mode (requires GITHUB_TOKEN)
	@echo "${GREEN}🤖 Running renovate in dry-run mode...${RST}"
	@if [ -z "$(GITHUB_TOKEN)" ]; then \
		echo "${RED}❌ Error: GITHUB_TOKEN environment variable is required${RST}"; \
		echo "${YELLOW}💡 Set it with: export GITHUB_TOKEN=your_token_here${RST}"; \
		exit 1; \
	fi
	@$(RENOVATE_RUNNER) \
		-e GITHUB_TOKEN="$(GITHUB_TOKEN)" \
		-e LOG_LEVEL=info \
		renovate --dry-run --print-config | tee -a $(MAKE_LOGFILE)
.PHONY: renovate-dry-run

#
# Release
# ------------------------------------------------------------------------------------
commit:
	czg commit --config="./.github/.cz.config.js"
.PHONY: commit
