.PHONY: all clean
.PHONY: deps compile iex version versions livebook

SHELL := BASH_ENV=.rc /bin/bash --noprofile

## Help
##============================================================

help:  ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

## Main targets
##============================================================

all: compile  ## Build the project (default)

deps:  ## Get project dependencies
	mix deps.get

compile: deps  ## Compile the project
	mix compile

iex:  compile ## Start an interactive Elixir shell
	iex -S mix

livebook: compile ## Start Livebook server with notebooks directory mounted
	livebook

clean:  ## Clean all build artifacts
	mix clean --all
	mix deps.clean --all
	rm -rf _build
	rm -rf doc

## Version management
##============================================================

version:  ## Show current Elixir version
	@echo "Current Elixir version: $${ELIXIR_VERSION}"

versions:  ## Show all configured versions
	@cat .versions

## You can override versions using environment variables:
##   make compile ELIXIR_VERSION=1.14.5